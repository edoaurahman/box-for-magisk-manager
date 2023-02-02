import 'package:flutter/material.dart';

class Convert extends StatefulWidget {
  const Convert({super.key});

  @override
  State<StatefulWidget> createState() => _ConvertState();
}

Future<void> convert(String account) async {
  try {
    // Map<String, String> params = Stream.of(account)

  } catch (e) {}
}

class _ConvertState extends State<Convert> {
  final myController = TextEditingController();

  void dispose() {
    myController.dispose();
    super.dispose();
  }

  void _printLatestValue() {
    print('Text Field: ${myController.text}');
  }

  void initState() {
    super.initState();
    myController.addListener(_printLatestValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Converter')),
        body: 
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: myController,
                    ),
                  )
                ],
              )
        );
  }
}
