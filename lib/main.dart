import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Wall App',
      theme: ThemeData(
        primaryColor: Colors.blueAccent,
        brightness: Brightness.dark,
      ),
      home: Announcements(),
    );
  }
}

class Announcements extends StatefulWidget {
  @override
  _AnnouncementsState createState() => _AnnouncementsState();
}

class _AnnouncementsState extends State<Announcements> {

  createAlertDialog(BuildContext context) {

    TextEditingController controller = TextEditingController();

    return showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text('Make Announcement'),
        content: TextField(
          controller: controller,
        ),
        actions: <Widget>[
          MaterialButton(
            elevation: 5.0,
            child: Text('Post'),
            onPressed: () {
              Firestore.instance.collection('announcements').add({
                'text': controller.text.toString(),
                'likes': 0
              });
              Navigator.pop(context);
            },
          )
        ],
      );
    });
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('announcements').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);

    return Padding(
      key: ValueKey(record.text),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(2.0),
        ),
        child: ListTile(
          title: Text(record.text),
          trailing: Wrap(
            spacing: 12, // space between two icons
            children: <Widget>[
              Icon(Icons.favorite, color: Colors.red),
              Text(record.likes.toString(), style: TextStyle(fontSize: 20.0) ),
            ],
          ),
          onTap: () => record.reference.updateData({'likes': FieldValue.increment(1)}),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("The Wall")),
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          createAlertDialog(context);
        },
        tooltip: 'Post',
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class Record {
  final String text;
  final int likes;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['text'] != null),
        assert(map['likes'] != null),
        text = map['text'],
        likes = map['likes'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$text:$likes>";
}
