import 'mosque_type.dart';

class MosqueTypes {
  static const musalla = MosqueType(
    id: 'musalla',
    nameAr: 'مصلى (مستوى أول)',
    descriptionAr: '''
مصلى بمساحة تقريبية تبلغ 150 مترًا مربعًا، مع مئذنة بارتفاع 10 أمتار من فوق سطح المصلى، يخدم الأحياء الصغيرة وعابري السبيل على الطرقات.
''',
    imageUrl: 'assets/images/musalla.jpeg',
  );

  static const small = MosqueType(
    id: 'small',
    nameAr: 'مسجد صغير (مستوى ثاني)',
    descriptionAr: '''
مسجد صغير يجمع بين الوظيفة والجمال، بمساحة تتراوح بين 450 و650 مترًا مربعًا، ومئذنة بارتفاع 19 مترًا عن سطح الأرض، تُقام فيه صلوات الجمعة والجماعة، وحلقات التعليم وتحفيظ القرآن الكريم.
''',
    imageUrl: 'assets/images/small.jpg',
  );

  static const medium = MosqueType(
    id: 'medium',
    nameAr: 'مسجد متوسط (مستوى ثالث)',
    descriptionAr: '''
مسجد متوسط، صرح يخدم الأحياء الكبرى، بمساحة تتراوح بين 700 و1000 متر مربع، ويضم صحنًا ومكتبة، مع مئذنة بارتفاع 21 مترًا عن سطح الأرض، ليكون من أكثر المساجد اعتمادًا في خدمة المسلمين.
''',
    imageUrl: 'assets/images/medium.jpg',
  );

  static const large = MosqueType(
    id: 'large',
    nameAr: 'مسجد كبير (مستوى رابع)',
    descriptionAr: '''
المسجد الكبير، بمساحة بين 1100 و1500 متر مربع، ومئذنة بارتفاع 27 مترًا عن سطح الأرض، ويضم قاعات ومشاريع متعددة، ليكون بيئة حضارية ومعرفية حديثة تُكمّل رسالة المسجد.
''',
    imageUrl: 'assets/images/large.jpg',
  );

  static const expansion = MosqueType(
    id: 'expansion',
    nameAr: 'توسعة',
    descriptionAr: "",
    imageUrl: 'assets/images/expansion.JPG',
  );

  static const all = [musalla, small, medium, large, expansion];
}