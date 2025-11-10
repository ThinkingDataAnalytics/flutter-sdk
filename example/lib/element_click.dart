import 'package:flutter/material.dart';
import 'package:thinking_analytics/autotrack/td_autotrack_config.dart';
class ElementClickView extends StatefulWidget {
  @override
  State<ElementClickView> createState() => _ElementClickViewState();
}

class _ElementClickViewState extends State<ElementClickView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('元素点击测试'),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {  },),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                  key: TDElementKey("3333", properties: {"44": "223"},isIgnore: true),
                  onPressed: () {},
                  child: Text(
                    "按钮2",
                    style: TextStyle(fontSize: 14),
                  )),
              TextButton(
                  key: TDElementKey("text_button1", properties: {"key1": "kkkkdd"}),
                  onPressed: () {},
                  child: Text("按钮3", style: TextStyle(fontSize: 14))),
              IconButton(
                key: TDElementKey("text_button2", properties: {"key1": "3333"}),
                icon: Icon(Icons.delete),
                onPressed: () {},
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                key: TDElementKey("inkWell", properties: {"in123": "oooo"}),
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Text('Custom Button'),
                ),
              ),
              GestureDetector(
                key: TDElementKey("geust_key", properties: {"g_key": "dddd"}),
                onTap: () {},
                child: Text('Tap me'),
              )
            ],
          ),
          ListTile(
            title: Text('List Tile 123'),
            onTap: () {},
          ),
          Container(height: 200,
          child:ListView(
            children: [
              ListTile(
                title: Text('Item 1'),
                onTap: () {},
              ),
              Divider(),
              ListTile(
                title: Text('Item 2'),
                onTap: () {},
              ),
              Divider(),
              ListTile(
                title: Text('Item 3'),
                onTap: () {},
              ),
            ],
          ) )

        ],
      ),
    );
  }
}
