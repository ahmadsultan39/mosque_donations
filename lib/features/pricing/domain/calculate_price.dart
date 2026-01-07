import 'package:mosque_donations/features/mosque_type/domain/mosque_types.dart';

import '../../mosque_type/domain/mosque_type.dart';
import 'form_models.dart';

double calculatePrice({
  required MosqueType type,
  required FormSchema schema,
  required Map<String, dynamic> values,
}) {
  double total = 0;
  if (type == MosqueTypes.musalla) {
    total = _toDouble(values["area"]) * 680;
  } else if (type == MosqueTypes.small) {
    total = _toDouble(values["area"]) * 780;
    total += calculateInstituteCost(_toDouble(values["sharia_institute"]));
    total += calculateBasementCost(
      values["basement"],
      _toDouble(values["basement_area"]),
    );
    total += calculateImamHousesCost(values["imam_house"]);
    total += calculateCourtyardCost(
      values["courtyard"],
      _toDouble(values["courtyard_area"]),
    );
    total += calculateShopsCost(
      values["shops"],
      _toDouble(values["shops_area"]),
    );
  } else if (type == MosqueTypes.medium) {
    total = _toDouble(values["area"]) * 880;
    total += calculateInstituteCost(_toDouble(values["sharia_institute"]));
    total += calculateBasementCost(
      values["basement"],
      _toDouble(values["basement_area"]),
    );
    total += calculateImamHousesCost(values["imam_house"]);
    total += calculateCourtyardCost(
      values["courtyard"],
      _toDouble(values["courtyard_area"]),
    );
    total += calculateShopsCost(
      values["shops"],
      _toDouble(values["shops_area"]),
    );
    total += calculateCharityKitchenCost(
      values["charity_kitchen"],
      _toDouble(values["charity_kitchen_area"]),
    );
    total += calculateClinicCost(
      values["clinic"],
      _toDouble(values["clinic_area"]),
    );
    total += calculateLibraryCost(
      values["library"],
      _toDouble(values["library_area"]),
    );
  } else if (type == MosqueTypes.large) {
    total = _toDouble(values["area"]) * 980;
    total += calculateInstituteCost(_toDouble(values["sharia_institute"]));
    total += calculateBasementCost(
      values["basement"],
      _toDouble(values["basement_area"]),
    );
    total += calculateImamHousesCost(values["imam_house"]);
    total += calculateCourtyardCost(
      values["courtyard"],
      _toDouble(values["courtyard_area"]),
    );
    total += calculateShopsCost(
      values["shops"],
      _toDouble(values["shops_area"]),
    );
    total += calculateCharityKitchenCost(
      values["charity_kitchen"],
      _toDouble(values["charity_kitchen_area"]),
    );
    total += calculateClinicCost(
      values["clinic"],
      _toDouble(values["clinic_area"]),
    );
    total += calculateLibraryCost(
      values["library"],
      _toDouble(values["library_area"]),
    );
  } else {
    // Expansion
    total += calculateInstituteCost(_toDouble(values["sharia_institute"]));
    total += calculateImamHousesCost(values["imam_house"]);
    total += calculateCourtyardCost(
      values["courtyard"],
      _toDouble(values["courtyard_area"]),
    );
    total += calculateShopsCost(
      values["shops"],
      _toDouble(values["shops_area"]),
    );
  }
  total = calculateLocationRatio(total, values["location"]);
  total = calculateQualityRatio(total, values["quality"]);
  if (values["needs_renovation"] ?? false) {
    final tempTotal = total;
    total -= calculateStructuralConditionRatio(tempTotal, values);
    total -= calculateArchitecturalConditionRatio(tempTotal, values);
    total -= calculateDecorConditionRatio(tempTotal, values);
    total -= calculateHVACConditionRatio(tempTotal, values);
    total -= calculateElectricConditionRatio(tempTotal, values);
    total -= calculateRenewablePowerConditionRatio(tempTotal, values);
    total -= calculateMinaretConditionRatio(tempTotal, values);
    total -= calculateWaterConditionRatio(tempTotal, values);
  }
  total += calculateLocationSetupCost(_toDouble(values["area"]));
  return total;
}

