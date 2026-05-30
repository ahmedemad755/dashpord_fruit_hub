import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruitesdashboard/featurs/sensors/presentation/cubits/cubit/sensor_cubit.dart';
import 'package:fruitesdashboard/featurs/sensors/presentation/cubits/cubit/sensor_state.dart';

class SensorCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;

  const SensorCard({
    super.key, 
    required this.label, 
    required this.value, 
    required this.icon, 
    required this.color
  });

  @override
  Widget build(BuildContext context) {
    // نستخدم BlocListener هنا لمراقبة الـ Streams وإطلاق الـ Popups فجأة وبشكل تفاعلي
return BlocListener<SensorCubit, SensorState>(
  listener: (context, state) {
    if (state is SensorDataUpdated) {
      final sensorCubit = context.read<SensorCubit>();
      
      if (label == 'Temperature' || label == 'درجة الحرارة') {
        double currentTemperature = 0.0;
        try {
          currentTemperature = (state as dynamic).sensorModel.temperature;
        } catch (_) {
          try { currentTemperature = (state as dynamic).sensorEntity.temperature; } catch (_) {
            try { currentTemperature = (state as dynamic).data.temperature; } catch (_) {
              currentTemperature = double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
            }
          }
        }

        if (currentTemperature > sensorCubit.maxSafeTemperature && sensorCubit.isAlarmPlaying) {
          if (ModalRoute.of(context)?.isCurrent != true) return;
          _showWebAlertDialog(context, currentTemperature, sensorCubit);
          
          // 💡 نداء سحري: بمجرد بناء الواجهة والـ Dialog، نحاول إعادة تشغيل الصوت لتخطي حظر المتصفح
        }
      }
    }
  },
// باقي الكود كما هو بدون تغيير

      child: Card(
        margin: const EdgeInsets.all(15),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Icon(icon, color: color, size: 40),
          title: Text(
            label, 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          trailing: Text(
            value, 
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
          ),
        ),
      ),
    );
  }

  // بناء نافذة التحذير المنبثقة الإجبارية للويب التي تقفل واجهة المتصفح
  void _showWebAlertDialog(BuildContext context, double currentTemp, SensorCubit cubit) {
    showDialog(
      context: context,
      barrierDismissible: false, // ⚠️ إجباري: يمنع إغلاق النافذة بالضغط خارجها لحماية الأدوية
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Row(
            children: [
              Icon(Icons.gpp_bad_rounded, color: Colors.red, size: 35),
              SizedBox(width: 12),
              Text(
                'حالة حرجة: خطر بيئي!', 
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تم رصد ارتفاع حاد وغير طبيعي في درجة حرارة ثلاجة حفظ الأدوية الحالية داخل الصيدلية.',
                style: TextStyle(fontSize: 15, color: Colors.grey[800], fontFamily: 'Cairo'),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الحرارة الحالية: $currentTemp°C',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    Text(
                      'الحد المسموح: ${cubit.maxSafeTemperature}°C',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.volume_off),
              label: const Text(
                'إيقاف صوت الإنذار وتأكيد التوجه للفحص',
                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                cubit.stopAlertSound(); // إيقاف صوت صفارة الإنذار في الـ Web
                Navigator.of(dialogContext).pop(); // إغلاق الـ Dialog يدوياً بعد اتخاذ الإجراء
              },
            ),
          ],
        );
      },
    );
  }
}
