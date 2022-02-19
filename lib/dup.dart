import 'dart:math';
import 'dart:async';

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();
const _length = 5;

String random() => String.fromCharCodes(Iterable.generate(
    _length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

Map dup() {
  Map dup = {'s': {}}, opt = {'max': 1000, 'age': 1000 * 9};

  dup['check'] = (String id) {
    return dup['s'][id] != null ? dup['track'](id) : -1;
  };

  dup['track'] = (String id) {
    dup['s'][id] = DateTime.now().millisecondsSinceEpoch;
    if (dup['to'] == null) {
      Timer.periodic(Duration(milliseconds: opt['age']), (Timer t) {
        for (var id in dup['s'].keys) {
          var time = dup['s'][id];
          if (opt['age'] > (DateTime.now().millisecondsSinceEpoch - time)) {
            return;
          }
          dup['s'].remove('id');
        }
      });
    }
    return id;
  };
  return dup;
}

