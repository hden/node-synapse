'use strict'

fs      = require 'fs'

_       = require 'underscore'
HAProxy = require 'haproxy'
{Bacon} = require 'baconjs'
Q       = require 'q'

{debug} = require "#{__dirname}/utils"

print   = debug 'haproxy'

preset =
  pidFile: "#{__dirname}/../tmp/haproxy.pid"
  config: "#{__dirname}/../tmp/haproxy.config"
  discover: true

exports.start = (options = {}) ->
  _.defaults options, preset

  haproxy = new HAProxy "#{__dirname}/../tmp/haproxy.sock", options

  # kill haproxy when SIGTERM or SIGINT
  terminate = (msg) ->
    print "terminating due to #{msg}"
    do haproxy.stop
    do process.exit

  process.on 'SIGTERM', _.partial terminate, 'SIGTERM'
  process.on 'SIGINT', _.partial terminate, 'SIGINT'

  hasStarted = false

  start = ->
    Bacon.fromCallback(haproxy, 'start').map (err) ->
      if err?
        print 'error while starting haproxy'
        new Bacon.Error err
      else
        hasStarted = true
        "successfully started"

  reload = ->
    Bacon.fromCallback(haproxy, 'reload').map (err) ->
      if err?
        print 'error while updating config file'
        new Bacon.Error err
      else
        "successfully reloaded"

  (config) ->
    print 'updating config'

    throw new Error 'invalid config' unless _.isString config
    print "writing #{options.config}"
    fs.writeFileSync options.config, config

    if hasStarted
      print 'restarting haproxy'
      do reload
    else
      print 'haproxy not started yet'
      do start

idx = 0

f = exports.start()

g = ->
  file = fs.readFileSync("#{__dirname}/../tmp/haproxy.config", 'utf-8') + """

  listen http-innn#{idx++}
      bind *:8080
      balance roundrobin
      option http-server-close

  """
  print 'time to reload'
  f(file).assign print

setInterval g, 10000
