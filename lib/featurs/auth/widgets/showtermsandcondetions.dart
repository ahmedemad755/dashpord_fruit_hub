import 'package:flutter/material.dart';

void showTermsAndConditionsDialog(
  BuildContext context,
  void Function(bool) onAccept,
) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "اتفاقية شروط استخدام منصة PHarma Go",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "بصفتك ممثلاً قانونياً للصيدلية، فإن تسجيلك في المنصة يعني إقرارك بالبنود التالية:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                SizedBox(height: 15),
                _TermsBullet(
                  title: "صحة البيانات القانونية:",
                  content:
                      "تقر الصيدلية بأن جميع المستندات المرفوعة (رخصة مزاولة المهنة، السجل التجاري) صحيحة وسارية المفعول، وتتحمل المسؤولية القانونية الكاملة عن أي تزوير.",
                ),
                _TermsBullet(
                  title: "جودة المنتجات والمنشأ:",
                  content:
                      "تلتزم الصيدلية بتوفير أدوية ومنتجات طبية أصلية وغير منتهية الصلاحية، ومخزنة وفقاً لمعايير هيئة الدواء والجهات الرقابية المختصة.",
                ),
                _TermsBullet(
                  title: "دقة الأسعار:",
                  content:
                      "يجب أن تطابق الأسعار المدخلة في لوحة التحكم الأسعار الرسمية المعتمدة، مع الالتزام بتحديثها فور حدوث أي تغيير رسمي.",
                ),
                _TermsBullet(
                  title: "سرية بيانات المرضى:",
                  content:
                      "تتعهد الصيدلية بالحفاظ على خصوصية بيانات العملاء والوصفات الطبية المستلمة عبر المنصة وعدم مشاركتها مع أي طرف ثالث خارج إطار تنفيذ الطلب.",
                ),
                _TermsBullet(
                  title: "إدارة الطلبات:",
                  content:
                      "تلتزم الصيدلية بتحديث حالة الطلب (قبول، تحضير، توصيل) في الوقت الفعلي، وتتحمل مسؤولية أي تأخير غير مبرر يؤثر على سلامة المريض.",
                ),
                _TermsBullet(
                  title: "المنازعات والشكاوى:",
                  content:
                      "في حال وجود شكوى من العميل بشأن جودة المنتج، تلتزم الصيدلية بالتعاون الكامل مع إدارة المنصة لحل المشكلة وفقاً لسياسة الاستبدال والاسترجاع المعتمدة.",
                ),
                _TermsBullet(
                  title: "الرسوم والعمولات:",
                  content:
                      "تقر الصيدلية باطلاعها على نسب العمولات المستقطعة للمنصة وطريقة تسوية المبالغ المالية المحصلة إلكترونياً.",
                ),
                _TermsBullet(
                  title: "حق التعليق:",
                  content:
                      "يحق لإدارة المنصة إيقاف حساب الصيدلية فوراً في حال ثبوت مخالفة للمعايير الطبية أو الأخلاقية أو تلقي بلاغات متكررة من المستخدمين.",
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onAccept(false);
            },
            child: const Text("رفض", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onAccept(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text("أوافق على الشروط"),
          ),
        ],
      );
    },
  );
}

// Widget مساعد لجعل النص منسقاً بشكل أفضل
class _TermsBullet extends StatelessWidget {
  final String title;
  final String content;

  const _TermsBullet({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 13,
            height: 1.4,
          ),
          children: [
            TextSpan(
              text: "• $title ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: content),
          ],
        ),
      ),
    );
  }
}
