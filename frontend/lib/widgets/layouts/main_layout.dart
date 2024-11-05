import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:star23sharp/providers/index.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final double bottomNavHeight = MediaQuery.of(context).size.height * 0.2;
    final double deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: child,
          ),
          IgnorePointer(
            ignoring: true,
            child: Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(themeProvider.backgroundImage),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Stack(
        children: [
          // 배경 이미지
          Positioned.fill(
            child: Image.asset(
              themeProvider.bottomNavigationImage, // 여기에 이미지 경로를 넣으세요.
              fit: BoxFit.cover,
            ),
          ),
          // BottomNavigationBar
          SizedBox(
            height: bottomNavHeight,
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent, // 배경을 투명하게 설정
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.business),
                  label: 'Map',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.school),
                  label: 'Profile',
                ),
              ],
              onTap: (index) {
                // 페이지 전환 논리 구현
                if (index == 0) {
                  Navigator.pushReplacementNamed(context, '/home');
                } else if (index == 1) {
                  Navigator.pushReplacementNamed(context, '/map');
                } else if (index == 2) {
                  Navigator.pushReplacementNamed(context, '/profile');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
