import 'package:flutter/material.dart';

// height 앞의 required를 제거하고 double? 로 변경하여 선택 사항으로 만듭니다.
Widget cardContainer({double? height, required Widget child}) {
  return Container(
    width: double.infinity,
    height: height, // 이제 height가 null이면 자식 위젯 크기에 맞춰 자동으로 늘어납니다.
    margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          // black.withOpacity는 곧 사용 중단될 예정이므로 withValues를 권장하지만, 
          // 현재 코드를 유지하시려면 그대로 두셔도 됩니다.
          color: Colors.black.withValues(alpha: 0.03), 
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: child,
  );
}