import 'dart:async';
import 'dart:convert';

import 'package:dartgun/dup.dart';
import "package:web_socket_channel/web_socket_channel.dart";

var _dup = dup();

Future<void> main(List<String> arguments) async {
  final channel = WebSocketChannel.connect(
    Uri.parse('ws://localhost:8080'),
  );
  var msg = {
    "#": _dup['track'](random()),
    'put': {
      'ASDF': {
        '_': {
          '#': 'ASDF',
          '>': {'name': 2, 'boss': 2}
        },
        'name': "Mark Nadal",
        'boss': {'#': 'FDSA'}
      },
      'FDSA': {
        '_': {
          '#': 'FDSA',
          '>': {'name': 2, 'species': 2, 'slave': 2}
        },
        'name': "Fluffy",
        'species': "a kitty",
        'slave': {'#': 'ASDF'}
      }
    }
  };
  channel.sink.add(json.encode(msg));

  msg = {
    "#": _dup['track'](random()),
    'put': {
      'ASDF': {
        '_': {
          '#': 'ASDF',
          '>': {'name': 1}
        },
        'name': "Mark",
      },
      'FDSA': {
        '_': {
          '#': 'FDSA',
          '>': {'species': 2, 'color': 3}
        },
        'species': "felis silvestris",
        'color': 'ginger'
      }
    }
  };

  Timer.periodic(Duration(seconds: 1), (Timer t) {
    print("Updating Data!");
    channel.sink.add(json.encode(msg));

    print('Getting Data');
    msg = {
      '#': _dup['track'](random()),
      'get': {'#': 'FDSA', '.': 'color'}
    };
    channel.sink.add(json.encode(msg));
  });

  // /// Listen for all incoming data
  channel.stream.listen(
    (data) {
      var msg = json.decode(data);
      // if(dup['check'](msg['#']) != -1){ return ;}
      _dup['track'](msg['#']);
      print('Data: $msg');
      channel.sink.add(data);
    },
    onError: (error) => print(error),
  );
}
