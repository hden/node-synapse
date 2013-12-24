'use strict'

_ = require 'underscore'

module.exports = (listOfCurrentMembers) ->
  roles = _.chain(listOfCurrentMembers)
  .groupBy('role')
  .map (server, role) ->
    {server, role}
  .value()
  {roles}
