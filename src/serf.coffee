'use strict'

{exec}  = require 'child_process'
stream  = require 'stream'

_       = require 'underscore'
{Bacon} = require 'baconjs'
Q       = require 'q'

{debug} = require "#{__dirname}/utils"

print   = debug 'serf'

preset =
  node: 'agent-two'
  role: 'minion'
  bind: '127.0.0.1:7947'
  'rpc-addr': '127.0.0.1:7374'

parameters = [
  'node'
  'role'
  'bind'
  'encrypt'
  'event-handler'
  'join'
  'snapshot'
]

class Readline extends stream.Transform
  constructor: ->
    super
    @_cache = ''
  _transform: (chunk, encoding = 'utf-8', done) =>
    @_cache += chunk.toString encoding
    [lines..., @_cache] = @_cache.split '\n'
    lines.forEach @push.bind @
    do done

execBacon = (command = '') ->
  Bacon.fromNodeCallback exec, command

exports.start = (options = {}) ->

  preset[k] = v for k, v of options when k in parameters

  flags = _.map preset, (v, k) ->
    "-#{k}=#{v}"

  {stdout, stderr} = exec "serf agent #{flags.join(' ')}"

  stream = stdout.pipe new Readline {encoding: 'utf-8'}

  Bacon.fromEventTarget(stream, 'data')
  .filter (line) ->
    line.match 'Received event: member-'
  .flatMapLatest (line) ->
    exports.members()
  .skipDuplicates(_.isEqual)

exports.members = (options = '-status alive') ->
  print 'members'
  execBacon("serf members -rpc-addr #{preset['rpc-addr']} #{options}").map (stdout) ->
    _.chain(stdout.split('\n'))
    .compact()
    .map (line) ->
      [name, address, status, role] = line.split /\ +/
      {name, address, status, role}
    .value()

exports.leave = ->
  execBacon 'serf leave'

exports.join = (address = '') ->
  execBacon "serf join #{address}"

exports.event = (event = 'test', payload = '') ->
  payload = JSON.stringify payload unless _.isString payload
  execBacon "serf event #{event} #{payload}"
