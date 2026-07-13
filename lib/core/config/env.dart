class Env {
  const Env._();

  static const firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
  );

  static const openAiApiKey = String.fromEnvironment('OPENAI_API_KEY');

  static const whatsappApiKey = String.fromEnvironment('WHATSAPP_API_KEY');
}
