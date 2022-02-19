import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'dup.dart';
import 'ham.dart';

var _dup = dup();

var peers = [];
Map graph = {};

Future<bool> startServer(String host, int port) async {
  HttpServer server = await HttpServer.bind(host, port);
  server.transform(WebSocketTransformer()).listen(onWebSocketData);
  return true;
}

String prettyJson(dynamic json) {
  var spaces = ' ' * 4;
  var encoder = JsonEncoder.withIndent(spaces);
  return encoder.convert(json);
}

void onWebSocketData(WebSocket client) {
  peers.add(client);

  // var count = 0;
  // Timer.periodic(Duration(seconds:1), (Timer t) {
  //   count += 1;
  //   var msg = {
  // 		'#': _dup['track'](count)
  // 	};
  //   client.add(json.encode(msg));
  // });

  client.listen((data) {
    var msg = json.decode(data);
    if (_dup['check'](msg['#']) != -1) {
      return;
    }
    _dup['track'](msg['#']);
    // print('Received: ${prettyJson(msg)}');
    if (msg['put'] != null) {
      mix(msg['put'], graph);
      // print("----------------");
      // print(prettyJson(graph));
    }
    if (msg['get'] != null) {
      var ack = get(msg['get'], graph);
      ack = json
          .encode({'#': _dup['track'](random()), '@': msg['#'], 'put': ack});
      client.add(ack);
    }
    // for (var peer in peers) {
    //   try {
    //     peer.add(data);
    //   } catch (e) {}
    // }
  });
}
