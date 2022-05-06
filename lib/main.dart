import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? sortBy;
  Future<dynamic> fetchData() async {
    try {
      Uri uri = Uri.parse('http://127.0.0.1:5500/json/table_data.json');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw ErrorDescription('Bad Request!');
      }
    } catch (error) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            Container(
              height: 200,
              color: Colors.grey,
            ),
            // HEADERS GO HERE
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              width: double.infinity,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 1, color: Colors.black),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        sortBy = 'name';
                      });
                    },
                    child: const Text('Name'),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        sortBy = 'date';
                      });
                    },
                    child: const Text('Date'),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        sortBy = 'type';
                      });
                    },
                    child: const Text('Type'),
                  ),
                ],
              ),
            ),
            FutureBuilder(
              future: fetchData(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final data = snapshot.data as List<dynamic>;
                  if(sortBy != null) {
                    data.sort(((a, b) => a[sortBy].compareTo(b[sortBy])));
                  }
                  return Expanded(
                    child: ListView.builder(
                      physics: const ClampingScrollPhysics(),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final row = Map<String, String>.from(data[index]);
                        return Container(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(row['name']!),
                              Text(row['date']!),
                              Text(row['type']!)
                            ],
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
