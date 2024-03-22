import 'package:flutter/material.dart';
import 'package:unift/unift_core/app.dart';
import 'package:unift/unift_core/model.dart';
import 'package:unift/unift_core/widgets/app.dart';
import 'package:unift/unift_core/theme.dart';
import 'package:unift/unift_ref/ref_widget.dart';
import 'package:unift/unift_ref/unift_ref.dart';

void main() {
  final themeManager = ThemeManager.init();
  ThemeManager().changeThemeMode('light');

  /// 在UniFtApp里面对路由进行了封装
  runApp(UniFtApp(
    home: MyHomePage(),
    themeManager: themeManager,
    routes: {'page': (context) => SecondPage()},
  ));
}

/// 数据模型 用于跨页面共享状态
class DataModel extends BaseModel {
  final count = 0.toRef();
}

class MyHomePage extends StatelessWidget {
  // 实例化模型 并调用share方法 会将模型自动共享到容器中
  final DataModel model = DataModel().share();

  MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: ElevatedButton(
            onPressed: () {
              App.router.toName('page');
            },
            child: refEl(() => Text('count记录值 ${model.count} 点我跳转到新页面')),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => model.count.value++,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  // 这里通过模型管理容器的of方法来获取到容器中的共享数据模型
  final DataModel model = Model.of<DataModel>();
  SecondPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ignore: prefer_const_constructors
      appBar: AppBar(title: Text('Second Page')),
      body: Center(
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 33, 236, 243),
              disabledBackgroundColor: const Color.fromARGB(255, 33, 243, 149),
              disabledForegroundColor: Colors.black),
          child: refEl(() => Text('这是共享的count值： ${model.count}')),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => model.count.value++,
        child: const Icon(Icons.add),
      ),
    );
  }
}
