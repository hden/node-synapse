'use strict'

_          = require 'underscore'
handlebars = require 'handlebars'
program    = require 'commander'
HAProxy    = require 'haproxy'
dnode      = require 'dnode'
Q          = require 'q'

{start}    = require "#{__dirname}/haproxy"
{debug}    = require "#{__dirname}/utils"
serf       = require "#{__dirname}/serf"

print      = debug 'main'

program
  .version('0.0.0')
  .option('-t --template <.handlebars>', 'HAProxy config template in handlebars', require)
  .parse(process.argv)

# Default Settings
program.template ?= require "#{__dirname}/../example/haproxy.config"

throw new Error 'invalid template' unless _.isFunction program.template

handlers =
  print: print

server = dnode(handlers).listen("#{__dirname}/../synapse.sock")

data = {
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

# print program.template data
