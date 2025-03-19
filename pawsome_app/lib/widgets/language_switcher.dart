import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        final isEnglish = languageService.currentLocale.languageCode == 'en';
        return TextButton(
          child: Text(
            isEnglish ? 'Magyar' : 'English',
            style: const TextStyle(
              color: Color(0xFF65558F),
              fontWeight: FontWeight.w500,
            ),
          ),
          onPressed: () {
            languageService.changeLanguage(isEnglish ? 'hu' : 'en');
          },
        );
      },
    );
  }
} 