import 'dart:convert';

Map _ham(
    machineState, incomingState, currentState, incomingValue, currentValue) {
  if (machineState < incomingState) {
    return {'defer': true};
  }
  if (incomingState < currentState) {
    return {'historical': true};
  }
  if (currentState < incomingState) {
    return {'converge': true, 'incoming': true};
  }
  if (incomingState == currentState) {
    incomingValue = json.encode(incomingValue);
    currentValue = json.encode(currentValue);
    if (incomingValue.compareTo(currentValue) == 0) {
      return {'state': true};
    }
    if (incomingValue.compareTo(currentValue) < 0) {
      return {'converge': true, 'current': true};
    }
    if (incomingValue.compareTo(currentValue) > 0) {
      return {'converge': true, 'incoming': true};
    }
  }
  return {
    'err': "Invalid CRDT Data: " +
        incomingValue +
        " to " +
        currentValue +
        " at " +
        incomingState +
        " to " +
        currentState +
        "!"
  };
}

mix(change, graph) {
  var machine = (DateTime.now().millisecondsSinceEpoch);
  Map<dynamic, dynamic> diff = {};
  change.keys.forEach((soul) {
    var node = change[soul];
    node.keys.forEach((key) {
      var val = node[key];
      if ('_' == key) {
        return;
      }

      var state = node["_"]['>'][key];
      var was = (graph[soul] ??
              {
                '_': {'>': {}}
              })["_"]['>'][key] ??
          -1;
      var known = (graph[soul] ?? {})[key];
      var ham = _ham(machine, state, was, val, known);
      if (ham['incoming'] == null) {
        if (ham['defer'] != null) {
          print("DEFER $key $val");
          // you'd need to implement this yourself.
        }
        return;
      }

      diff[soul] = diff[soul] ??
          {
            '_': {'#': soul, '>': {}}
          };
      graph[soul] = graph[soul] ??
          {
            '_': {'#': soul, '>': {}}
          };

      graph[soul] = {
        ...graph[soul],
        ...{key: val}
      };
      diff[soul] = {
        ...diff[soul],
        ...{key: val}
      };
      graph[soul]["_"]['>'][key] = diff[soul]["_"]['>'][key] = state;
    });
  });
  return diff;
}

get(lex, graph) {
  var soul = lex['#'];
  var key = lex['.'];
  var node = graph[soul];
  var tmp;
  if (node == null) {
    return;
  }
  if (key != null) {
    tmp = node[key];
    if (tmp == null) {
      return;
    }
    (node = {'_': node['_']})[key] = tmp;
    tmp = node['_']['>'];
    (node['_']['>'] = {})[key] = tmp[key];
  }
  var ack = {};
  ack[soul] = node;
  return ack;
}
