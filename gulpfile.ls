argv = require 'yargs' .argv
only-compile = false


require! <[ watchify gulp browserify glob path fs globby touch ]>
require! 'prelude-ls': {union, join, keys, map, unique}
require! 'vinyl-source-stream': source
require! 'vinyl-buffer': buffer
require! 'gulp-watch': watch
require! 'gulp-pug': pug
require! 'node-notifier': notifier
require! 'gulp-concat': cat
require! 'gulp-uglify': uglify
require! 'gulp-flatten': flatten
require! 'gulp-tap': tap
require! 'gulp-cached': cache
require! 'gulp-sourcemaps': sourcemaps
require! 'browserify-livescript'
require! 'run-sequence'
require! 'through2':through
require! 'optimize-js'
require! 'gulp-if-else': if-else
require! 'gulp-rename': rename

# Build Settings
notification-enabled = yes

# Project Folder Structure
src-path = "#{__dirname}/src"
build-path = "#{__dirname}/build"
out-dir = argv.out-dir or build-path

on-error = (source, msg) ->
    msg = try
        msg.to-string!
    catch
        "unknown message: #{e}"
    console-msg = "GULP ERROR: #{source} : #{msg}"
    console.log console-msg

log-info = (source, msg) ->
    msg = try
        msg.to-string!
    catch
        "unknown message: #{e}"
    console-msg = "GULP INFO: #{source} : #{msg}"
    console.log console-msg

ls-entry-file = "#{src-path}/loading-bar.ls"

for-browserify =
    "#{src-path}/*.ls"
    ...


# Organize Tasks
gulp.task \default, ->
    do function run-all
        gulp.start do
            \browserify
            ...

    watch for-browserify, ->
        gulp.start \browserify


browserify-cache = {}
bundler = browserify do
    entries: ls-entry-file
    debug: true
    paths:
        src-path
        ...
    extensions: <[ .ls ]>
    cache: browserify-cache
    package-cache: {}
    plugin:
        watchify unless only-compile
        ...

bundler.transform browserify-livescript

first-browserify-done = no

function bundle
    bundler
        .bundle!
        .on \error, (err) ->
            msg = try
                err.message
            catch
                err
            on-error \browserify, msg
            @emit \end
        .pipe source "loading-bar.js"
        .pipe buffer!
        #.pipe sourcemaps.init {+load-maps, +large-files}
        .pipe if-else only-compile, uglify
        #.pipe rename basename: 'app'
        #.pipe sourcemaps.write '.'
        .pipe gulp.dest out-dir
        .pipe tap (file) ->
            log-info \browserify, "Browserify finished #{if out-dir isnt build-path then "out-dir: #{out-dir}"}"
            console.log "------------------------------------------"
            first-browserify-done := yes

gulp.task \browserify, ->
    bundle!