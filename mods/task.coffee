fs = require 'fs'
config = {}
try
    fileCon = fs.readFileSync 'config.json','utf-8'
    config = JSON.parse fileCon
catch e
    # ...

_gitPath = config.gitPath
taskPad = 
    select: (name,cmd,msg) ->
        _cmdStr = ''
        _path = config.task[name].path
        _src  = config.task[name].src
        switch cmd
            when 'gulp'
                _cmdStr = "cd #{_path} && cd build && gulp"
                break

            when 'status'
                _cmdStr = "cd #{_path} && #{_gitPath} status"
                break

            when 'push'
                _cmdStr = "cd #{_path} && #{_gitPath} add . && #{_gitPath} commit -m '#{msg}' && #{_gitPath} push"
                break

            when 'build'
                _cmdStr = "cd #{_path} && cd build && gulp --e dev"
                break

            when 'diff'
                _cmdStr = "cd #{_path} && #{_gitPath} diff #{_src}"
                break

            when 'checkout'
                _cmdStr = "cd #{_path} && #{_gitPath} checkout #{msg}"
                break

            when 'pull'
                _cmdStr = "cd #{_path} && #{_gitPath} pull origin #{msg}"
                break

            else
                _cmdStr = "cd #{_path} && #{_gitPath} status" 
                break

        return _cmdStr

module.exports = taskPad