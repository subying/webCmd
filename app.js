// Generated by CoffeeScript 1.9.3
var _execObj, _fdir, _port, createHttp, exec, io, taskPad, webSr;

exec = require("child_process").exec;

createHttp = require('./web');

taskPad = require('./mods/task');

_port = 88;

_fdir = __dirname + '/html/';

_execObj = {};

webSr = createHttp(_port, _fdir, function() {
  return console.log('all is ok!');
});

io = require('socket.io')(webSr);

io.on('connection', function(socket) {
  console.log('one connection');
  return socket.on('exec', function(msg) {
    var _arr, _carr, _child, _cmd, _cmdGulp, _execName, _logName, _msg, _name;
    _arr = msg.split('|');
    _name = _arr[0];
    if (_arr[1].indexOf('-') > -1) {
      _carr = _arr[1].match(/([^-]*)-(.*)/);
      _cmd = _carr[1];
      _msg = _carr[2];
    } else {
      _cmd = _arr[1];
      _msg = '';
    }
    if (!_name || !_cmd) {
      return false;
    }
    _child = _execObj[_name] || {};
    _execName = "exec-" + _name;
    _logName = "log-" + _name;
    if (_child.kill && (_cmd === 'gulp' || _cmd === 'build')) {
      _child.kill();
      console.log("kill " + _name);
    }
    _cmdGulp = taskPad.select(_name, _cmd, _msg);
    socket.emit(_execName, _cmdGulp);
    _execObj[_name] = exec(_cmdGulp, function(error, stdout, stderr) {
      if (error) {
        socket.emit(_logName, error.toString('utf-8'));
        return console.log(error);
      }
    });
    return _execObj[_name].stdout.on('data', function(_data) {
      return socket.emit(_logName, _data);
    });
  });
});
