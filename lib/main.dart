import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:root/root.dart';
import './dashboard.dart';

void main() =>
    runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _runingStatus = false;
  String _btnStart = 'START';
  String _result = " ";
  bool _status = false;
  bool _statusAvailability = false;
  String _logs = "Kosong";
  Future<void> noRootAccess() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Root Access'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Please grant root access'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Exit'),
              onPressed: () {
                exit(0);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> checkRoot() async {
    bool? result = await Root.isRooted();
    setState(() {
      _status = result!;
    });
  }

  //Check Root availability
  Future<void> checkRootAvailability() async {
    bool? result = await Root.isRootAvailable();
    setState(() {
      _statusAvailability = result!;
    });
  }

  //Execute shell Commands
  Future<void> startService() async {
    String? res;
    res = await Root.exec(cmd: "ls /data/adb/modules/box_for_magisk");
    setState(() {
      _result = res!;
    });
    if (_result.contains('disable')) {
      res = await Root.exec(
          cmd: "rm -f /data/adb/modules/box_for_magisk/disable");
      setState(() {
        _result = res!;
      });
    } else {
      res = await Root.exec(
          cmd: "touch /data/adb/modules/box_for_magisk/disable");
      setState(() {
        _result = res!;
      });
    }
    isRuning();
  }

  Future<void> isRuning() async {
    String? res;
    res = await Root.exec(cmd: "ls /data/adb/modules/box_for_magisk");
    setState(() {
      _result = res!;
    });
    if (_result.contains('disable')) {
      setState(() {
        _runingStatus = false;
        _btnStart = 'START';
      });
    } else {
      setState(() {
        _runingStatus = true;
        _btnStart = 'STOP';
      });
    }
  }
  Future<void> Logs() async {
    String? log;
    log = await Root.exec(cmd: "cat /data/adb/box/run/runs.log");
    setState(() {
      _logs = log!;
    });
  }

  @override
  void initState() {
    super.initState();
    checkRoot();
    checkRootAvailability();
    isRuning();
    Timer mytimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      Logs();
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text('Box For Magisk')),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Text('Root Access : $_status'),
              ],
            ),
            Row(children: [
              Text('Status Service : $_runingStatus'),
            ]),
            Row(
              children: [
                OutlinedButton(
                    onPressed: startService,
                    child: SizedBox(
                      width: width / 2,
                      child: Center(
                          child: Text(
                        _btnStart,
                        style: const TextStyle(
                            fontSize: 20,
                            fontStyle: FontStyle.italic,
                            color: Colors.black54),
                      )),
                    )),
                const Spacer(),
                OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MyDashboard()));
                    },
                    icon: const Icon(Icons.desktop_mac,
                        size: 20, color: Colors.black),
                    label: const Text(
                      'DASHBOARD',
                      style: TextStyle(
                          fontSize: 20,
                          fontStyle: FontStyle.italic,
                          color: Colors.black54),
                    )),
              ],
            ),
            Row(
              children: [
                Container(
                  // color: Colors.black,
                  height: 600,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    color: Color.fromARGB(255, 32, 32, 32)
                  ),
                  width: MediaQuery.of(context).size.width - 32,
                  child: Center(
                    child: ListView(
                      padding: EdgeInsets.all(10),
                      children: [
                      Text(
                        _logs,
                        style: const TextStyle(color: Colors.white),
                      )
                    ]),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
