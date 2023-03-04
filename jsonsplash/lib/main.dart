import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SplashPage extends StatelessWidget {
  final Future<List<dynamic>> _dataListFuture;

  SplashPage(this._dataListFuture);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: _dataListFuture,
          builder:
              (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Display loading spinner
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              // Navigate to the main page after the data is loaded
              return MainPage(snapshot.data ?? []); // Add null check here
            }
          },
        ),
      ),
    );
  }
}

class MainPage extends StatelessWidget {
  final List<dynamic> dataList;

  MainPage(this.dataList);

  @override
  Widget build(BuildContext context) {
    final List<String> names =
          dataList.map((result) => result["login"]["username"] as String).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('My List'),
      ),
      body: ListView.builder(
        itemCount: names.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(names[index]),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<List<dynamic>> _dataListFuture = loadData();

  static Future<List> loadData() async {
    final response =
        await http.get(Uri.parse('https://randomuser.me/api/?results=10'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      // print(response.body);
      final List<dynamic> results = data['results'];
      // final List<String> names =
      //     results.map((result) => result["login"]["username"] as String).toList();
      return results;
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: SplashPage(_dataListFuture),
    );
  }
}
