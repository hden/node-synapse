'use strict'

{exec}  = require 'child_process'
stream  = require 'stream'

_       = require 'underscore'
debug   = require 'debug'
Q       = require 'q'

exports.debug = (domain = 'unnamed') ->
  print = debug domain
  (d) ->
    return unless d?
    if _.isString d
      print d
    else
      try
        print JSON.stringify d
      catch error
        print 'circular structure!'

exports.execPromise = (command) ->
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

class exports.Readline extends stream.Transform
  constructor: ->
    super
    @_cache = ''
  _transform: (chunk, encoding = 'utf-8', done) =>
    @_cache += chunk.toString encoding
    [lines..., @_cache] = @_cache.split '\n'
    lines.forEach @push.bind @
    do done
