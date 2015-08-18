http = require 'http'
fs = require 'fs'
url = require 'url'
path = require 'path'
mime = require 'mime-types'


err404 = (res)->
    res.writeHead 404, {"Content-Type": "text/html"}
    res.end "<h1>404 Read Error</h1>"

createHttp = (port,root,cb) ->
    webHttp = http.createServer (req,res)->
        reqUrl = req.url
        pathName = url.parse(reqUrl).pathname #使用url解析模块获取url中的路径名
        ext = path.extname pathName  #获取url后缀

        #判断最后一个字符 如果是'/' 那么就表示访问目录
        if pathName.charAt(pathName.length - 1) is '/'
            pathName += 'index.html' #指定为默认网页

        filePath = path.join root,pathName #找出文件路径
        stream = '' #字节流数据

        #如果是请求config.json
        if pathName is '/config.json'
            filePath = 'config.json'

        #返回数据  

        #判断文件是否存在
        if fs.existsSync(filePath)
            res.writeHead 200,{'Content-Type': mime.lookup(filePath)}
            stream = fs.createReadStream(filePath, {flags : "r", encoding : null})#只读模式 读取文件内容

            #如果读取错误 返回404
            stream.on 'error',->
                err404 res
            

            stream.pipe res #连接文件流和http返回流的管道,用于返回实际Web内容
        else
            err404 res
    

    #错误调试
    webHttp.on 'error',(e)->
        console.log e.message

    webHttp.listen port#不输入第二个参数则表示 本机IP  127.0.0.1  localhost都能够访问
    #webHttp.listen(port, '127.0.0.1');   
    #填写IP（127.0.0.1）时只表示在浏览器中输入 127.0.0.1 才能运行

    cb()#执行回调方法

    return webHttp

module.exports = createHttp