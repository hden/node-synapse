'use strict'

{exec} = require 'child_process'
stream = require 'stream'

_      = require 'underscore'
debug  = require 'debug'
Q      = require 'q'

print  = debug 'serf'


class Readline extends stream.Transform
  constructor: ->
    super
    @_cache = ''
  _transform: (chunk, encoding = 'utf-8', done) =>
    @_cache += chunk.toString encoding
    [lines..., @_cache] = @_cache.split '\n'
    lines.forEach @push.bind @
    do done

class Parser extends stream.Transform
  constructor: ->
    super
    @_readableState.objectMode = true
    @_writableState.objectMode = true
  _transform: (line, encoding = 'utf-8', done) =>
    line = line.toString encoding
    if line.match 'EventMember'
      @push exports.members()
    do done

execPromise = (command) ->
  deferred = do Q.defer
  exec command, (err, stdout, stderr) ->
    if err?
      print "node err: #{err}"
      deferred.reject err
    if stderr.length > 0
      print "stderr: #{stderr}"
      deferred.reject stderr

    print "stdout: #{stdout}"
    deferred.resolve stdout

  deferred.promise

exports.start = (options = {}) ->
  preset =
    node: 'nobody'
    role: 'minion'
    bind: '0.0.0.0:7946'
    encrypt: 'yvaS3kB4u9t164qpsOYitQ=='

  _.defaults options, preset

  flags = _.map options, (v, k) ->
    "-#{k} #{v} "

  Q.when exec "serf agent #{flags.join('')}"

exports.members = (options = '-status alive') ->
  print 'members'
  deferred = do Q.defer
  execPromise("serf members #{options}").then (stdout) ->
    _.chain(stdout.split('\n'))
    .compact()
    .map (line) ->
      [name, address, status, role] = line.split /\ +/
      {name, address, status, role}
    .value()

exports.leave = ->
  execPromise 'serf leave'

exports.join = (address = '') ->
  execPromise "serf join #{address}"

exports.event = (event = 'test', payload = '') ->
  payload = JSON.stringify payload unless _.isString payload
  execPromise "serf event #{event} #{payload}"

exports.start().done ({stdout}) ->
  readline = new Readline()
  parser = new Parser()
  stdout.pipe(readline).pipe(parser).on 'data', (promise) ->
    promise.then (d) ->
      print JSON.stringify d, null, 4

setTimeout exports.leave, 3000
