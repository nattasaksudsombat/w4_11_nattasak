import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  // 🟢 เริ่มต้นระบบ Flutter และเชื่อมต่อ Firebase ก่อนรัน App
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

/// ======================================================
/// 🚀 CONFIGURATION: ปรับแต่งสีธีม (ม่วง-ดำ) ทั่วทั้งแอป
/// ======================================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music Vault',
      theme: ThemeData(
        brightness: Brightness.dark, // ตัวนี้บอกว่าธีมหลักคือ Dark
        scaffoldBackgroundColor: const Color(0xFF050507),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurpleAccent,
          brightness: Brightness.dark, // ✨ เพิ่มบรรทัดนี้เข้าไปเพื่อให้ ColorScheme เป็น Dark เหมือนกันครับ
          primary: Colors.deepPurpleAccent,
          surface: const Color(0xFF1A1A2E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      home: const MyHomePage(title: '🔮 Music Vault'),
    );
  }
}

/// ======================================================
/// 🎵 HOME PAGE: หน้าจัดการข้อมูลเพลง (เพิ่ม & แสดงรายการ)
/// ======================================================
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 📝 ตัวควบคุมข้อความสำหรับรับค่าจาก TextField
  final _songNameCtrl = TextEditingController();
  final _artistCtrl = TextEditingController();
  final _songTypeCtrl = TextEditingController();

  // 💾 ฟังก์ชันบันทึกข้อมูลลง Firebase Firestore
  void addSong() async {
    if (_songNameCtrl.text.isEmpty) return; // ถ้าชื่อเพลงว่าง ไม่ต้องทำต่อ

    await FirebaseFirestore.instance.collection("songs").add({
      "songName": _songNameCtrl.text,
      "artist": _artistCtrl.text,
      "songType": _songTypeCtrl.text,
      "createdAt": Timestamp.now(), // เก็บเวลาที่สร้างเพื่อใช้เรียงลำดับ
    });

    // ล้างค่าในช่องกรอกหลังจากบันทึกเสร็จ
    _songNameCtrl.clear();
    _artistCtrl.clear();
    _songTypeCtrl.clear();
  }

  // 🛠️ Widget ตัวช่วยสร้างดีไซน์ช่อง Input ให้เหมือนกันทุกช่อง
  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.deepPurpleAccent),
      filled: true,
      fillColor: const Color(0xFF161625),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.deepPurpleAccent, width: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// ⌨️ ส่วนกรอกข้อมูล (Text Fields)
            TextField(controller: _songNameCtrl, decoration: _inputStyle("ชื่อเพลง", Icons.music_note)),
            const SizedBox(height: 10),
            TextField(controller: _artistCtrl, decoration: _inputStyle("ศิลปิน", Icons.person_pin_rounded)),
            const SizedBox(height: 10),
            TextField(controller: _songTypeCtrl, decoration: _inputStyle("แนวเพลง", Icons.album_rounded)),
            const SizedBox(height: 15),

            /// ➕ ปุ่มกดเพื่อบันทึก
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_rounded),
                label: const Text("บันทึกเข้า Vault", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: addSong,
              ),
            ),
            const SizedBox(height: 25),

            /// 📡 ส่วนแสดงรายการเพลงแบบ Real-time (ใช้ StreamBuilder)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("songs")
                    .orderBy("createdAt", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  // แสดงวงกลมหมุนถ้าข้อมูลยังโหลดไม่เสร็จ
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                  final docs = snapshot.data!.docs;

                  // สร้าง Grid แสดงผล 2 คอลัมน์
                  return GridView.builder(
                    itemCount: docs.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.1,
                    ),
                    itemBuilder: (context, index) {
                      final song = docs[index].data() as Map<String, dynamic>;

                      return InkWell(
                        onTap: () {
                          // ➡️ คลิกที่ Card เพื่อข้ามไปหน้าดูรายละเอียด
                          Navigator.push(context, MaterialPageRoute(builder: (_) => SongDetail(song: song)));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [const Color(0xFF2E1A47), Colors.black],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.play_circle_fill, size: 40, color: Colors.deepPurpleAccent),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  song["songName"],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(song["artist"], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                      );
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

/// ======================================================
/// 🎧 SONG DETAIL: หน้าแสดงรายละเอียดเพลงแบบเน้นๆ
/// ======================================================
class SongDetail extends StatelessWidget {
  final Map<String, dynamic> song;
  const SongDetail({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Now Playing")),
      body: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: const Color(0xFF121220),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(color: Colors.deepPurpleAccent.withOpacity(0.2), blurRadius: 20, spreadRadius: 5)
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // รูปจำลองแผ่นเสียง/หน้าปก
              Container(
                height: 150, width: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(colors: [Colors.deepPurpleAccent, Colors.black]),
                  border: Border.all(color: Colors.white10, width: 4),
                ),
                child: const Icon(Icons.music_note, size: 80, color: Colors.white),
              ),
              const SizedBox(height: 30),
              // ข้อมูลเพลงที่ส่งมาจากหน้าแรก
              Text(song["songName"], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("🎤 ${song["artist"]}", style: const TextStyle(fontSize: 18, color: Colors.deepPurpleAccent)),
              const SizedBox(height: 4),
              Text("Genre: ${song["songType"]}", style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}