double _toDouble(dynamic v) {
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

bool _toBool(dynamic v) {
  if (v is bool) return v;
  v = v.toString();
  return v == "موجود" || v == "سليم" ? true : false;
}

double calculateLocationRatio(double total, String location) {
  if (location == "محافظة") {
    return total;
  } else if (location == "مدينة") {
    return total * 0.8;
  } else if (location == "بلدة") {
    return total * 0.7;
  } else {
    return total * 0.6; // "قرية"
  }
}

double calculateQualityRatio(double total, String quality) {
  if (quality == "متوسطة") {
    return total * 0.9;
  } else if (quality == "اقتصادي") {
    return total * 0.8;
  } else {
    return total; // "عالية"
  }
}

double calculateInstituteCost(double classesCount) {
  return classesCount * 24000;
}

double calculateBasementCost(bool basement, double area) {
  return basement ? area * 650 : 0;
}

double calculateImamHousesCost(String housesCount) {
  return _toDouble(housesCount) * 28000;
}

double calculateCourtyardCost(bool courtyard, double area) {
  return courtyard ? area * 145 : 0;
}

double calculateShopsCost(String shopsCount, double area) {
  return _toDouble(shopsCount) * 240 * area;
}

double calculateCharityKitchenCost(bool charityKitchen, double area) {
  return charityKitchen ? 650 * area : 0;
}

double calculateClinicCost(bool clinic, double area) {
  return clinic ? 650 * area : 0;
}

double calculateLibraryCost(bool library, double area) {
  return library ? 650 * area : 0;
}

double calculateLocationSetupCost(double area) {
  return 20 * area;
}

double calculateStructuralConditionRatio(
  double total,
  Map<String, dynamic> values,
) {
  if (_toBool(values["structural_condition"])) {
    return total * 0.3;
  } else {
    return total * 0.3 -
        (total * 0.3 * (_toDouble(values["structural_damage_percent"]) / 100));
  }
}

double calculateArchitecturalConditionRatio(
  double total,
  Map<String, dynamic> values,
) {
  if (_toBool(values["architectural_condition"])) {
    return total * 0.2;
  } else {
    return total * 0.2 -
        (total * 0.2 * (_toDouble(values["architectural_damage_percent"]) / 100));
  }
}

double calculateDecorConditionRatio(double total, Map<String, dynamic> values) {
  if (_toBool(values["decor_presence"])) {
    return total * 0.1;
  } else {
    return total * 0.1 -
        (total * 0.1 * (_toDouble(values["decor_missing_percent"]) / 100));
  }
}

double calculateHVACConditionRatio(double total, Map<String, dynamic> values) {
  if (_toBool(values["hvac_presence"])) {
    return total * 0.1;
  } else {
    return 0;
  }
}

double calculateElectricConditionRatio(
  double total,
  Map<String, dynamic> values,
) {
  if (_toBool(values["electric_presence"])) {
    return total * 0.1;
  } else {
    return total * 0.1 -
        (total * 0.1 * (_toDouble(values["electric_missing_percent"]) / 100));
  }
}

double calculateRenewablePowerConditionRatio(
  double total,
  Map<String, dynamic> values,
) {
  if (_toBool(values["renewable_presence"])) {
    return total * 0.03;
  } else {
    return total * 0.03 -
        (total * 0.03 * (_toDouble(values["renewable_missing_percent"]) / 100));
  }
}

double calculateMinaretConditionRatio(
  double total,
  Map<String, dynamic> values,
) {
  if (_toBool(values["minaret_condition"])) {
    return total * 0.1;
  } else {
    return total * 0.1 -
        (total * 0.1 * (_toDouble(values["minaret_damage_percent"]) / 100));
  }
}

double calculateWaterConditionRatio(double total, Map<String, dynamic> values) {
  if (_toBool(values["water_condition"])) {
    return total * 0.07;
  } else {
    return total * 0.07 -
        (total * 0.07 * (_toDouble(values["water_damage_percent"]) / 100));
  }
}
