'use strict'

fs      = require 'fs'

_       = require 'underscore'
HAProxy = require 'haproxy'
Q       = require 'q'

{debug} = require "#{__dirname}/utils"

print   = debug 'haproxy'

exports.start = (options = {}, done) ->

  if _.isFunction options
    done = options
    options = {}

  preset =
    pidFile: "#{__dirname}/../tmp/haproxy.pid"
    config: "#{__dirname}/../tmp/haproxy.config"
    discover: true

  _.defaults options, preset

  haproxy = new HAProxy "#{__dirname}/../tmp/haproxy.sock", options

  # kill haproxy when SIGTERM or SIGINT
  terminate = (msg) ->
    print msg
    do haproxy.stop
    do process.exit

  process.on 'SIGTERM', _.partial terminate, 'SIGTERM'
  process.on 'SIGINT', _.partial terminate, 'SIGINT'

  Q.ninvoke(haproxy, 'start').then ->
    haproxy

writeAndReload = (configFile) ->
  throw new Error 'invalid haproxy config file' unless _.isString configFile

  fs.writeFileSync preset.config, configFile
  Q.ninvoke(haproxy, 'reload').then () ->
    print 'reload'
    haproxy

exports.writeAndReload = _.throttle writeAndReload, 60 * 1000 # 1 minute
