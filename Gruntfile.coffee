###
  grunt-hardcoder
  https://github.com/jonakyd/grunt-hardcoder

  Copyright (c) 2015 Jonathan Dang
  Licensed under the MIT license.
###

'use strict'

module.exports = (grunt) ->
  (require 'time-grunt') grunt
  (require 'load-grunt-tasks') grunt

  # Actually load this plugin's task(s).
  grunt.loadTasks 'tasks'