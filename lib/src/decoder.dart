import 'dart:convert';
import 'package:box_for_magisk/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Convert extends StatefulWidget {
  const Convert({super.key});

  @override
  State<StatefulWidget> createState() => _ConvertState();
}

class _ConvertState extends State<Convert> {
  final MyApp callback = const MyApp();
  final rawText = TextEditingController();
  String decodeText = "";

  @override
  void dispose() {
    rawText.dispose();
    super.dispose();
  }

  void trojanDecode(String input) {
    input = urlDecode(input);
    List<String> getParams = input.split(RegExp('[@:?#]'));
    try {
      var filter = getParams[3];
      var keyValuePairs = filter.split('&');
      Map octMap = <String, String>{};
      for (var i in keyValuePairs) {
        List pair = i.split('=');
        octMap[pair[0]] = pair[1];
      }
      var accDecode = StringBuffer();
      accDecode.write(
          '- name: ${getParams.length >= 5 ? getParams[4] : 'Simple-sub'}\n');
      accDecode.write('    server: ${getParams[1]}\n');
      accDecode.write('    port: ${getParams[2].replaceAll('/', '')}\n');
      accDecode.write('    type: trojan\n');
      accDecode.write('    password: ${getParams[0]}\n');
      accDecode.write('    skip-cert-verify: true\n');
      if (octMap['sni'] != null) {
        accDecode.write('    sni: ${octMap['sni']}\n');
      } else {
        accDecode.write('    sni: ${getParams[1]}\n');
      }
      accDecode.write('    network: ${octMap['type']}\n');
      if (octMap['type'] != null && octMap['type'] == "ws") {
        accDecode.write('    ws-opts: \n');
        accDecode.write('      path: ${octMap['path']}\n');
        accDecode.write('      headers: \n');
        if (octMap['host'] != null) {
          accDecode.write('        Host: ${octMap['host']}\n');
        } else {
          accDecode.write('        Host: ${getParams[1]}\n');
        }
      } else if (octMap['type'] != null && octMap['type'] == 'grpc') {
        accDecode.write('    grpc-opts: \n');
        if (octMap['serviceName'].toString().contains('#')) {
          accDecode.write(
              '      grpc-service-name: ${octMap['serviceName'].split('#')[0]}\n');
        } else {
          accDecode
              .write('      grpc-service-name: ${octMap['serviceName']}\n');
        }
      }
      accDecode.write('    udp: true');
      setState(() {
        decodeText = accDecode.toString();
      });
    } catch (e) {
      notificationBar('an error occurs, check your config again');
    }
  }

  Future<void> vmessDecode(String input) async {
    var decodeMap = urlBase64Decode(input);
    try {
      var accDecode = StringBuffer();
      accDecode.write('- name: ${decodeMap!['ps']}\n');
      accDecode.write('    server: ${decodeMap['add']}\n');
      accDecode.write('    port: ${decodeMap['port']}\n');
      accDecode.write('    type: vmess\n');
      accDecode.write('    uuid: ${decodeMap['id']}\n');
      accDecode.write('    alterid: ${decodeMap['aid']}\n');
      accDecode.write('    cipher: ${decodeMap['scy']}\n');
      if (decodeMap['tls'] != null) {
        String isTls = decodeMap['tls'] == 'tls' ? 'true' : 'false';
        accDecode.write('    tls: $isTls\n');
        accDecode.write('    skip-cert-verify: $isTls\n');
      } else {
        accDecode.write('    tls: none\n');
        accDecode.write('    skip-cert-verify: false\n');
      }
      if (decodeMap.containsKey('sni')) {
        accDecode.write('    servername: ${decodeMap['sni']}\n');
      } else {
        accDecode.write('    servername: ${decodeMap['host']}\n');
      }
      if (decodeMap['net'] == 'ws') {
        accDecode.write('    network: ${decodeMap['net']}\n');
        accDecode.write('    ws-opts: \n');
        accDecode.write('      path: ${decodeMap['path']}\n');
        accDecode.write('      headers: \n');
        accDecode.write('        Host: ${decodeMap['host']}\n');
      } else if (decodeMap['net'] == 'grpc') {
        accDecode.write('    network: ${decodeMap['net']}\n');
        accDecode.write('    grpc-opts: \n');
        accDecode.write('      grpc-service-name: ${decodeMap['path']}\n');
      }
      accDecode.write('    udp: true');
      setState(() {
        decodeText = accDecode.toString();
      });
    } catch (e) {
      notificationBar('an error occurs, check your config again');
    }
  }
  Future<void> vlessDecode(String input) async {
    input = urlDecode(input);
    List<String> getParams = input.split(RegExp('[@:?#]'));

    try {
      var filter = getParams[3];
      var keyValuePairs = filter.split('&');
      Map octMap = <String, String>{};
      for (var i in keyValuePairs) {
        List pair = i.split('=');
        octMap[pair[0]] = pair[1];
      }
      print(octMap);
      print(getParams);
      var accDecode = StringBuffer();
      accDecode.write('- name: ${getParams[4]}\n');
      accDecode.write('    server: ${getParams[1]}\n');
      accDecode.write('    port: ${getParams[2]}\n');
      accDecode.write('    type: vless\n');
      accDecode.write('    uuid: ${getParams[0]}\n');
      accDecode.write('    cipher: auto\n');
      if (octMap['security'] != null && octMap['security'] =='tls') {
        accDecode.write('    tls: true\n');
      } else {
        accDecode.write('    tls: false\n');
      }
      accDecode.write('    skip-cert-verify: true\n');
      if (octMap['sni'] != null) {
        accDecode.write('    servername: ${octMap['sni']} \n');
      } else {
        accDecode.write('    servername: ${getParams[1]}\n');
      }
      accDecode.write('    network: ${octMap['type']}\n');
      if (octMap['type'].startsWith('grpc')) {
        accDecode.write('    grpc-opts: \n');
        accDecode.write('      grpc-service-name: ${octMap['serviceName']}\n');
      } else {
        accDecode.write('    ws-opts: \n');
        accDecode.write('      path: ${octMap['path']}\n');
        accDecode.write('      headers: \n');
        if (octMap['host'] != null) {
          accDecode.write('        Host: ${octMap['host']})\n');
        } else {
          accDecode.write('        Host: ${getParams[1]}\n');
        }
      }
      accDecode.write("    udp: true");
      setState(() {
        decodeText = accDecode.toString();
      });
    } catch (e) {
      notificationBar('an error occurs, check your config again');
    }
  }

  void notificationBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Map? urlBase64Decode(String uri) {
    try {
      var encodedString = uri;
      var decodedString = base64.decode(encodedString);
      var decodedMap = json.decode(utf8.decode(decodedString));
      return decodedMap;
    } catch (e) {
      notificationBar('Error, please check again');
      return null;
    }
  }

  String urlDecode(String input) {
    return Uri.decodeFull(input);
  }

  Future<void> checkTypeConfig() async {
    String input = rawText.text;
    String type = input.split(':')[0];
    if (input.isEmpty) notificationBar('Empty');
    if (type == 'trojan') {
      input = input.replaceAll('trojan://', '');
      trojanDecode(input);
    } else if (type == 'vmess') {
      input = input.replaceAll('vmess://', '');
      vmessDecode(input);
    } else if (type == 'vless') {
      input = input.replaceAll('vless://', '');
      vlessDecode(input);
    } else {
      notificationBar('Not Support For Now');
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(title: const Text('Converter')),
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextFormField(
                    controller: rawText,
                    minLines: null,
                    maxLines: null,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                width: 3, color: Colors.blueAccent),
                            borderRadius: BorderRadius.circular(20.0)),
                        enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                width: 3, color: Colors.blueAccent),
                            borderRadius: BorderRadius.circular(20.0))),
                  ),
                  const Text(
                    'Clash Only (For now just support trojan and vmess)',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: width / 2 - 32,
                        child: OutlinedButton.icon(
                            onPressed: checkTypeConfig,
                            icon: const Icon(Icons.send),
                            label: const Text('Convert')),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: width / 2 - 32,
                        child: OutlinedButton.icon(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: decodeText))
                                  .then((value) =>
                                      notificationBar('Copied to Clipboard'));
                            },
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy')),
                      ),
                    ],
                  ),
                  ElevatedButton(
                      onPressed: () {
                        callback.getLaunchInBrowser('https://t.me/subxfm_bot');
                      },
                      child: const Text('Telegram Bot(Sing-box/xray)')),
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    height: MediaQuery.of(context).size.height / 3,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent, width: 3),
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                    ),
                    width: MediaQuery.of(context).size.width - 32,
                    child:
                        ListView(padding: const EdgeInsets.all(10), children: [
                      Text(
                        decodeText,
                      )
                    ]),
                  ),
                ],
              )),
        ));
  }
}
