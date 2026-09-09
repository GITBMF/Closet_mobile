import 'package:closet/data/models/article.dart';
import 'package:closet/data/repositories/cart_repository.dart';
import 'package:closet/data/repositories/transaction_repository.dart';
import 'package:closet/features/transaction/transaction_flow_screen.dart';
import 'package:closet/features/transaction/transaction_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _robe = Article(
  id: '1',
  title: 'Robe Elégante Durable',
  description: '',
  brand: 'Maison Coco Chanel',
  size: 'M',
  material: 'soie',
  condition: 'excellent',
  price: 38500,
  imageUrls: const ['https://exemple/robe.jpg'],
);

DemandeTransaction _paiement({double montant = 42000}) => DemandeTransaction(
      type: TypeOperation.paiement,
      montant: montant,
      fraisLivraison: 3500,
      moyen: 'mtn_momo',
      compte: '690123456',
      beneficiaire: 'Aïcha N.',
    );

const _retrait = DemandeTransaction(
  type: TypeOperation.retrait,
  montant: 28875,
  moyen: 'orange_money',
  compte: '699000000',
  beneficiaire: 'Sourceur ClosET',
);

void main() {
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    container = ProviderContainer();
    await container.read(cartProvider.future);
  });

  tearDown(() => container.dispose());

  ExecuteurTransaction executeur() =>
      container.read(transactionExecuteurProvider);

  group('Paiement acheteuse', () {
    test('refuse une sélection vide sans appeler le serveur', () async {
      await expectLater(
        executeur()(_paiement(), null),
        throwsA(isA<TransactionRefusee>()),
      );
    });
  });

  group('Retrait sourceur', () {
    test('est refusé : l’API n’expose pas de déclenchement de virement',
        () async {
      await expectLater(
        executeur()(_retrait, null),
        throwsA(isA<TransactionRefusee>()),
      );
    });

    test("un retrait refusé n'entame pas la sélection de la cliente", () async {
      container.read(cartProvider.notifier).addArticle(_robe);

      await expectLater(
        executeur()(_retrait, null),
        throwsA(isA<TransactionRefusee>()),
      );

      expect(container.read(cartListProvider), hasLength(1));
    });
  });

  group('Masquage du compte', () {
    test('le reçu ne montre que les quatre derniers caractères', () {
      expect(_retrait.compteMasque, endsWith('0000'));
      expect(_retrait.compteMasque.contains('699'), isFalse);
    });
  });
}
