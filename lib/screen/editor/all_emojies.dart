import 'package:flutter/material.dart';
import 'package:kadai_app/data/data.dart';

class Emojies extends StatefulWidget {
  const Emojies({Key key}) : super(key: key);

  @override
  _EmojiesState createState() => _EmojiesState();
}

class _EmojiesState extends State<Emojies> {
  List<String> emojis = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0.0),
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey[400],
            blurRadius: 10.9,
          ),
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Text('Select Emoji'),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Container(
            height: 315,
            padding: const EdgeInsets.all(0.0),
            child: GridView(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              scrollDirection: Axis.vertical,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                mainAxisSpacing: 0.0,
                maxCrossAxisExtent: 60.0,
              ),
              children: emojis.map((String emoji) {
                return GridTile(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(
                        context,
                        {
                          'name': emoji,
                          'color': Colors.white,
                          'size': 12.0,
                          'align': TextAlign.center,
                        },
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.zero,
                      child: Text(
                        emoji,
                        style: const TextStyle(
                          fontSize: 35,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    emojis = getSmileys();
  }
}
