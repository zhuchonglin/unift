import 'package:flutter/material.dart';
import 'package:unift/unift_core/helper.dart';
import 'package:unift/unift_ref/unift_ref.dart';

import 'unift_ref/ref_widget.dart';
import 'dart:ui';

void main() {
  print(window.locale);
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatelessWidget {
  final text = 0.toRef();
  Home({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('测试页面'),
      ),
      body: Center(
        child: refEl(() => Text('$text', style: TextStyle(fontSize: rpx(50)))),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => text.value++,
        child: const Icon(Icons.add),
      ),
    );
  }
}
