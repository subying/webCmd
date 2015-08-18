exec = require("child_process").exec
createHttp = require './web'
taskPad = require './mods/task'
_port = 88
_fdir = __dirname + '/html/'
_execObj = {}


webSr = createHttp _port,_fdir,->
    console.log 'all is ok!'

io = require('socket.io')(webSr)
io.on 'connection',(socket)->
    console.log 'one connection'

    socket.on 'exec',(msg)->
        _arr = msg.split '|'
        _name = _arr[0]
        if _arr[1].indexOf('-')>-1
            _carr = _arr[1].match(/([^-]*)-(.*)/)
            _cmd = _carr[1]
            _msg = _carr[2]
        else
            _cmd = _arr[1]
            _msg = ''

        if not _name or not _cmd
            return false

        _child = _execObj[_name] or {}
        _execName = "exec-#{_name}" #执行名称输出
        _logName = "log-#{_name}" #执行日志输出

        if _child.kill and (_cmd is 'gulp' or _cmd is 'build')
            _child.kill()
            console.log "kill #{_name}"

        _cmdGulp = taskPad.select _name,_cmd,_msg  #获取命令

        socket.emit _execName,_cmdGulp #输出运行命令

        #执行命令
        _execObj[_name] = exec _cmdGulp,(error, stdout, stderr)->
            if error
                socket.emit _logName,error.toString('utf-8')
                console.log error

        _execObj[_name].stdout.on 'data',(_data)->
            socket.emit _logName,_data