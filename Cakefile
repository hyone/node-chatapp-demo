fs        = require 'fs'
{ print } = require 'util'
{ spawn } = require 'child_process'


targets = [
  'app.coffee'
  'chatserver.coffee'
  'models.coffee'
  'routes'  
]

build = (watch, callback) ->
  options = ['-c'].concat(targets)
  options.unshift '-w' if watch

  coffee = spawn './node_modules/.bin/coffee', options
  coffee.stdout.on 'data', (data) -> print data.toString()
  coffee.stderr.on 'data', (data) -> print data.toString()
  coffee.on 'exit', (status) -> callback?() if status is 0


task 'build', 'Compile CoffeeScript source files.', ->
  build()

task 'watch', 'Recompile CoffeeScript source files when modified.', ->
  build(true)