import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:intl/intl.dart';

// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tzdata;

firebaseAnalyticsLog(String eventName, Map<String, Object> parameters) async {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  try {
    // Log the event with parameters
    await analytics.logEvent(name: eventName, parameters: parameters);
  } catch (e) {
    print("Error logging event: $e");
  }
}

// Password Validation
String? passwordValidator(String value) {
  if (value.isEmpty) {
    return 'please enter password';
  }
  if (value.length < 6) {
    return 'minimum 6 characters required';
  }
  return null;
}

// Empty field validation

String? emptyValidator({required String value, String? message}) {
  if (value.isEmpty) {
    return message ?? 'field can not be empty';
  }
  return null;
}

String? emailValidator(value) {
  if (value.isEmpty) {
    return 'please enter email id';
  }
  const patt =
      r"^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})$";
  if (!RegExp(patt).hasMatch(value)) {
    return 'please enter valid email address';
  }

  return null;
}

String? phoneValidator(value) {
  if (value.isEmpty) {
    return 'please enter phone number';
  }
  // const patt =
  //     r"^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})$";
  // if (!RegExp(patt).hasMatch(value)) {
  //   return 'Please enter valid email address';
  // }
  if (value.toString().length != 10) {
    return 'phone number should be 10 characters long';
  }

  return null;
}

appLog(message) {
  print(message);
}

Future<void> noInternet({required BuildContext context}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  textAlign: TextAlign.center,
                  'No tienes conexión a Internet, por favor conéctate a Internet para continuar',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  softWrap: true,
                ),
              ),
              // const SizedBox(height: 20),
              // InkWell(
              //   onTap: () {
              //     Navigator.pop(context);
              //   },
              //   child: appNormalText(
              //       title: 'De acuerdo',
              //       fontSize: 15,
              //       textFontWeight: FontWeight.w700),
              // ),
            ],
          ),
        ),
      );
    },
  );
}

String cleanCommaPrice(String price) {
  return price.replaceAll(',', '');
}

Color halloweenColorChanger(Color halloweenColor, Color normalColor) {
  final now = DateTime.now().toLocal(); // current local datetime
  final currentYear = now.year;

  // 🛍️ Black Friday test period: 14 Oct to 30 Nov, Night 11:59 PM(inclusive)
  final halloweenStart = DateTime(currentYear, 11, 14);
  final halloweenEnd = DateTime(currentYear, 11, 30, 23, 59, 59);

  if (now.isAfter(halloweenStart) && now.isBefore(halloweenEnd)) {
    return halloweenColor;
  } else {
    return normalColor;
  }
}

bool isHalloweenPeriod() {
  final now = DateTime.now().toLocal(); // current local datetime
  final currentYear = now.year;

  // 🛍️ Black Friday test period: 14 Oct to 30 Nov, Night 11:59 PM(inclusive)
  final halloweenStart = DateTime(currentYear, 11, 14);
  final halloweenEnd = DateTime(currentYear, 11, 30, 23, 59, 59);

  return now.isAfter(halloweenStart) && now.isBefore(halloweenEnd);
}
