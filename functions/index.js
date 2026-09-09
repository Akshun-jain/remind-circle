const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {setGlobalOptions} = require("firebase-functions");
const {initializeApp} = require("firebase-admin/app");
const {getAuth} = require("firebase-admin/auth");
const {getMessaging} = require("firebase-admin/messaging");
const {
  getFirestore,
  FieldValue,
} = require("firebase-admin/firestore");

initializeApp();

setGlobalOptions({
  maxInstances: 10,
});

const db = getFirestore();

const RECENT_AUTH_SECONDS = 10 * 60;

/**
 * Deletes the authenticated user's RemindCircle account and associated data.
 *
 * @param {Object} request Callable function request.
 * @return {Promise<Object>} Deletion result.
 */
exports.deleteAccount = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError(
        "unauthenticated",
        "You must be signed in to delete your account.",
    );
  }

  const authTime = request.auth.token.auth_time;
  const currentTime = Math.floor(Date.now() / 1000);

  if (
    typeof authTime !== "number" ||
    currentTime - authTime > RECENT_AUTH_SECONDS
  ) {
    throw new HttpsError(
        "failed-precondition",
        "For your security, please sign in again before deleting your account.",
    );
  }

  const uid = request.auth.uid;

  try {
    const groupsSnapshot = await db.collection("groups").get();

    const ownedGroups = [];
    const memberGroups = [];

    for (const groupDoc of groupsSnapshot.docs) {
      const group = groupDoc.data();

      if (group.ownerId === uid) {
        ownedGroups.push(groupDoc);
        continue;
      }

      const memberIds = Array.isArray(group.memberIds) ?
        group.memberIds :
        [];

      if (memberIds.includes(uid)) {
        memberGroups.push(groupDoc);
      }
    }

    // Delete groups owned by the user.
    for (const groupDoc of ownedGroups) {
      await deleteOwnedGroup(groupDoc);
    }

    // Remove the user from groups owned by somebody else.
    for (const groupDoc of memberGroups) {
      await removeUserFromGroup(groupDoc.id, uid);
    }

    // Delete the user's top-level Firestore profile.
    await db.collection("users").doc(uid).delete();

    // Delete the Firebase Authentication account last.
    await getAuth().deleteUser(uid);

    return {
      success: true,
    };
  } catch (error) {
    console.error("Account deletion failed", {
      uid,
      error: error.message,
    });

    throw new HttpsError(
        "internal",
        "We could not completely delete your account. Please try again.",
    );
  }
});

/**
 * Sends a push notification to group members when a new event is created.
 */
