import 'dart:convert';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup name generator',
      home: RandomWords(),
      theme: ThemeData(primaryColor: Colors.indigoAccent),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _saved = Set<WordPair>();
  final _biggerFont = const TextStyle(fontSize: 18.0);

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          if (i.isOdd) return Divider();

          final index = i ~/ 2;
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10));
          }
          return _buildRow(_suggestions[index]);
        });
  }

  Widget _buildRow(WordPair pair) {
    bool alreadySaved = _saved.contains(pair);
    Future<Employee> post = fetchPost();
    return ExpansionTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: new Column(children: <Widget>[
//        new Container(
//          child: new IconButton(
//            icon: new Icon(
//              alreadySaved ? Icons.favorite : Icons.favorite_border,
//              color: alreadySaved ? Colors.red : null,
//            ),
//            onPressed: () {
//              setState(() {
//                if (alreadySaved) {
//                  _saved.remove(pair);
//                } else {
//                  _saved.add(pair);
//                }
//              });
//            },
//          ),
////                margin: EdgeInsets.only(right: 1),
//        ),
        new Container(
          child: new OutlineButton(
            child: Text(alreadySaved ? "End" : "Start"),
            onPressed: () {
              setState(() {
                if (alreadySaved) {
                  _saved.remove(pair);
                } else {
                  _saved.add(pair);
                }
              });
            },
          ),
        )
      ]),
      children: <Widget>[
        new FutureBuilder<Employee>(
            future: post,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.data.name);
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return CircularProgressIndicator();
            }),
        new ListTile(
          title: Text("Details"),
        ),
        new ListTile(
          title: Text("task 1"),
          trailing: new Column(
            children: <Widget>[
              Checkbox(
                value: alreadySaved,
                onChanged: (bool value) {
                  setState(() {
                    alreadySaved ? _saved.remove(pair) : _saved.add(pair);
                  });
                },
              )
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GIMME SCHEDULE'),
//        backgroundColor: Colors.red,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.list),
            onPressed: _pushedSaved,
          )
        ],
      ),
      body: _buildSuggestions(),
    );
  }

  void _pushedSaved() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      var post = fetchPost();

      final Iterable<ListTile> tiles = _saved.map((WordPair pair) {
        return ListTile(
          title: Text(
            post.toString(),
            style: _biggerFont,
          ),
        );
      });
      final List<Widget> divided =
          ListTile.divideTiles(context: context, tiles: tiles).toList();

      return Scaffold(
        appBar: AppBar(
          title: Text("hahahaha"),
        ),
        body: ListView(children: divided),
      );
    }));
  }

  Future<http.Response> getResponse() {
    return http.get("http://localhost:8080/");
  }

  Future<Employee> fetchPost() async {
    final response = await http.get("http://10.0.2.2:8080/1");
    if (response.statusCode == 200) {
      return Employee.fromJson(json.decode(response.body));
    } else {
      throw Exception("Failed to load post");
    }
  }
}

class RandomWords extends StatefulWidget {
  @override
  RandomWordsState createState() => RandomWordsState();
}

class Post {
  final Employee e;

  //data:{"id":1,"name":"user_1","salary":101}

  Post({this.e});
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      e: json['data']
    );
  }
}

class Employee {
  final int id;
  final String name;
  final int salary;

  Employee({this.id, this.name, this.salary});

  factory Employee.fromJson(Map<String, dynamic> json){
    return Employee(
      id: json['id'],
      name: json['name'],
      salary: json['salary']
    );
  }

}