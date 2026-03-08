import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fruitesdashboard/core/utils/app_colors.dart';

class EditProductView extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> initialData;
  const EditProductView({
    super.key,
    required this.productId,
    required this.initialData,
  });

  @override
  State<EditProductView> createState() => _EditProductViewState();
}

class _EditProductViewState extends State<EditProductView> {
  late TextEditingController nameController,
      priceController,
      costController,
      amountController;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialData['name']);
    priceController = TextEditingController(
      text: widget.initialData['price'].toString(),
    );
    costController = TextEditingController(
      text: (widget.initialData['cost'] ?? 0).toString(),
    );
    amountController = TextEditingController(
      text: (widget.initialData['unitAmount'] ?? 0).toString(),
    );

    // إضافة مستمعين لتحديث واجهة الربح عند تغيير الأسعار
    priceController.addListener(() => setState(() {}));
    costController.addListener(() => setState(() {}));
  }

  // حساب هامش الربح
  String get _profitMargin {
    double p = double.tryParse(priceController.text) ?? 0;
    double c = double.tryParse(costController.text) ?? 0;
    return (p - c).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("تحديث بيانات المنتج"), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("المعلومات الأساسية"),
            _buildField(
              nameController,
              "اسم المنتج",
              Icons.badge_outlined,
              isEnabled: false,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle("التسعير والمخزون"),
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    priceController,
                    "سعر البيع",
                    Icons.monetization_on_outlined,
                    isNumber: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildField(
                    costController,
                    "سعر التكلفة",
                    Icons.shopping_bag_outlined,
                    isNumber: true,
                    iconColor: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // بطاقة حساب الربح التلقائي
            _buildProfitCard(),
            const SizedBox(height: 24),
            _buildField(
              amountController,
              "الكمية الحالية",
              Icons.inventory_2_outlined,
              isNumber: true,
            ),
            const SizedBox(height: 40),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfitCard() {
    double profit = double.tryParse(_profitMargin) ?? 0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: profit >= 0 ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            profit >= 0 ? Icons.trending_up : Icons.trending_down,
            color: profit >= 0 ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            "هامش الربح المتوقع: $profit \$",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: profit >= 0 ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
    bool isEnabled = true,
    Color? iconColor,
  }) {
    return TextField(
      controller: controller,
      enabled: isEnabled,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: iconColor ?? AppColors.primaryColor),
        filled: !isEnabled,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: isUpdating ? null : _handleUpdate,
        child: isUpdating
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "حفظ التعديلات",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Future<void> _handleUpdate() async {
    setState(() => isUpdating = true);
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .update({
            'price': num.parse(priceController.text),
            'cost': num.parse(costController.text),
            'unitAmount': num.parse(amountController.text),
          });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("خطأ: $e")));
    } finally {
      if (mounted) setState(() => isUpdating = false);
    }
  }
}