exports.notifyGroupMembersOnEventCreated = onDocumentCreated(
    "groups/{groupId}/events/{eventId}",
    async (event) => {
      const snapshot = event.data;

      if (!snapshot) {
        console.log("No event data found.");
        return;
      }

      const eventData = snapshot.data();
      const groupId = event.params.groupId;
      const eventId = event.params.eventId;

      const createdBy = eventData.createdBy;
      const eventTitle = eventData.title || "New event";
      const personName = eventData.personName;
      const eventType = eventData.eventType || "custom";

      try {
        const groupSnapshot = await db
            .collection("groups")
            .doc(groupId)
            .get();

        if (!groupSnapshot.exists) {
          console.log(`Group ${groupId} does not exist.`);
          return;
        }

        const group = groupSnapshot.data();
        const groupName = group.name || "Group";

        const memberIds = Array.isArray(group.memberIds) ?
          group.memberIds :
          [];

        // Don't send the push notification back to the creator.
        const recipientIds = memberIds.filter((uid) => uid !== createdBy);

        if (recipientIds.length === 0) {
          console.log("No other group members to notify.");
          return;
        }

        const userRefs = recipientIds.map((uid) =>
          db.collection("users").doc(uid),
        );

        const userSnapshots = await db.getAll(...userRefs);

        const tokens = [];
        const tokenOwners = new Map();

        for (const userSnapshot of userSnapshots) {
          if (!userSnapshot.exists) {
            continue;
          }

          const userData = userSnapshot.data();
          const userTokens = Array.isArray(userData.fcmTokens) ?
            userData.fcmTokens :
            [];

          for (const token of userTokens) {
            if (typeof token !== "string" || token.length === 0) {
              continue;
            }

            tokens.push(token);
            tokenOwners.set(token, userSnapshot.id);
          }
        }

        if (tokens.length === 0) {
          console.log("No FCM tokens found for group members.");
          return;
        }

        let eventTypeLabel;
        let eventEmoji;

        switch (eventType) {
          case "birthday":
            eventTypeLabel = "Birthday";
            eventEmoji = "🎂";
            break;
          case "anniversary":
            eventTypeLabel = "Anniversary";
            eventEmoji = "💍";
            break;
          case "workAnniversary":
            eventTypeLabel = "Work Anniversary";
            eventEmoji = "🏆";
            break;
          case "meeting":
            eventTypeLabel = "Meeting";
            eventEmoji = "📅";
            break;
          case "festival":
            eventTypeLabel = "Festival";
            eventEmoji = "🎉";
            break;
          case "holiday":
            eventTypeLabel = "Holiday";
            eventEmoji = "🌴";
            break;
          case "custom":
            eventTypeLabel = "Custom";
            eventEmoji = "📅";
            break;
          case "other":
            eventTypeLabel = "Other";
            eventEmoji = "📅";
            break;
          default:
            eventTypeLabel = "Event";
            eventEmoji = "📅";
        }

        const response = await getMessaging().sendEachForMulticast({
          tokens,
          notification: {
            title: "New group event",
            body: `${eventEmoji} ${eventTypeLabel} — ${
              personName || eventTitle
            }\n- ${groupName}`,
          },
          data: {
            type: "new_group_event",
            groupId,
            eventId,
          },
          android: {
            notification: {
              channelId: "event_channel",
            },
          },
        });

        console.log(
            `FCM notification result: ${response.successCount} sent, ` +
            `${response.failureCount} failed.`,
        );

        // Remove invalid/expired FCM tokens.
        const cleanupPromises = [];

        response.responses.forEach((sendResponse, index) => {
          if (sendResponse.success) {
            return;
          }

          let errorCode;

          if (sendResponse.error) {
            errorCode = sendResponse.error.code;
          }

          if (
            errorCode === "messaging/registration-token-not-registered" ||
            errorCode === "messaging/invalid-registration-token"
          ) {
            const token = tokens[index];
            const ownerUid = tokenOwners.get(token);

            if (ownerUid) {
              cleanupPromises.push(
                  db.collection("users").doc(ownerUid).update({
                    fcmTokens: FieldValue.arrayRemove(token),
                  }),
              );
            }
          }
        });

        await Promise.all(cleanupPromises);
      } catch (error) {
        console.error(
            "Failed to send group event notifications",
            {
              groupId,
              eventId,
              error: error.message,
            },
        );
      }
    },
);

/**
 * Deletes a group owned by the user, including its subcollections.
 *
 * @param {FirebaseFirestore.QueryDocumentSnapshot} groupDoc Group document.
 * @return {Promise<void>} Resolves when the group is deleted.
 */
async function deleteOwnedGroup(groupDoc) {
  const groupId = groupDoc.id;
  const group = groupDoc.data();

  await deleteCollection(
      db.collection("groups").doc(groupId).collection("events"),
  );

  await deleteCollection(
      db.collection("groups").doc(groupId).collection("members"),
  );

  if (group.inviteCode) {
    await db.collection("inviteCodes").doc(group.inviteCode).delete();
  }

  await db.collection("groups").doc(groupId).delete();
}

/**
 * Removes a user from a group they do not own.
 *
 * @param {string} groupId Group ID.
 * @param {string} uid User ID.
 * @return {Promise<void>} Resolves when membership is removed.
 */
async function removeUserFromGroup(groupId, uid) {
  const groupRef = db.collection("groups").doc(groupId);
  const memberRef = groupRef.collection("members").doc(uid);

  await groupRef.update({
    memberIds: FieldValue.arrayRemove(uid),
    admins: FieldValue.arrayRemove(uid),
  });

  await memberRef.delete();

  // Keep shared events, but remove the deleted user's identity.
  const eventsSnapshot = await groupRef
      .collection("events")
      .where("createdBy", "==", uid)
      .get();

  for (const eventDoc of eventsSnapshot.docs) {
    await eventDoc.ref.update({
      createdBy: "",
      createdByName: "Deleted User",
    });
  }
}

/**
 * Deletes all documents in a collection in chunks.
 *
 * @param {FirebaseFirestore.CollectionReference} collectionRef Collection.
 * @return {Promise<void>} Resolves when the collection is empty.
 */
async function deleteCollection(collectionRef) {
  let hasMore = true;

  while (hasMore) {
    const snapshot = await collectionRef.limit(400).get();

    if (snapshot.empty) {
      hasMore = false;
      continue;
    }

    const batch = db.batch();

    for (const doc of snapshot.docs) {
      batch.delete(doc.ref);
    }

    await batch.commit();

    hasMore = snapshot.size === 400;
  }
}
