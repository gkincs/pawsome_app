import 'package:flutter/material.dart';
import 'package:pawsome_app/screens/pet_prof_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pawsome_app/screens/main_screen.dart';

class FirststepWidget extends StatefulWidget {
  const FirststepWidget({super.key});

  @override
  _FirststepWidgetState createState() => _FirststepWidgetState();
}

/// Az a képernyő, amely segítéségével a felhasználó hozzáadhatja az első kisállatát a profilhoz.
/// Ha a kisállat profilját sikeresen elmenti, akkor a főképernyőre navigál.
class _FirststepWidgetState extends State<FirststepWidget> {
  final bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTitle(),
                        const SizedBox(height: 120),
                        _buildSubtitle(l10n),
                        const SizedBox(height: 40),
                        _buildAddButton(context, l10n),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'PawSome',
      style: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle(AppLocalizations l10n) {
    return Text(
      l10n.addFirstPet,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.normal,
        color: Color.fromRGBO(0, 0, 0, 0.9),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, AppLocalizations l10n) {
    return ElevatedButton(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PetProfileWidget(
              petId: null,
              isFirstRegistration: true,
            ),
          ),
        );
        
        if (result == true) {
          // Ha sikeresen mentette a kisállat profilját, navigáljunk a főképernyőre
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFEADDFF),
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(l10n.add),
    );
  }
}
