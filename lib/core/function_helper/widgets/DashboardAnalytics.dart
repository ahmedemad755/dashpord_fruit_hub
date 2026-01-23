import 'package:flutter/material.dart';

class DashboardAnalytics extends StatelessWidget {
  const DashboardAnalytics({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pharmacy Analytics Dashboard'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Overview",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _analyticsCard(
                  title: "Total Products",
                  value: "120",
                  icon: Icons.inventory_2,
                  color: Colors.orange,
                ),
                _analyticsCard(
                  title: "Daily Sales",
                  value: "\$1,250",
                  icon: Icons.sell,
                  color: Colors.green,
                ),
                _analyticsCard(
                  title: "Units Sold",
                  value: "350",
                  icon: Icons.shopping_cart,
                  color: Colors.blue,
                ),
                _analyticsCard(
                  title: "Low Stock",
                  value: "15",
                  icon: Icons.warning_amber_rounded,
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "Top Products",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                _topProductItem("Panadol", "50 sold", Icons.medical_services, Colors.teal),
                _topProductItem("Betaderm", "30 sold", Icons.medication, Colors.purple),
                _topProductItem("Vitamin C", "25 sold", Icons.local_hospital, Colors.amber),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "Recent Reviews",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                _reviewItem("Ahmed E.", "Great product!", 5),
                _reviewItem("Mona S.", "Fast delivery", 4),
                _reviewItem("Omar A.", "Well packed", 5),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _analyticsCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 14, color: color.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  Widget _topProductItem(String name, String sold, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(sold, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _reviewItem(String user, String review, int stars) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(user, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Row(
          children: [
            ...List.generate(stars, (index) => const Icon(Icons.star, color: Colors.amber, size: 16)),
            ...List.generate(5 - stars, (index) => const Icon(Icons.star_border, color: Colors.grey, size: 16)),
            const SizedBox(width: 8),
            Text(review),
          ],
        ),
      ),
    );
  }
}
