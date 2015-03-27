###
  grunt-hardcoder
  https://github.com/jonakyd/grunt-hardcoder

  Copyright (c) 2015 Jonathan Dang
  Licensed under the MIT license.
###

COFFEE_ESCAPE = '`'
STRICT = "'use strict';"
AMD_WRAPPER_BEGIN = 'define([], function() {'
AMD_WRAPPER_END = '});'
CJS_WRAPPER_BEGIN = 'define(function(require, exports, module){'
CJS_WRAPPER_END = '});'
EXPORTS_WRAPPER_BEGIN = '(function(exports){'
EXPORTS_WRAPPER_END = '})(exports);'

isCoffee = (path) -> /.coffee$/.test path
isJson = (path) -> /.json$/.test path

wrapScriptByType = (wrapperObj, wrapperType) ->
  switch wrapperType
    when 'amd'
     wrapperObj.begin = AMD_WRAPPER_BEGIN
     wrapperObj.end = AMD_WRAPPER_END
    when 'cjs'
     wrapperObj.begin = CJS_WRAPPER_BEGIN
     wrapperObj.end = CJS_WRAPPER_END
    when 'exports'
     wrapperObj.begin = EXPORTS_WRAPPER_BEGIN
     wrapperObj.end = EXPORTS_WRAPPER_END

wrapCoffee = (wrapperObj) ->
  wrapperObj.begin = "#{COFFEE_ESCAPE}#{wrapperObj.begin}#{COFFEE_ESCAPE}"
  wrapperObj.end = "#{COFFEE_ESCAPE}#{wrapperObj.end}#{COFFEE_ESCAPE}"

wrapJson = (wrapperObj) ->
  wrapperObj.begin += "module.exports = "
  wrapperObj.end = ";#{wrapperObj.end}"

appendStrict = (wrapperObj) ->
  wrapperObj.begin += STRICT

appendGlobals = (wrapperObj, globals) ->
  globals.forEach ({varName, moduleName}) ->
    wrapperObj.begin += "var #{varName} = require('#{moduleName}');"

module.exports = (grunt) ->

  grunt.registerMultiTask 'hardcoder', 'Grunt task plugin can help you compose JS/Coffee scripts with CommonJS/AMD/\'use strict\' wrapper.', () ->

    options = @options
      isStrict: true  # default all files entitle 'use strict'
      wrapperType: 'cjs' # false || exports || cjs || amd
      exportsType: false # false || function || var || all(function + var) || filename
      globals: [] # globals var injection
      # ignoreStartsWith_:true -> exports extension

    grunt.verbose.writeflags @

    @files.forEach (f) ->

      # Make sure path really has file.
      f.src.filter (filePath) ->

        isFileExist = grunt.file.exists filePath
        grunt.log.warn "Source file '#{filepath}' not found." unless isFileExist
        isFileExist

      .forEach (filePath) ->

        script = grunt.file.read filePath

        # Mutable variables 'begin' and 'end'.
        wrapperObj =
          begin: ''
          end: ''

        wrapScriptByType wrapperObj, options.wrapperType

        appendStrict wrapperObj if options.isStrict
        appendGlobals wrapperObj, options.globals if options.globals
        wrapCoffee wrapperObj if isCoffee filePath
        wrapJson wrapperObj if isJson filePath

        grunt.file.write f.dest, [wrapperObj.begin, script, wrapperObj.end].join grunt.util.linefeed
        grunt.log.writeln "File #{f.dest.cyan} created"