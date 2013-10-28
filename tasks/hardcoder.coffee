###*
 * grunt-hardcoder
 * https://github.com/jonakyd/grunt-hardcoder
 *
 * Copyright (c) 2013 Jonathan Dang
 * Licensed under the MIT license.
###

'use strict'

module.exports = (grunt) ->
  COFFEE_ESCAPE = '`'
  STRICT = "'use strict';"
  AMD_WRAPPER_BEGIN = 'define(function(require, exports, module){'
  AMD_WRAPPER_END = '});'
  EXPORTS_WRAPPER_BEGIN = '(function(exports){'
  EXPORTS_WRAPPER_END = '})(exports);'

  isCoffee = ( path ) ->
    /.coffee$/.test path

  wrapScipts = ( wrapperType, wrapperObj ) ->
    switch wrapperType
      when 'amd'
       wrapperObj.begin = AMD_WRAPPER_BEGIN
       wrapperObj.end = AMD_WRAPPER_END
      when 'exports'
       wrapperObj.begin = EXPORTS_WRAPPER_BEGIN
       wrapperObj.end = EXPORTS_WRAPPER_END

  wrapStrict = ( isStrict, wrapperObj ) ->
    wrapperObj.begin += STRICT if isStrict

  wrapCoffee = ( wrapperObj ) ->
    wrapperObj.begin = COFFEE_ESCAPE + wrapperObj.begin + COFFEE_ESCAPE
    wrapperObj.end = COFFEE_ESCAPE + wrapperObj.end + COFFEE_ESCAPE

  grunt.registerMultiTask 'hardcoder', 'Grunt task plugin can help you compose JS/Coffee scripts with CommonJS/AMD/\'use strict\' wrapper.', () ->

    options = @options
      isStrict: true  # default all files entitle 'use strict'
      wrapperType: 'amd' # false || exports || amd
      exportsType: false # false || function || var || all(function + var) || filename
      # ignoreStartsWith_:true -> exports extension

    @files.forEach (f) ->
      f.src
        .filter ( filePath ) ->
          isFileExist = grunt.file.exists filePath

          if not isFileExist
            grunt.log.warn 'Source file "' + filepath + '" not found.'

          return isFileExist
        .forEach ( filePath ) ->
          code = grunt.file.read filePath
          # mutable variables 'begin' and 'end'
          wrapper =
            begin: ''
            end: ''

          wrapScipts options.wrapperType, wrapper
          wrapStrict options.isStrict, wrapper
          wrapCoffee wrapper if isCoffee filePath

          # grunt.log.ok filePath + '->' + f.dest.cyan

          grunt.file.write f.dest, [ wrapper.begin, code, wrapper.end ].join grunt.util.linefeed