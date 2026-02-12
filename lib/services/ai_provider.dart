enum AIProvider {
  gemini,
  gpt,
}

AIProvider aiProviderFromString(String? raw) {
  final value = raw?.trim().toLowerCase();
  if (value == 'gpt' || value == 'openai') return AIProvider.gpt;
  return AIProvider.gemini;
}
