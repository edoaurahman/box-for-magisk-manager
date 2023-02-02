import 'dart:io';
import 'dart:async';
import 'package:box_for_magisk/src/decoder.dart';
import 'package:flutter/material.dart';
import 'package:root/root.dart';
import './web_view.dart';
import 'package:process_run/shell.dart';

void main() =>
    runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _runningStatus = false;
  String _btnStart = 'START';
  String? _result;
  bool _status = false;
  String _logs = "", _update = "";

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

  //Execute shell Commands
  Future<void> startService() async {
    if (!_runningStatus) {
      await Root.exec(cmd: "rm -f /data/adb/modules/box_for_magisk/disable");
    } else {
      await Root.exec(cmd: "touch /data/adb/modules/box_for_magisk/disable");
    }
    isRunning();
  }

  Future<void> isRunning() async {
    String? res;
    res = await Root.exec(cmd: "ls /data/adb/modules/box_for_magisk");
    setState(() {
      _result = res!;
    });
    if (_result!.contains('disable')) {
      setState(() {
        _runningStatus = false;
        _btnStart = 'START';
      });
    } else {
      setState(() {
        _runningStatus = true;
        _btnStart = 'STOP';
      });
    }
  }

  Future<void> logs() async {
    String? log;
    log = await Root.exec(cmd: "cat /data/adb/box/run/runs.log");
    setState(() {
      _logs = log!;
    });
  }

  Future<void> updateClash() async {
    var controller = ShellLinesController();
    var shell = Shell(stdout: controller.sink, verbose: false);
    controller.stream.listen((event) {
      setState(() {
        _update = event;
      });
      shell.kill();
    });
    try {
      await shell.run('su -c ./data/adb/box/scripts/box.tool upcore');
      setState(() {
        _update = "Core Updated";
      });
    } on ShellException catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    checkRoot();
    isRunning();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      logs();
    });
  }

  void handleClick(int item) {
    exit(0);
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Box For Magisk'),
        actions: <Widget>[
          PopupMenuButton<int>(
            onSelected: (item) => handleClick(item),
            itemBuilder: (context) => [
              const PopupMenuItem<int>(value: 0, child: Text('Exit')),
            ],
          ),
        ],
      ),
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
              Text('Status Service : $_runningStatus'),
            ]),

            //Button
            Row(
              children: [
                SizedBox(
                    width: width / 2 - 32,
                    child: OutlinedButton.icon(
                      onPressed: startService,
                      icon: const Icon(Icons.play_arrow,
                          size: 25, color: Colors.black),
                      label: Text(
                        _btnStart,
                        style: const TextStyle(
                            fontSize: 20,
                            fontStyle: FontStyle.italic,
                            color: Colors.black54),
                      ),
                    )),
                const Spacer(),
                SizedBox(
                    width: width / 2 - 32,
                    child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const WebView(
                                      'http://127.0.0.1:9090/ui',
                                      'DASHBOARD')));
                        },
                        icon: const Icon(Icons.desktop_mac_outlined,
                            size: 20, color: Colors.black),
                        label: const Text(
                          'DASHBOARD',
                          style: TextStyle(
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                              color: Colors.black54),
                        ))),
              ],
            ),
            Row(
              children: [
                SizedBox(
                    width: width / 2 - 32,
                    child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const WebView(
                                      'https://speedtest.net', 'SPEEDTEST')));
                        },
                        icon: const Icon(Icons.speed_outlined,
                            size: 20, color: Colors.black),
                        label: const Text(
                          'SPEEDTEST',
                          style: TextStyle(
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                              color: Colors.black54),
                        ))),
                const Spacer(),
                SizedBox(
                    width: width / 2 - 32,
                    child: OutlinedButton.icon(
                        onPressed: () {
                          updateClash();
                        },
                        icon: const Icon(Icons.update_outlined,
                            size: 20, color: Colors.black),
                        label: const Text(
                          'UPDATE',
                          style: TextStyle(
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                              color: Colors.black54),
                        ))),
              ],
            ),
            Row(
              children: [
                SizedBox(
                    width: width / 2 - 32,
                    child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const WebView(
                                      'https://howdy.id', 'CREATE ACCOUNT')));
                        },
                        icon: const Icon(Icons.person_add_alt,
                            size: 20, color: Colors.black),
                        label: const Text(
                          'CREATE ACCOUNT',
                          style: TextStyle(
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                              color: Colors.black54),
                        ))),
                const Spacer(),
                SizedBox(
                    width: width / 2 - 32,
                    child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Convert()));
                        },
                        icon: const Icon(Icons.change_circle_outlined,
                            size: 20, color: Colors.black),
                        label: const Text(
                          'CONVERTER',
                          style: TextStyle(
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                              color: Colors.black54),
                        ))),
              ],
            ),

            // Logs
            Row(
              children: [
                Container(
                  // color: Colors.black,
                  height: MediaQuery.of(context).size.height / 2.5,
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      color: const Color.fromARGB(255, 32, 32, 32)),
                  width: MediaQuery.of(context).size.width - 32,
                  child: Center(
                    child:
                        ListView(padding: const EdgeInsets.all(10), children: [
                      const Text('Clash Log',
                          style: TextStyle(color: Colors.redAccent)),
                      Text(
                        _logs,
                        style: const TextStyle(color: Colors.white),
                      )
                    ]),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  height: MediaQuery.of(context).size.height / 5,
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      color: const Color.fromARGB(255, 32, 32, 32)),
                  width: MediaQuery.of(context).size.width - 32,
                  child: Center(
                    child:
                        ListView(padding: const EdgeInsets.all(10), children: [
                      const Text('Update Log',
                          style: TextStyle(color: Colors.redAccent)),
                      Text(
                        _update,
                        style: const TextStyle(color: Colors.white),
                      )
                    ]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
