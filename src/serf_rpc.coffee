'use strict'

{exec}  = require 'child_process'
stream  = require 'stream'
net     = require 'net'

_       = require 'underscore'
msgpack = require 'msgpack'
debug   = require('debug')('serf')
Q       = require 'q'

print   = (d) ->
  if _.isString d
    debug d
  else
    debug JSON.stringify d, null, 4

class Translator extends stream.Transform
  constructor: ->
    super
    @_readableState.objectMode = true
    @_writableState.objectMode = true

  _transform: (chunk, encoding, done) =>
    if chunk instanceof Buffer
      print 'unpack'
      @push msgpack.unpack chunk
    else if _.isArray chunk
      print 'array'
      chunk.forEach (d) =>
        @push msgpack.pack d
    else
      print 'pack'
      @push msgpack.pack chunk
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

exports.connect = (options = {port: 7373}) ->
  translator = new Translator()
  socket = net.connect options, ->
    print 'connected'

  socket.on 'end', ->
    print 'disconnected'

  translator.pipe socket

  result =
    input: translator
    output: socket.pipe new Translator()

{input, output} = exports.connect()
output.on 'data', print

handshake = [
  {Command: 'handshake', Seq: 0}
  {Version: 1, Seq: 0}
]

# input.write {Command: 'handshake', Seq: 0}

input.write handshake

input.write {Command: 'members', Seq: 1}
