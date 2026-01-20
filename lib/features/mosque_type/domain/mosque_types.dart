import 'mosque_type.dart';

class MosqueTypes {
  static const musalla = MosqueType(
    id: 'musalla',
    nameAr: 'مصلى (مستوى أول)',
    descriptionAr: '''
السعة المستهدفة: 80 - 100 مصلٍ
المساحة الإجمالية التقريبية: 138م²
القبة: لا يوجد
المئذنة: عدد 1 بارتفاع 15,00م
الارتفاع الصافي: 5م
''',
    imageUrl: 'assets/images/musalla.jpeg',
  );

  static const small = MosqueType(
    id: 'small',
    nameAr: 'مسجد صغير (مستوى ثاني)',
    descriptionAr: '''
السعة المستهدفة: 250 - 300 مصلٍ
المساحة الإجمالية التقريبية: 450 - 650م²
القبة: عدد 1 بارتفاع 4,00م
المئذنة: عدد ١ بارتفاع 20,00م
الارتفاع الصافي: 8,00م
''',
    imageUrl: 'assets/images/small.jpg',
  );

  static const medium = MosqueType(
    id: 'medium',
    nameAr: 'مسجد متوسط (مستوى ثالث)',
    descriptionAr: '''
السعة المستهدفة: 500 - 700 مصلٍ
المساحة الإجمالية التقريبية: 1000 - 1200م²
القبة: عدد 1 بارتفاع 8,00 - 10,00م
المئذنة: عدد ١ بارتفاع 21,00م 
الارتفاع الصافي: 5,50 - 6,00م
''',
    imageUrl: 'assets/images/medium.jpg',
  );

  static const large = MosqueType(
    id: 'large',
    nameAr: 'مسجد كبير (مستوى رابع)',
    descriptionAr: '''
السعة المستهدفة: 1200 - 1500 مصلٍ
المساحة الإجمالية التقريبية: 1100 - 1500م²
القبة: عدد 1 بارتفاع 20,00م
المئذنة: عدد ١ بارتفاع 27,00م 
الارتفاع الصافي: 9,00م
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