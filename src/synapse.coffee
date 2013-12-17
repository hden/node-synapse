'use strict'

_          = require 'underscore'
handlebars = require 'handlebars'
program    = require 'commander'

haproxy    = require "#{__dirname}/haproxy"
{debug}    = require "#{__dirname}/utils"
serf       = require "#{__dirname}/serf"

print      = debug 'main'

program
  .version('0.0.0')
  .option('-c --controller <module>', 'Controller', require)
  .option('-t --template <.handlebars>', 'HAProxy config template in handlebars', require)
  .parse(process.argv)

# Default Settings
program.controller ?= require "#{__dirname}/../example/controller"
program.template   ?= require "#{__dirname}/../example/haproxy.config"

throw new Error 'invalid controller' unless _.isFunction program.controller
throw new Error 'invalid template' unless _.isFunction program.template

# serf
#   .start()
#   .flatMap(program.controller)
#   .flatMap(program.template)
#   .debounceImmediate(5 * 1000) # 5 seconds
#   .skipDuplicates(_.isEqual)
#   .flatMap(haproxy.pipe)
#   .assign(print)

data = {
  socket: 'path-to-socket'
  roles: [
    {
      "role": "apache",
      "server": [
        {"name": "server1", "address": "127.0.0.1:1234"},
      {"name": "server1", "address": "127.0.0.1:1235"},
      {"name": "server1", "address": "127.0.0.1:1236"}
      ]
    },
    {
      "role": "cometd",
      "server": [
        {"name": "server1", "address": "127.0.0.1:1234"},
      {"name": "server1", "address": "127.0.0.1:1235"},
      {"name": "server1", "address": "127.0.0.1:1236"}
      ]
    },
    {
      "role": "ngix",
      "server": [
        {"name": "server1", "address": "127.0.0.1:1234"},
      {"name": "server1", "address": "127.0.0.1:1235"},
      {"name": "server1", "address": "127.0.0.1:1236"}
      ]
    }
  ]
}

console.log program.template data
