import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Convert extends StatefulWidget {
  const Convert({super.key});

  @override
  State<StatefulWidget> createState() => _ConvertState();
}

class _ConvertState extends State<Convert> {
  final rawText = TextEditingController();
  String decodeText = "";
  @override
  void dispose() {
    rawText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void notificationBar(snackBar) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    void trojanDecode() {
      String input = rawText.text;
      input = input.replaceAll('trojan://', '');
      List<String> getParams = input.split(RegExp('[@:?#]'));
      try {
        var filter = getParams[3];
        var keyValuePairs = filter.split('&');
        Map octMap = <String, String>{};
        for (var i = 0; i < keyValuePairs.length; i++) {
          List pair = keyValuePairs[i].split('=');
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
          accDecode.write('    ws-opts: ');
          accDecode.write('      path: ${octMap['path']}');
          accDecode.write('      headers: ');
          if (octMap['host'] != null) {
            accDecode.write('        Host: ${octMap['host']}');
          } else {
            accDecode.write('        Host: ${getParams[1]}');
          }
        } else if (octMap['type'] != null && octMap['type'] == 'grpc') {
          accDecode.write('    grpc-opts: ');
          if (octMap['serviceName'].toString().contains('#')) {
            accDecode.write(
                '      grpc-service-name: ${octMap['serviceName'].split('#')[0]}');
          } else {
            accDecode
                .write('      grpc-service-name: ${octMap['serviceName']}');
          }
        }
        accDecode.write('    udp: true');
        setState(() {
          decodeText = accDecode.toString();
        });
      } catch (e) {
        const snackBar =
            SnackBar(content: Text('an error occurs, check your config again'));
        notificationBar(snackBar);
      }
    }

    // String urlDecodeVMess(String uri) {
    //   final base64Decoder = base64.decoder;
    //   String base64Bytes = uri;
    //   final decodedBytes = base64Decoder.convert(base64Bytes);
    //   String decoded = utf8.decode(decodedBytes);
    //   return decoded;
    // }

    var width = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(title: const Text('Converter')),
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: TextFormField(
                controller: rawText,
                minLines: null,
                maxLines: null,
                decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            width: 3, color: Color.fromARGB(255, 0, 204, 105)),
                        borderRadius: BorderRadius.circular(20.0)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            width: 3, color: Colors.greenAccent),
                        borderRadius: BorderRadius.circular(20.0))),
              ),
            ),
            Row(children: const [
              Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Text('For now just support trojan'),
              ),
            ]),
            Container(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: width / 2 - 32,
                      child: OutlinedButton.icon(
                          onPressed: trojanDecode,
                          icon: const Icon(Icons.send),
                          label: const Text('Convert')),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: width / 2 - 32,
                      child: OutlinedButton.icon(
                          onPressed: () {
                            const snackBar =
                                SnackBar(content: Text('Copied to Clipboard'));
                            Clipboard.setData(ClipboardData(text: decodeText))
                                .then((value) => notificationBar(snackBar));
                          },
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy')),
                    ),
                  ],
                )),
            //
            Center(
              child: Container(
                margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                height: MediaQuery.of(context).size.height / 3,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.greenAccent, width: 3),
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                ),
                width: MediaQuery.of(context).size.width - 32,
                child: Center(
                  child: ListView(padding: const EdgeInsets.all(10), children: [
                    Text(
                      decodeText,
                    )
                  ]),
                ),
              ),
            ),
          ],
        ));
  }
}
