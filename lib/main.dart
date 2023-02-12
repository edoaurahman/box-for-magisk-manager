import 'dart:async';
import 'package:box_for_magisk/src/custom_transition_widget.dart';
import 'package:box_for_magisk/src/decoder.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:root/root.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:process_run/shell.dart';

void main() =>
    runApp(const MaterialApp(debugShowCheckedModeBanner: true, home: MyApp()));

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  void getLaunchInBrowser(input) {
    _MyAppState()._launchInBrowser(input);
  }

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _runningStatus = false;
  String _btnStart = 'START';
  String? _selectedMode;
  late String _logs = "", _update = "";
  ButtonStyle _btnStartStyle =
      ElevatedButton.styleFrom(backgroundColor: Colors.blue);

  Future<void> noRootAccess() {
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
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchInBrowser(String input) async {
    Uri url = Uri.parse(input);
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      _notificationBar('Could not launch');
    }
  }

  void _notificationBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> aboutMenu() {
    late final handleTapGesture = TapGestureRecognizer();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('2023 Sing Box Manager\n'),
                RichText(
                    text: TextSpan(
                        text: '@edoaurahman',
                        style: const TextStyle(color: Colors.blue),
                        recognizer: handleTapGesture
                          ..onTap = () {
                            _launchInBrowser('https://t.me/edoaurahman');
                          }))
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                handleTapGesture.dispose();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> changeMode(String script) async {
    await Root.exec(cmd: script);
    _notificationBar('Mode has been changed, please restart the service');
  }

  Future<void> settingMenu() {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Text('Setting'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('Mode : '),
                            DropdownButton<String>(
                              value: _selectedMode,
                              onChanged: (value) {
                                setState(() {
                                  _selectedMode = value!;
                                });
                                changeMode(value!);
                              },
                              items: const [
                                DropdownMenuItem(
                                  value:
                                      "sed -i 's/bin_name=\$.*/bin_name=\$c/' /data/adb/box/settings.ini",
                                  child: Text('Clash'),
                                ),
                                DropdownMenuItem(
                                  value:
                                      "sed -i 's/bin_name=\$.*/bin_name=\$s/' /data/adb/box/settings.ini",
                                  child: Text('Sing Box'),
                                ),
                                DropdownMenuItem(
                                  value:
                                      "sed -i 's/bin_name=\$.*/bin_name=\$x/' /data/adb/box/settings.ini",
                                  child: Text('Xray'),
                                ),
                                DropdownMenuItem(
                                  value:
                                      "sed -i 's/bin_name=\$.*/bin_name=\$v/' /data/adb/box/settings.ini",
                                  child: Text('V2fly'),
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Ok'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
        });
  }

  Future<void> checkRoot() async {
    bool? result = await Root.isRooted();
    if (!result!) {
      noRootAccess();
    }
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
    String? result =
        await Root.exec(cmd: "ls /data/adb/modules/box_for_magisk");
    if (result!.contains('disable')) {
      setState(() {
        _runningStatus = false;
        _btnStart = 'START';
        _btnStartStyle = ElevatedButton.styleFrom(backgroundColor: Colors.blue);
      });
    } else {
      setState(() {
        _runningStatus = true;
        _btnStart = 'STOP';
        _btnStartStyle = ElevatedButton.styleFrom(backgroundColor: Colors.red);
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

  Future<void> updateBox() async {
    ShellLinesController controller = ShellLinesController();
    Shell shell = Shell(stdout: controller.sink, verbose: false);
    controller.stream.listen((event) {
      setState(() {
        _update = event;
      });
    });
    try {
      await shell.run('su -c ./data/adb/box/scripts/box.tool upcore');
      await shell.run('su -c ./data/adb/box/scripts/box.tool upyacd');
      await shell.run('su -c ./data/adb/box/scripts/box.tool subgeo');
      setState(() {
        _update = "Updated";
      });
      shell.kill();
      controller.close();
    } on ShellException catch (e) {
      _notificationBar(e.toString());
    }
  }

  Future<void> getMode() async {
    String mode = " ";
    mode = await Root.exec(
            cmd: 'cat /data/adb/box/settings.ini | grep "bin_name="') ??
        "";
    mode = mode.split('\$')[1];
    if (mode.contains('c')) {
      setState(() {
        _selectedMode =
            "sed -i 's/bin_name=\$.*/bin_name=\$c/' /data/adb/box/settings.ini";
      });
    } else if (mode.contains('s')) {
      setState(() {
        _selectedMode =
            "sed -i 's/bin_name=\$.*/bin_name=\$s/' /data/adb/box/settings.ini";
      });
    } else if (mode.contains('x')) {
      setState(() {
        _selectedMode =
            "sed -i 's/bin_name=\$.*/bin_name=\$x/' /data/adb/box/settings.ini";
      });
    } else if (mode.contains('v')) {
      setState(() {
        _selectedMode =
            "sed -i 's/bin_name=\$.*/bin_name=\$v/' /data/adb/box/settings.ini";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getMode();
    checkRoot();
    isRunning();
    Timer.periodic(const Duration(seconds: 1), (e) {
      logs();
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void handleClick(int item) {
    switch (item) {
      case 0:
        settingMenu();
        break;
      case 1:
        aboutMenu();
        break;
      case 2:
        SystemNavigator.pop();
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    double? width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Box For Magisk'),
        actions: <Widget>[
          PopupMenuButton<int>(
            onSelected: (item) => handleClick(item),
            itemBuilder: (context) => [
              const PopupMenuItem<int>(value: 0, child: Text('Setting')),
              const PopupMenuItem<int>(value: 1, child: Text('About')),
              const PopupMenuItem<int>(value: 2, child: Text('Exit')),
            ],
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                color: Colors.teal[300],
                elevation: 5,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.dashboard, size: 50),
                      title: const Text('STATUS',
                          style: TextStyle(color: Colors.white)),
                      subtitle: Text(_runningStatus ? 'RUNNING' : 'STOPPED',
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  SizedBox(
                      width: width / 2 - 32,
                      child: ElevatedButton.icon(
                        style: _btnStartStyle,
                        onPressed: startService,
                        icon: const Icon(Icons.play_arrow,
                            size: 25, color: Colors.white),
                        label: Text(_btnStart,
                            style: const TextStyle(
                                fontSize: 20,
                                fontStyle: FontStyle.italic,
                                color: Colors.white)),
                      )),
                  const Spacer(),
                  SizedBox(
                      width: width / 2 - 32,
                      child: OutlinedButton.icon(
                          onPressed: () {
                            _launchInBrowser('http://127.0.0.1:9090/ui');
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
                            _launchInBrowser('https://speedtest.net');
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
                          onPressed: () => updateBox(),
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
                          onPressed: () => _launchInBrowser('https://howdy.id'),
                          icon: const Icon(Icons.person_add_alt,
                              size: 20, color: Colors.black),
                          label: Text(
                            'CREATE ACCOUNT',
                            style: TextStyle(
                                fontSize: width * 0.03 > 20 ? 20 : width * 0.03,
                                fontStyle: FontStyle.italic,
                                color: Colors.black54),
                          ))),
                  const Spacer(),
                  SizedBox(
                      width: width / 2 - 32,
                      child: OutlinedButton.icon(
                          onPressed: () {
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => const Convert()));
                            Navigator.of(context).push(
                                CustomRouteTransition(widget: const Convert()));
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
              Container(
                height: MediaQuery.of(context).size.height / 2.5,
                decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    color: const Color.fromARGB(255, 32, 32, 32)),
                width: MediaQuery.of(context).size.width - 32,
                child: ListView(padding: const EdgeInsets.all(10), children: [
                  const Text('Clash Log',
                      style: TextStyle(color: Colors.redAccent)),
                  Text(
                    _logs,
                    style: const TextStyle(color: Colors.white),
                  )
                ]),
              ),

              Container(
                margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                height: 70,
                decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    color: const Color.fromARGB(255, 32, 32, 32)),
                width: MediaQuery.of(context).size.width - 32,
                child: ListView(padding: const EdgeInsets.all(10), children: [
                  const Text('Update Log',
                      style: TextStyle(color: Colors.redAccent)),
                  Text(
                    _update,
                    style: const TextStyle(color: Colors.white),
                  )
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
