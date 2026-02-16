import 'package:flutter/material.dart';

void showTermsAndConditionsDialog(
  BuildContext context,
  void Function(bool) onAccept,
) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("الشروط والأحكام"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "• يتم استخدام بياناتك الشخصية فقط لتوصيل الطلبات وتحسين جودة الخدمة.",
              ),
              SizedBox(height: 10),
              Text(
                "• يجب إدخال بيانات صحيحة ومحدثة مثل الاسم، العنوان، ورقم الهاتف.",
              ),
              SizedBox(height: 10),
              Text(
                "• الأسعار المعروضة قابلة للتغيير دون إشعار مسبق حسب السوق أو العروض الترويجية.",
              ),
              SizedBox(height: 10),
              Text(
                "• لا يجوز استخدام التطبيق لأغراض تجارية أو إعادة البيع دون تصريح رسمي.",
              ),
              SizedBox(height: 10),
              Text(
                "• الطلبات تعتمد على توفر المنتجات وقد يتم إلغاء الطلب في حالة نفاد المخزون.",
              ),
              SizedBox(height: 10),
              Text(
                "• وقت التوصيل تقديري وقد يتأثر بعوامل خارجة عن الإرادة مثل الطقس أو الضغط على الخدمة.",
              ),
              SizedBox(height: 10),
              Text(
                "• يجب التأكد من توفر العميل في العنوان المحدد أثناء وقت التوصيل.",
              ),
              SizedBox(height: 10),
              Text(
                "• يتم قبول الدفع نقدًا عند الاستلام أو من خلال وسائل الدفع المتاحة داخل التطبيق.",
              ),
              SizedBox(height: 10),
              Text(
                "• في حال وجود مشكلة في الطلب (مثل تلف المنتجات)، يجب الإبلاغ خلال 24 ساعة من الاستلام.",
              ),
              SizedBox(height: 10),
              Text(
                "• سياسة الإرجاع تشمل فقط المنتجات التالفة أو غير المطابقة، مع إثبات الحالة.",
              ),
              SizedBox(height: 10),
              Text(
                "• لا يتحمل التطبيق مسؤولية أي استخدام غير مصرح به لحسابك الشخصي.",
              ),
              SizedBox(height: 10),
              Text(
                "• يحق لإدارة التطبيق تعليق أو حذف الحسابات المخالفة دون إشعار.",
              ),
              SizedBox(height: 10),
              Text(
                "• باستخدامك للتطبيق، فإنك توافق تلقائيًا على أي تعديلات مستقبلية في هذه الشروط.",
              ),
              SizedBox(height: 10),
              Text(
                "• تحتفظ إدارة التطبيق بحق إلغاء أو تعديل أي طلب دون إبداء أسباب.",
              ),
              SizedBox(height: 10),
              Text(
                "• لا يتم تقديم ضمانات على جودة الفواكه والخضار بعد الاستلام بسبب طبيعتها القابلة للتلف.",
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onAccept(false);
            },
            child: Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () {
              // المستخدم وافق
              Navigator.pop(context);
              onAccept(true);
              // تابع إنشاء الحساب
            },
            child: Text("أوافق"),
          ),
        ],
      );
    },
  );
}
