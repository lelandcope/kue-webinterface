kue     = require 'kue'
express = require 'express'
auth    = require 'basic-auth'
program = require 'commander'


program
    .version('1.0.0')
    .option('-l, --local-testing', 'Removes the need for a username and password.')
    .option('-p, --password [password]', 'Set the basic auth password.')
    .option('-u, --user [user]', 'Set the basic auth username.')
    .option('--port [port]', 'Set the port the app will listen on. Defaults to 3011')
    .option('--redis-auth [password]', 'The Redis AUTH password.')
    .option('--redis-host [host]', 'The Redis host address. Defaults to 127.0.0.1.')
    .option('--redis-port [port]', 'The Redis port. Defaults to 6379.')
    .parse(process.argv)


app         = express()
username    = program.user or 'august'
password    = program.password or 'development'

jobs    = kue.createQueue(
    redis:
        port: program.redisPort or 6379
        host: program.redisHost or '127.0.0.1'
        auth: program.redisAuth if program.redisAuth
)

app.use (req, res, next)->
    return next() if program.localTesting

    user = auth(req)

    if user and user.name is username and  user.pass is password
        return next()
    else
        res.set 'WWW-Authenticate', 'Basic realm=Authorization Required'
        return res.send 401

app.use kue.app

kue.app.set 'title', 'August Kue System'

app.listen program.port or 3011
