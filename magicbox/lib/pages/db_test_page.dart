import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class DBTestPage extends StatefulWidget {
  const DBTestPage({super.key});

  @override
  State<DBTestPage> createState() => _DBTestPageState();
}

class _DBTestPageState extends State<DBTestPage> {
  String? dbPath;
  String? error;

  @override
  void initState() {
    super.initState();
    checkDatabasePath();
  }

  Future<void> checkDatabasePath() async {
    try {
      final path = await getDatabasesPath();
      setState(() {
        dbPath = path;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('数据库路径测试')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('尝试获取数据库路径...'),
              const SizedBox(height: 20),
              if (dbPath != null) Text('✅ 数据库路径: $dbPath'),
              if (error != null)
                Text(
                  '❌ 错误: $error',
                  style: const TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }
}