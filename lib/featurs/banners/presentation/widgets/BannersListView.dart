import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruitesdashboard/featurs/banners/manger/cubit/banners_cubit.dart';
import 'package:fruitesdashboard/featurs/data/entity/BannerEntity.dart';

class BannersListView extends StatelessWidget {
  const BannersListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BannersCubit, BannersState>(
      builder: (context, state) {
        if (state is GetBannersLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is GetBannersSuccess) {
          final banners = state.banners;

          if (banners.isEmpty) {
            return const Center(child: Text("لا توجد عروض منشورة حالياً"));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: banners.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final banner = banners[index];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey[200]!),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          banner.imageUrl,
                          width: 80,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              banner.linkType == 'none'
                                  ? "عرض فقط"
                                  : "ربط بـ ${banner.linkType}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              banner.isActive ? "نشط" : "متوقف",
                              style: TextStyle(
                                color: banner.isActive
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                        onPressed: () => _showDeleteDialog(context, banner),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }

        if (state is GetBannersFailure) {
          return Center(child: Text(state.errMessage));
        }

        return const SizedBox();
      },
    );
  }

  // دالة إظهار نافذة التأكيد
  void _showDeleteDialog(BuildContext context, BannerEntity banner) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text("تأكيد الحذف"),
          ],
        ),
        content: const Text(
          "هل أنت متأكد من حذف هذا العرض؟ سيتم حذفه من التطبيق ومن قاعدة البيانات نهائياً.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("إلغاء", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              context.read<BannersCubit>().deleteBanner(banner);
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("جاري الحذف...")));
            },
            child: const Text(
              "حذف الآن",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
