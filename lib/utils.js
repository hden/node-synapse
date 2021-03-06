// Generated by CoffeeScript 1.6.3
(function() {
  'use strict';
  var Q, debug, exec, stream, _,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __slice = [].slice;

  exec = require('child_process').exec;

  stream = require('stream');

  _ = require('underscore');

  debug = require('debug');

  Q = require('q');

  exports.debug = function(domain) {
    var print;
    if (domain == null) {
      domain = 'unnamed';
    }
    print = debug(domain);
    return function(d) {
      var error;
      if (d == null) {
        return;
      }
      if (_.isString(d)) {
        return print(d);
      } else {
        try {
          return print(JSON.stringify(d));
        } catch (_error) {
          error = _error;
          return print('circular structure!');
        }
      }
    };
  };

  exports.execPromise = function(command) {
    var deferred;
    deferred = Q.defer();
    exec(command, function(err, stdout, stderr) {
      if (err != null) {
        print("node err: " + err);
        deferred.reject(err);
      }
      if (stderr.length > 0) {
        print("stderr: " + stderr);
        deferred.reject(stderr);
      }
      print("stdout: " + stdout);
      return deferred.resolve(stdout);
    });
    return deferred.promise;
  };

  exports.Readline = (function(_super) {
    __extends(Readline, _super);

    function Readline() {
      this._transform = __bind(this._transform, this);
      Readline.__super__.constructor.apply(this, arguments);
      this._cache = '';
    }

    Readline.prototype._transform = function(chunk, encoding, done) {
      var lines, _i, _ref;
      if (encoding == null) {
        encoding = 'utf-8';
      }
      this._cache += chunk.toString(encoding);
      _ref = this._cache.split('\n'), lines = 2 <= _ref.length ? __slice.call(_ref, 0, _i = _ref.length - 1) : (_i = 0, []), this._cache = _ref[_i++];
      lines.forEach(this.push.bind(this));
      return done();
    };

    return Readline;

  })(stream.Transform);

}).call(this);
