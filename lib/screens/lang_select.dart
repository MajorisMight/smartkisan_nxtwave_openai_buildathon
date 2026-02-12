import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kisan/l10n/app_localizations.dart';
import 'package:kisan/main.dart'; // Assuming your main app class is in main.dart
import 'package:kisan/services/app_config_service.dart';

import '../services/session_service.dart'; // Import the session service

// A model class to hold language details
class Language {
  final String name;
  final String nativeName;
  final String code;

  const Language({
    required this.name,
    required this.nativeName,
    required this.code,
  });
}

// List of languages for the selection screen
const List<Language> languages = [
  Language(name: 'English', nativeName: 'English', code: 'en'),
  Language(name: 'Hindi', nativeName: 'हिन्दी', code: 'hi'),
  Language(name: 'Tamil', nativeName: 'தமிழ்', code: 'ta'),
  Language(name: 'Telugu', nativeName: 'తెలుగు', code: 'te'),
  Language(name: 'Marathi', nativeName: 'मراठी', code: 'mr'),
  Language(name: 'Bengali', nativeName: 'বাংলা', code: 'bn'),
  Language(name: 'Punjabi', nativeName: 'ਪੰਜਾਬੀ', code: 'pa'),
  Language(name: 'Rajasthani', nativeName: 'राजस्थानी', code: 'raj'),
  Language(name: 'Gujarati', nativeName: 'ગુજરાતી', code: 'gu'),
  Language(name: 'Kannada', nativeName: 'ಕನ್ನಡ', code: 'kn'),
  Language(name: 'Malayalam', nativeName: 'മലയാളം', code: 'ml'),
  Language(name: 'Odia', nativeName: 'ଓଡ଼ିଆ', code: 'or'),
];

class LanguageSelectPage extends StatefulWidget {
  const LanguageSelectPage({super.key});

  @override
  State<LanguageSelectPage> createState() => _LanguageSelectPageState();
}

class _LanguageSelectPageState extends State<LanguageSelectPage> {
  Language? _selectedLanguage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = languages.first;
    _initializeSelection();
  }

  Future<void> _initializeSelection() async {
    final savedCode = await SessionService.getLanguagePreference();
    if (!mounted) return;

    final initialLanguage = languages.firstWhere(
      (language) => language.code == savedCode,
      orElse: () => languages.first,
    );

    setState(() {
      _selectedLanguage = initialLanguage;
    });

    FarmerEcosystemApp.setLocale(context, Locale(initialLanguage.code));
  }

  void _onLanguageSelected(Language language) async {
    setState(() {
      _selectedLanguage = language;
    });
    await SessionService.saveLanguagePreference(language.code);
    if (!mounted) return;
    FarmerEcosystemApp.setLocale(context, Locale(language.code));
  }

  Future<void> _onContinue() async {
    if (_selectedLanguage == null) return;

    setState(() {
      _isSaving = true; // Show loading indicator
    });

    // 3. Show a confirmation snackbar
    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.languageSelectedSnackbar(_selectedLanguage!.name)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
    
    // 4. Navigate to the next screen
    if (AppConfigService.isAuthFlowEnabled()) {
      context.go('/otp');
    } else {
      final onboarded = await SessionService.isOnboardingComplete();
      if (!mounted) return;
      if (onboarded) {
        context.go('/home');
      } else {
        context.go('/onboarding');
      }
    }

    // It's good practice to check if the widget is still mounted
    // before trying to update its state after an async gap.
    if (mounted) {
        setState(() {
          _isSaving = false;
        });
    }
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectLanguageTitle),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
              child: Text(
                l10n.selectLanguagePrompt,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: languages.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.8,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final language = languages[index];
                  final isSelected = _selectedLanguage?.code == language.code;
                  return LanguageTile(
                    language: language,
                    isSelected: isSelected,
                    onTap: () => _onLanguageSelected(language),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedLanguage == null || _isSaving ? null : _onContinue,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(l10n.continueButton, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class LanguageTile extends StatelessWidget {
  const LanguageTile({
    super.key,
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  final Language language;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: isSelected ? 4 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    language.nativeName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    language.name,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.check_circle,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
