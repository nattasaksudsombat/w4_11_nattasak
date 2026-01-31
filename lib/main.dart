import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _songNameCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _songTypeCtrl = TextEditingController();
  void addSong() async {
    String _songName = _songNameCtrl.text;
    String _name = _nameCtrl.text;
    String _songType = _songTypeCtrl.text;
    print("ท่าที่เก็บ $_songName | $_name | $_songType");

    try {
      await FirebaseFirestore.instance.collection("songs").add({
        "songName": _songName,
        "artis": _name,
        "songlype": _songType,
      });
      _songNameCtrl.clear();
      _nameCtrl.clear();
      _songTypeCtrl.clear();
    } catch (e) {
      print(" เกิดข้อผิดพลาด : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: "ชื่อมพอง"),
              controller: _songNameCtrl,
            ),
            TextField(
              decoration: InputDecoration(labelText: "ชื่อศิลปิน"),
              controller: _nameCtrl,
            ),
            TextField(
              decoration: InputDecoration(labelText: "แนวเพลง"),
              controller: _songTypeCtrl,
            ),
            ElevatedButton(onPressed: addSong, child: Text("มันทีก")),

            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("songs")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  }
                  final docs = snapshot.data!.docs;
                  return GridView.builder(
                    itemCount: docs.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),

                    itemBuilder: (context, index) {
                      final songs = docs[index];
                      final s = songs. data();
                      return InkWell(
                        onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (_)=> SongDetail(song: s)));
                        },
                        child: Card(child: Center(child: Text(s["songName"])) ,),);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class SongDetail extends StatelessWidget{
  final song;
  const SongDetail({super.key, required this.song});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("songName data"),
      ),
      body: Column(
        children: [

          Text (song ["songName"]),

          Text (song ["artis"]),

          Text (song ["songType"]),
        ],
      ),
    );
  }
}