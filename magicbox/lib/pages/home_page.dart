import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:get/get.dart';

import '../controllers/box_controller.dart';
import '../pages/box_detail_page.dart';
import '../pages/create_box_page.dart';
import '../utils/theme_helper.dart';
import '../widgets/star_background.dart';

class HomePage extends StatelessWidget {
  final BoxController boxController = Get.put(BoxController());

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: IgnorePointer(child: StarFieldBackground()),
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6D60F6), Color(0xFF9C27B0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: const Text('我的魔盒'),
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
            ),
            floatingActionButton: FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () => Get.to(() => const CreateBoxPage()),
            ),
            backgroundColor: Colors.transparent,
            body: Obx(() {
              if (boxController.boxList.isEmpty) {
                return const Center(child: Text('暂无盒子，点击右下角添加'));
              }

              return Swiper(
                itemCount: boxController.boxList.length,
                itemWidth: MediaQuery.of(context).size.width * 0.8,
                itemHeight: MediaQuery.of(context).size.height * 0.5,
                layout: SwiperLayout.STACK,
                itemBuilder: (context, index) {
                  final box = boxController.boxList[index];
                  return GestureDetector(
                    onTap: () async {
                      print('🟠 盒子点击触发: ${box.name}');
                      await Get.to(() => BoxDetailPage(box: box));
                      boxController.loadBoxes();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      transform: Matrix4.rotationY(0.05),
                      child: Hero(
                        tag: box.name,
                        child: Card(
                          elevation: 10,
                          shadowColor: Colors.purpleAccent,
                          color:
                              ThemeHelper.getMaterialForTheme(box.themeColor),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                            side: const BorderSide(
                                color: Colors.black12, width: 1),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12)),
                                  child: Image.file(
                                    File(box.coverImage),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                  box.name,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ),
      ],
    );
  }
}
