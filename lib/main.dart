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

enum OrderBy { asc, desc }
class _MyHomePageState extends State<MyHomePage> {
  final sorter = Sorting();

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
                      sorter.changeSort('name', () => setState(() {}));
                      // if(orderBy == OrderBy.desc) {
                      //   setState(() {
                      //     sortBy = null;
                      //     orderBy = null;
                      //   });
                      //   return;
                      // } else {
                      //   setState(() {
                      //     sortBy = 'name';
                      //     orderBy = orderBy == OrderBy.asc ? OrderBy.desc : OrderBy.asc;
                      //   });
                      // }
                    },
                    child: Row(
                      children: [
                         const Text('Name'),
                         if(sorter.sortBy == 'name' && sorter.orderBy != null)
                          sorter.orderBy == OrderBy.asc ? const Icon(Icons.arrow_drop_up) : const Icon(Icons.arrow_drop_down)
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      sorter.changeSort('date', () => setState(() {}));
                    },
                    child: Row(
                      children: [
                         const Text('Date'),
                         if(sorter.sortBy == 'date' && sorter.orderBy != null)
                          sorter.orderBy == OrderBy.asc ? const Icon(Icons.arrow_drop_up) : const Icon(Icons.arrow_drop_down)
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      sorter.changeSort('type', () => setState(() {}));
                    },
                    child: Row(
                      children: [
                         const Text('Type'),
                         if(sorter.sortBy == 'type' && sorter.orderBy != null)
                          sorter.orderBy == OrderBy.asc ? const Icon(Icons.arrow_drop_up) : const Icon(Icons.arrow_drop_down)
                      ],
                    ),
                  ),
                ],
              ),
            ),
            FutureBuilder(
              future: fetchData(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final data = snapshot.data as List<dynamic>;
                  if(sorter.orderBy != null) {
                    data.sort(((a, b) => sorter.orderBy == OrderBy.asc ? a[sorter.sortBy].compareTo(b[sorter.sortBy]) : b[sorter.sortBy].compareTo(a[sorter.sortBy])));
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

// When I click on a new column, I'd like it to reset to Asc
// When I click on the same column, after desc reset to no order by

class Sorting {
  String? sortBy;
  OrderBy? orderBy;
  int count = 0;

  void changeSort(String sortBy, Function() callback) {
    if (this.sortBy != sortBy){
      this.sortBy = sortBy;
      orderBy = OrderBy.asc;
      callback.call();
    } else if (this.sortBy == sortBy && orderBy == OrderBy.desc) {
      this.orderBy = null;
      callback.call();
    }
    else {
      orderBy = orderBy == OrderBy.asc ? OrderBy.desc : OrderBy.asc;
      callback.call();
    }
  }
}
