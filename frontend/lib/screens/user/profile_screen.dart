import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:star23sharp/main.dart';
import 'package:star23sharp/providers/index.dart';
import 'package:star23sharp/services/index.dart';
import 'package:star23sharp/utilities/app_global.dart';
import 'package:star23sharp/widgets/index.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var nickname = Provider.of<UserProvider>(context, listen: false).nickname;
    List<Map<String, String>> items = [
      {'text':'닉네임 변경', 'goto': '/modify_nickname'}, 
      {'text':'비밀번호 변경', 'goto': '/modify_pwd'}, 
      {'text':'테마 변경', 'goto': '/modify_theme'}
    ];

    return Stack(
      children: [
        Center(
          child: SizedBox(
            width: UIhelper.deviceWidth(context) * 0.85,
            height: UIhelper.deviceHeight(context) * 0.67,
            child: Image.asset(
              'assets/img/main_bg.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "내 정보",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: FontSizes.title, 
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "안녕하세요 $nickname님!",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: FontSizes.body),
              ),
              const SizedBox(height: 10),
              Container(
                width: UIhelper.deviceWidth(context) * 0.8,
                height: UIhelper.deviceHeight(context) * 0.3,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3E1E1).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 각 항목에 대해 InkWell로 클릭 가능하게 만들기
                    ...List.generate(items.length, (index) {
                      // 리스트 아이템의 높이를 Container 높이의 1/3로 설정
                      double itemHeight = (UIhelper.deviceHeight(context) * 0.3) * 0.33;

                      return InkWell(
                        onTap: () {
                          Navigator.pushNamed(AppGlobal.navigatorKey.currentContext!, '/modify_profile');   // 텍스트 클릭 시 "하이" 출력
                        },
                        child: Container(
                          height: itemHeight, // Container 높이의 1/3
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: index % 2 == 1 ? const Color(0xFFF6F6F6).withOpacity(0.2) : Colors.transparent,  // 배경색을 흰색으로 설정하고 투명도 50%
                            borderRadius: BorderRadius.circular(8), // 둥근 모서리
                          ),
                          child: Row(
                            children: [
                              Text(
                                "${index + 1}. ",  // 번호 매기기
                                style: const TextStyle(
                                  fontSize: FontSizes.body,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  items[index]['text']!,  // 리스트의 항목을 텍스트로 출력
                                  style: const TextStyle(
                                    fontSize: FontSizes.body,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.left, // 텍스트 좌측 정렬
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: UIhelper.deviceWidth(context) * 0.5, // 너비 50%
                child: ElevatedButton(
                  onPressed: () async {
                    var refresh = Provider.of<AuthProvider>(context, listen: false).refreshToken;
                    bool response = await UserService.logout(refresh!);
                    if(response){
                      Provider.of<AuthProvider>(AppGlobal.navigatorKey.currentContext!, listen: false).clearTokens();
                      Navigator.pushNamed(AppGlobal.navigatorKey.currentContext!, '/home');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA292EC).withOpacity(0.4), // 배경색 설정
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // 모서리 둥글게 설정
                    ),
                  ),
                  child: const Text("로그아웃", style: TextStyle(fontSize: FontSizes.body, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}