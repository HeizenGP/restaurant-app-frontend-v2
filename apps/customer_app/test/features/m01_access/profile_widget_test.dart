import 'package:customer_app/app/theme/theme_mode_controller.dart';
import 'package:customer_app/core/design_system/theme/app_theme.dart';
import 'package:customer_app/features/m01_access/profile/application/user_profile_controller.dart';
import 'package:customer_app/features/m01_access/profile/domain/profile_models.dart';
import 'package:customer_app/features/m01_access/profile/presentation/profile_pages.dart';
import 'package:customer_app/features/ui_foundation/presentation/foundation_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _testApp(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: child,
  );
}

void main() {
  group('ProfileFormatters', () {
    test('formats phone number in groups of 3', () {
      expect(ProfileFormatters.formatPhone('987654321'), '987 654 321');
      expect(ProfileFormatters.formatPhone('98765'), '987 65');
      expect(ProfileFormatters.formatPhone('987'), '987');
      expect(ProfileFormatters.formatPhone(''), '');
    });

    test('formats card number in groups of 4', () {
      expect(ProfileFormatters.formatCardNumber('4557123456789012'), '4557 1234 5678 9012');
      expect(ProfileFormatters.formatCardNumber('45571234'), '4557 1234');
      expect(ProfileFormatters.formatCardNumber(''), '');
    });

    test('CardExpiryTextInputFormatter automatically places slash and limits to 4 digits', () {
      final CardExpiryTextInputFormatter formatter = CardExpiryTextInputFormatter();
      // Typing 1 digit
      var result = formatter.formatEditUpdate(
        const TextEditingValue(text: ''),
        const TextEditingValue(text: '1'),
      );
      expect(result.text, '1');

      // Typing 2nd digit -> auto slash
      result = formatter.formatEditUpdate(
        const TextEditingValue(text: '1'),
        const TextEditingValue(text: '12'),
      );
      expect(result.text, '12/');

      // Typing month and year digits
      result = formatter.formatEditUpdate(
        const TextEditingValue(text: '12/'),
        const TextEditingValue(text: '12/28'),
      );
      expect(result.text, '12/28');

      // Attempting to type more than 4 digits -> strictly capped
      result = formatter.formatEditUpdate(
        const TextEditingValue(text: '12/28'),
        const TextEditingValue(text: '12/2899'),
      );
      expect(result.text, '12/28');

      // Backspacing across slash
      result = formatter.formatEditUpdate(
        const TextEditingValue(text: '12/'),
        const TextEditingValue(text: '12'),
      );
      expect(result.text, '1');
    });

    test('DateTextInputFormatter automatically places slashes and limits to 8 digits', () {
      final DateTextInputFormatter formatter = DateTextInputFormatter();
      var result = formatter.formatEditUpdate(
        const TextEditingValue(text: '1'),
        const TextEditingValue(text: '15'),
      );
      expect(result.text, '15/');

      result = formatter.formatEditUpdate(
        const TextEditingValue(text: '15/0'),
        const TextEditingValue(text: '15/08'),
      );
      expect(result.text, '15/08/');

      result = formatter.formatEditUpdate(
        const TextEditingValue(text: '15/08/'),
        const TextEditingValue(text: '15/08/1995'),
      );
      expect(result.text, '15/08/1995');

      // Attempting to type more than 8 digits
      result = formatter.formatEditUpdate(
        const TextEditingValue(text: '15/08/1995'),
        const TextEditingValue(text: '15/08/199599'),
      );
      expect(result.text, '15/08/1995');
    });
  });

  group('ProfileValidators', () {
    test('phone validator validates 9-digit Peruvian cellphones starting with 9', () {
      expect(ProfileValidators.phone(null), isNotNull);
      expect(ProfileValidators.phone(''), isNotNull);
      expect(ProfileValidators.phone('123456789'), isNotNull); // Doesn't start with 9
      expect(ProfileValidators.phone('98765432'), isNotNull); // 8 digits
      expect(ProfileValidators.phone('9876543210'), isNotNull); // 10 digits
      expect(ProfileValidators.phone('98765432a'), isNotNull); // non-digit
      expect(ProfileValidators.phone('987654321'), isNull); // Valid
      expect(ProfileValidators.phone(' 987 654 321 '), isNull); // Valid with spacing
    });

    test('cardNumber validator requires exact 16 numeric digits', () {
      expect(ProfileValidators.cardNumber(null), isNotNull);
      expect(ProfileValidators.cardNumber(''), isNotNull);
      expect(ProfileValidators.cardNumber('123456781234567'), isNotNull); // 15
      expect(ProfileValidators.cardNumber('12345678123456789'), isNotNull); // 17
      expect(ProfileValidators.cardNumber('1234567812345678'), isNull); // 16
      expect(ProfileValidators.cardNumber('1234 5678 1234 5678'), isNull); // 16 with spaces
    });

    test('cardExpiry validator enforces MM/AA format', () {
      expect(ProfileValidators.cardExpiry(null), isNotNull);
      expect(ProfileValidators.cardExpiry(''), isNotNull);
      expect(ProfileValidators.cardExpiry('13/26'), isNotNull); // Month > 12
      expect(ProfileValidators.cardExpiry('00/26'), isNotNull); // Month 00
      expect(ProfileValidators.cardExpiry('1226'), isNotNull); // Missing slash
      expect(ProfileValidators.cardExpiry('12/28'), isNull); // Valid
      expect(ProfileValidators.cardExpiry('05/30'), isNull); // Valid
    });

    test('cardCvv validator enforces 3 or 4 digits', () {
      expect(ProfileValidators.cardCvv(null), isNotNull);
      expect(ProfileValidators.cardCvv('12'), isNotNull);
      expect(ProfileValidators.cardCvv('12345'), isNotNull);
      expect(ProfileValidators.cardCvv('123'), isNull);
      expect(ProfileValidators.cardCvv('1234'), isNull);
    });

    test('address and label validators require non-empty content', () {
      expect(ProfileValidators.address(null), isNotNull);
      expect(ProfileValidators.address('   '), isNotNull);
      expect(ProfileValidators.address('Av. Arequipa 500'), isNull);

      expect(ProfileValidators.addressLabel(null), isNotNull);
      expect(ProfileValidators.addressLabel('   '), isNotNull);
      expect(ProfileValidators.addressLabel('Casa'), isNull);
    });
  });

  group('UserProfileController', () {
    test('initializes with defaults and updates state correctly', () {
      final controller = UserProfileController(
        initialDisplayName: 'Juan',
        initialLastName: 'Perez',
        initialPhone: '987654321',
      );

      expect(controller.displayName, 'Juan');
      expect(controller.lastName, 'Perez');
      expect(controller.phone, '987654321');
      expect(controller.addresses, isNotEmpty);
      expect(controller.cards, isNotEmpty);

      controller.updateProfile(
        displayName: 'Carlos',
        lastName: 'Quispe',
        phone: '912345678',
        avatarPath: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300',
        birthDate: '10/05/1990',
        dietaryPreferences: 'Sin picante',
      );
      expect(controller.displayName, 'Carlos');
      expect(controller.lastName, 'Quispe');
      expect(controller.phone, '912345678');
      expect(controller.avatarPath, contains('unsplash'));
      expect(controller.birthDate, '10/05/1990');
      expect(controller.dietaryPreferences, 'Sin picante');

      final initialAddressCount = controller.addresses.length;
      controller.addAddress(
        label: 'Oficina',
        address: 'Calle Los Pinos 456',
        department: '302',
        reference: 'Piso 3',
        isDefault: true,
      );
      expect(controller.addresses.length, initialAddressCount + 1);
      expect(controller.addresses.last.label, 'Oficina');
      expect(controller.addresses.last.fullText, 'Calle Los Pinos 456, Dpto 302 (Piso 3)');

      final addedId = controller.addresses.last.id;
      controller.removeAddress(addedId);
      expect(controller.addresses.length, initialAddressCount);

      final initialCardCount = controller.cards.length;
      controller.addCard(
        rawCardNumber: '4557123456789999',
        cardHolder: 'Carlos Quispe',
        expiry: '08/29',
        cvv: '123',
        documentType: 'DNI',
        documentNumber: '71234567',
      );
      expect(controller.cards.length, initialCardCount + 1);
      expect(controller.cards.last.brand, 'Visa');
      expect(controller.cards.last.cardNumberMasked, '•••• •••• •••• 9999');
      expect(controller.cards.last.documentType, 'DNI');

      controller.setTabIndex(2);
      expect(controller.selectedTabIndex, 2);
    });

    test('clear resets all in-memory fields', () {
      final controller = UserProfileController(
        initialDisplayName: 'Juan',
        initialLastName: 'Perez',
        initialPhone: '987654321',
        initialAvatarPath: 'path/to/img.png',
      );
      expect(controller.displayName, 'Juan');
      expect(controller.avatarPath, 'path/to/img.png');

      controller.clear();

      expect(controller.displayName, isNull);
      expect(controller.lastName, isNull);
      expect(controller.phone, isNull);
      expect(controller.avatarPath, isNull);
      expect(controller.addresses, isEmpty);
      expect(controller.cards, isEmpty);
    });

    test('loadForUser with null or empty userId clears profile without loading storage', () async {
      final controller = UserProfileController(
        initialDisplayName: 'Juan',
        initialPhone: '987654321',
        initialAvatarPath: 'path/to/img.png',
      );

      await controller.loadForUser(null);

      expect(controller.displayName, isNull);
      expect(controller.phone, isNull);
      expect(controller.avatarPath, isNull);
      expect(controller.addresses, isEmpty);
      expect(controller.cards, isEmpty);
    });
  });

  group('Profile Full Pages', () {
    testWidgets('EditProfilePage validates, allows photo selection and updates controller', (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = UserProfileController(
        initialDisplayName: 'Juan',
        initialLastName: 'Perez',
        initialPhone: '987654321',
      );
      final themeModeController = ThemeModeController();

      await tester.pumpWidget(
        _testApp(
          EditProfilePage(
            themeModeController: themeModeController,
            controller: controller,
            currentDisplayName: 'Juan Perez',
            currentEmail: 'juan@correo.com',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('page-edit-profile')), findsOneWidget);
      expect(find.byKey(const Key('edit-profile-name')), findsOneWidget);
      expect(find.byKey(const Key('edit-profile-phone')), findsOneWidget);

      // Open photo selector
      await tester.tap(find.byKey(const Key('upload-photo-action')));
      await tester.pumpAndSettle();

      // Tap sample photo 0
      expect(find.byKey(const Key('sample-photo-0')), findsOneWidget);
      await tester.tap(find.byKey(const Key('sample-photo-0')));
      await tester.pumpAndSettle();

      // Or enter custom URL
      await tester.enterText(
        find.byKey(const Key('photo-url-input')),
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300',
      );
      await tester.tap(find.byKey(const Key('apply-photo-url-button')));
      await tester.pumpAndSettle();

      // Enter invalid phone
      await tester.enterText(find.byKey(const Key('edit-profile-phone')), '812345678');
      await tester.ensureVisible(find.byKey(const Key('edit-profile-save-button')));
      await tester.tap(find.byKey(const Key('edit-profile-save-button')));
      await tester.pumpAndSettle();

      expect(find.text('El número de celular debe comenzar con 9.'), findsOneWidget);

      // Enter valid phone & extra data
      await tester.enterText(find.byKey(const Key('edit-profile-phone')), '999888777');
      await tester.enterText(find.byKey(const Key('edit-profile-name')), 'Juan Carlos');
      await tester.enterText(find.byKey(const Key('edit-profile-lastname')), 'Perez Chang');
      await tester.enterText(find.byKey(const Key('edit-profile-birthdate')), '12/04/1992');
      await tester.enterText(find.byKey(const Key('edit-profile-dietary')), 'Sin cebolla china');

      await tester.ensureVisible(find.byKey(const Key('edit-profile-save-button')));
      await tester.tap(find.byKey(const Key('edit-profile-save-button')));
      await tester.pumpAndSettle();

      expect(controller.displayName, 'Juan Carlos');
      expect(controller.lastName, 'Perez Chang');
      expect(controller.phone, '999888777');
      expect(controller.birthDate, '12/04/1992');
      expect(controller.dietaryPreferences, 'Sin cebolla china');
      expect(controller.avatarPath, contains('unsplash'));
    });

    testWidgets('AddAddressPage validates, selects chip and adds address', (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = UserProfileController();
      final themeModeController = ThemeModeController();

      await tester.pumpWidget(
        _testApp(
          AddAddressPage(
            themeModeController: themeModeController,
            controller: controller,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('page-add-address')), findsOneWidget);

      // Select 'Trabajo' chip
      await tester.tap(find.byKey(const Key('address-type-chip-Trabajo')));
      await tester.pumpAndSettle();

      // Submit empty
      await tester.ensureVisible(find.byKey(const Key('save-address-button')));
      await tester.tap(find.byKey(const Key('save-address-button')));
      await tester.pumpAndSettle();

      expect(find.text('Ingresa la dirección (calle, número o urbanización).'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('address-text-input')), 'Av. Conquistadores 100');
      await tester.enterText(find.byKey(const Key('address-dept-input')), 'Oficina 501');
      await tester.enterText(find.byKey(const Key('address-reference-input')), 'Frente a la plaza');

      // Toggle default switch
      await tester.ensureVisible(find.byKey(const Key('address-default-switch')));
      await tester.tap(find.byKey(const Key('address-default-switch')));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('save-address-button')));
      await tester.tap(find.byKey(const Key('save-address-button')));
      await tester.pumpAndSettle();

      expect(controller.addresses.any((a) => a.label == 'Trabajo' && a.department == 'Oficina 501'), isTrue);
    });

    testWidgets('AddCardPage renders live preview, validates and saves card', (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = UserProfileController();
      final themeModeController = ThemeModeController();

      await tester.pumpWidget(
        _testApp(
          AddCardPage(
            themeModeController: themeModeController,
            controller: controller,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('page-add-card')), findsOneWidget);

      // Enter card details and observe live update
      await tester.enterText(find.byKey(const Key('card-number-input')), '45571234');
      await tester.pump();
      expect(find.textContaining('VISA'), findsOneWidget);

      // Submit incomplete
      await tester.ensureVisible(find.byKey(const Key('save-card-button')));
      await tester.tap(find.byKey(const Key('save-card-button')));
      await tester.pumpAndSettle();

      expect(find.text('La tarjeta debe tener exactamente 16 dígitos (ingresaste 8).'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('card-number-input')), '5123456789012345');
      await tester.enterText(find.byKey(const Key('card-holder-input')), 'Maria Lopez');
      await tester.enterText(find.byKey(const Key('card-expiry-input')), '11/27');
      await tester.enterText(find.byKey(const Key('card-cvv-input')), '456');
      await tester.enterText(find.byKey(const Key('card-doc-number-input')), '44556677');

      await tester.ensureVisible(find.byKey(const Key('save-card-button')));
      await tester.tap(find.byKey(const Key('save-card-button')));
      await tester.pumpAndSettle();

      expect(controller.cards.any((c) => c.brand == 'Mastercard'), isTrue);
    });

    testWidgets('FoundationAccountPage navigates to full pages on action tap', (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = UserProfileController(
        initialDisplayName: 'Pedro Pascal',
        initialPhone: '955444333',
        initialAvatarPath: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300',
      );
      final themeModeController = ThemeModeController();

      await tester.pumpWidget(
        _testApp(
          FoundationAccountPage(
            themeModeController: themeModeController,
            isGuest: false,
            displayName: 'Pedro Pascal',
            email: 'pedro@correo.com',
            profileController: controller,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify photo avatar is rendered
      expect(find.byKey(const Key('account-edit-profile-action')), findsOneWidget);

      // Tap 'Editar perfil' -> opens full EditProfilePage
      await tester.tap(find.byKey(const Key('account-edit-profile-action')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('page-edit-profile')), findsOneWidget);

      // Pop back
      await tester.tap(find.byKey(const Key('header-back-button')));
      await tester.pumpAndSettle();

      // Go to tab 1: Direcciones -> opens addresses page
      await tester.tap(find.byKey(const Key('profile-tab-1')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('page-addresses')), findsOneWidget);

      // Tap '+ Agregar dirección' -> opens full AddAddressPage
      await tester.tap(find.byKey(const Key('account-add-address-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('page-add-address')), findsOneWidget);

      // Pop back from AddAddressPage to addresses page
      await tester.tap(find.byKey(const Key('header-back-button')));
      await tester.pumpAndSettle();

      // Pop back from addresses page to Account page
      await tester.tap(find.byKey(const Key('header-back-button')));
      await tester.pumpAndSettle();

      // Go to tab 2: Tarjetas -> opens cards page
      await tester.tap(find.byKey(const Key('profile-tab-2')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('page-cards')), findsOneWidget);

      // Tap '+ Agregar tarjeta' -> opens full AddCardPage
      await tester.tap(find.byKey(const Key('account-add-card-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('page-add-card')), findsOneWidget);

      // Pop back from AddCardPage to cards page
      await tester.tap(find.byKey(const Key('header-back-button')));
      await tester.pumpAndSettle();

      // Pop back from cards page to Account page
      await tester.tap(find.byKey(const Key('header-back-button')));
      await tester.pumpAndSettle();

      // Tap on avatar -> opens WhatsApp-style photo viewer
      await tester.tap(find.byKey(const Key('account-avatar-touchable')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('page-photo-viewer')), findsOneWidget);
      expect(find.byKey(const Key('photo-viewer-back')), findsOneWidget);

      // Pop back from photo viewer
      await tester.tap(find.byKey(const Key('photo-viewer-back')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('page-photo-viewer')), findsNothing);
    });

    testWidgets('FoundationAccountPage in guest mode isolates profile data', (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = UserProfileController(
        initialDisplayName: 'Pedro Pascal',
        initialPhone: '955444333',
        initialAvatarPath: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300',
      );
      final themeModeController = ThemeModeController();

      await tester.pumpWidget(
        _testApp(
          FoundationAccountPage(
            themeModeController: themeModeController,
            isGuest: true,
            displayName: null,
            email: null,
            profileController: controller,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Invitado'), findsOneWidget);
      expect(find.text('SESIÓN DE INVITADO'), findsOneWidget);
      expect(find.text('CUENTA REGISTRADA'), findsNothing);
      expect(find.byKey(const Key('account-phone-card')), findsNothing);
      expect(find.byKey(const Key('guest-account-empty-state')), findsOneWidget);
    });

    testWidgets('AddAddressPage edits existing address correctly', (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = UserProfileController(
        initialAddresses: <CustomerAddress>[
          const CustomerAddress(
            id: 'addr-edit-1',
            label: 'Casa',
            address: 'Calle Antigua 123',
            department: '101',
            reference: 'Cerca al parque',
            isDefault: false,
          ),
        ],
      );
      final themeModeController = ThemeModeController();

      await tester.pumpWidget(
        _testApp(
          AddAddressPage(
            themeModeController: themeModeController,
            controller: controller,
            existingAddress: controller.addresses.first,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Editar dirección'), findsOneWidget);
      expect(find.text('Guardar cambios'), findsOneWidget);
      expect(find.text('Calle Antigua 123'), findsOneWidget);

      // Modify address
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Calle Antigua 123'),
        'Calle Nueva y Modificada 999',
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('save-address-button')));
      await tester.tap(find.byKey(const Key('save-address-button')));
      await tester.pumpAndSettle();

      expect(controller.addresses.first.address, 'Calle Nueva y Modificada 999');
    });

    testWidgets('AddCardPage edits existing card correctly', (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = UserProfileController(
        initialCards: <SavedPaymentCard>[
          const SavedPaymentCard(
            id: 'card-edit-1',
            cardNumberMasked: '•••• •••• •••• 8888',
            cardHolder: 'JUAN VALDEZ',
            expiry: '11/27',
            brand: 'Visa',
          ),
        ],
      );
      final themeModeController = ThemeModeController();

      await tester.pumpWidget(
        _testApp(
          AddCardPage(
            themeModeController: themeModeController,
            controller: controller,
            existingCard: controller.cards.first,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Editar tarjeta'), findsOneWidget);
      expect(find.text('Guardar cambios'), findsOneWidget);
      expect(find.byKey(const Key('card-holder-input')), findsOneWidget);

      // Modify card holder
      await tester.enterText(
        find.byKey(const Key('card-holder-input')),
        'JUAN PABLO VALDEZ',
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('save-card-button')));
      await tester.tap(find.byKey(const Key('save-card-button')));
      await tester.pumpAndSettle();

      expect(controller.cards.first.cardHolder, 'JUAN PABLO VALDEZ');
    });

    testWidgets('ProfilePhotoViewerPage renders WhatsApp-style viewer and responds to tap overlay', (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final themeModeController = ThemeModeController();

      await tester.pumpWidget(
        _testApp(
          ProfilePhotoViewerPage(
            themeModeController: themeModeController,
            avatarPath: null,
            displayName: 'Carlos Chef',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('page-photo-viewer')), findsOneWidget);
      expect(find.byKey(const Key('photo-viewer-placeholder')), findsOneWidget);
      expect(find.text('Carlos Chef'), findsOneWidget);
      expect(find.byKey(const Key('photo-viewer-back')), findsOneWidget);

      // Tap screen -> toggles overlay (app bar hides)
      await tester.tap(find.byKey(const Key('page-photo-viewer')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('photo-viewer-back')), findsNothing);

      // Tap screen again -> overlay reappears
      await tester.tap(find.byKey(const Key('page-photo-viewer')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('photo-viewer-back')), findsOneWidget);
    });
  });
}
