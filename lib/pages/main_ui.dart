import 'package:flutter/material.dart';
import 'variables.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Tùy chỉnh AppBar với PreferredSize để có 2 hàng
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(160), // Chiều cao AppBar
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 2,
          // flexibleSpace cho phép ta tùy biến nội dung AppBar
          flexibleSpace: SafeArea(
            child: Column(
              children: [
                // ---- DÒNG 1: LOGO, SEARCH BAR, ACCOUNT ICON ----
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      // LOGO (thay đường dẫn logo của bạn)
                      Image.asset('assets/images/logo.png', height: 80),

                      const SizedBox(width: 40),

                      // THANH TÌM KIẾM
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(color: Colors.grey[300]),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Search...",
                              border: InputBorder.none,
                              prefixIcon: const Icon(Icons.search),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red, // Màu cam
                            foregroundColor: Colors.white, // Chữ trắng
                            shape: RoundedRectangleBorder(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ), // Kích thước phù hợp
                          ),
                          child: Text(
                            'Search',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // BIỂU TƯỢNG ACCOUNT
                      IconButton(
                        icon: const Icon(
                          Icons.account_circle,
                          color: Colors.red,
                          size: 32,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                // ---- DÒNG 2: DÃY NÚT CHUYỂN TRANG ----
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(titles.length, (index) {
                      return Expanded(
                        child: _buildNavItem(
                          title: titles[index],
                          isSelected: selectedIndex == index,
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: pages[selectedIndex],
    );
  }

  // Widget nút chuyển trang
  Widget _buildNavItem({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red : Colors.blueGrey,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          title,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
