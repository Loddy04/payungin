import 'package:hive/hive.dart';

part 'gear_item.g.dart';

// Model Perlengkapan Hujan dengan typeId 2 sesuai Dokumen Final Bagian 8
@HiveType(typeId: 2)
class GearItem extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int quantity;

  @HiveField(2)
  bool isReady;

  GearItem({
    required this.name,
    this.quantity = 1,
    this.isReady = false,
  });

  // Enkapsulasi: menambah jumlah barang
  void increase() {
    quantity++;
    if (isInBox) {
      save();
    }
  }

  // Enkapsulasi: mengurangi jumlah barang dengan batas minimal 1
  void decrease() {
    if (quantity > 1) {
      quantity--;
      if (isInBox) {
        save();
      }
    }
  }
}

