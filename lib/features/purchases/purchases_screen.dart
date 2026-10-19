import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/models/pet_character.dart';
import '../../core/models/player_profile.dart';
import '../../core/services/game_engine.dart';
import '../../core/services/storage_service.dart';
import '../../data/content/shop_items.dart';
import '../../widgets/feedback_card.dart';

/// Экран покупок (требование 8.6).
/// Каталог товаров с ценой, категорией, влиянием на питомца.
/// Подтверждение покупки, уменьшение баланса, обработка нехватки средств.
class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  late PlayerProfile _profile;
  int _tabIndex = 0; // 0 = обязательные, 1 = необязательные

  /// Последнее действие — для показа FeedbackCard (8.9).
  FeedbackCard? _lastFeedback;

  @override
  void initState() {
    super.initState();
    _profile = StorageService().activeProfile ??
        PlayerProfile.create(
          playerName: 'Гость',
          character: PetCharacter.gapTooth,
        );
  }

  void _showPurchaseDialog(ShopItem item) {
    final canAfford = _profile.balance >= item.price;
    final balanceBefore = _profile.balance;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Text(item.emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(child: Text(item.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Цена', '${item.price} 🪙'),
            _infoRow('Категория', item.type == ShopItemType.required ? 'Обязательная' : 'Необязательная'),
            _infoRow('Влияние на питомца', item.effectOnPet),
            const SizedBox(height: 12),
            if (!canAfford) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
                ),
                child: Row(children: [
                  const Text('⚠️', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                    'Не хватает ${item.price - _profile.balance} 🪙',
                    style: TextStyle(fontSize: 13, color: AppTheme.error),
                  )),
                ]),
              ),
              const SizedBox(height: 8),
              Text(
                'Варианты: выполни задание (+20 🪙) или подожди бонус за вход (+10 🪙).',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Отмена', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          FilledButton(
            onPressed: canAfford ? () {
              final ok = GameEngine().purchase(
                _profile,
                itemName: item.name,
                price: item.price,
                isRequired: item.type == ShopItemType.required,
                effectOnPet: item.effectOnPet,
              );
              Navigator.pop(ctx);
              if (ok && mounted) {
                setState(() {
                  _lastFeedback = FeedbackCard(
                    type: FeedbackType.success,
                    title: 'Куплено: ${item.name}!',
                    changedItems: [
                      'Баланс: −${item.price} 🪙 (осталось ${_profile.balance})',
                      if (item.effectOnPet.isNotEmpty) item.effectOnPet,
                    ],
                    explanation: item.type == ShopItemType.required
                        ? 'Обязательная покупка — питомец стал счастливее. Такие траты поддерживают его состояние.'
                        : 'Необязательная покупка — питомец рад, но это не влияет на его базовое состояние.',
                    nextStep: 'Проверь баланс на главном экране или выполни задание, чтобы заработать ещё 🪙',
                  );
                });
              }
            } : null,
            style: FilledButton.styleFrom(
              backgroundColor: canAfford ? AppTheme.primary : null,
              foregroundColor: Colors.white,
            ),
            child: Text('Купить за ${item.price} 🪙', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = ShopCatalog.forCharacter(_profile.character);
    final requiredItems = items.where((i) => i.type == ShopItemType.required).toList();
    final optionalItems = items.where((i) => i.type == ShopItemType.optional).toList();
    final currentItems = _tabIndex == 0 ? requiredItems : optionalItems;

    return Scaffold(
      appBar: AppBar(title: const Text('Магазин')),
      body: Column(
        children: [
          // Баланс
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Баланс: ${_profile.balance} 🪙', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              ],
            ),
          ),

          // FeedbackCard после покупки (8.9)
          if (_lastFeedback != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _lastFeedback!,
            ),

          // Табы
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  _tab('Обязательные', 0),
                  _tab('Необязательные', 1),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Список товаров
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: currentItems.length,
              itemBuilder: (context, i) => _itemCard(currentItems[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(String label, int index) {
    final selected = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : AppTheme.textSecondary)),
        ),
      ),
    );
  }

  Widget _itemCard(ShopItem item) {
    final canAfford = _profile.balance >= item.price;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: (item.type == ShopItemType.required ? AppTheme.accent : AppTheme.primary).withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: (item.type == ShopItemType.required ? AppTheme.accent : AppTheme.primary).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.center,
            child: Text(item.emoji, style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                const SizedBox(height: 4),
                Text(item.effectOnPet, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${item.price} 🪙', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: canAfford ? AppTheme.textPrimary : AppTheme.error)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => _showPurchaseDialog(item),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: canAfford ? AppTheme.primary : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Купить', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: canAfford ? Colors.white : AppTheme.textSecondary)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary))),
          Expanded(child: Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary))),
        ],
      ),
    );
  }
}
