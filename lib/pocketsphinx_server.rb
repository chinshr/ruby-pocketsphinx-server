require "pathname"
require "bundler"

($LOAD_PATH << Pathname(__FILE__).dirname.to_s).uniq!

(ENV["RACK_ENV"] || "development").to_sym.tap do |env|
  Bundler.setup   :default, env
  Bundler.require :default, env
end

require 'uuidtools'
require 'json'
require 'iconv'
require 'set'
require 'yaml'
require 'open-uri'
require 'uri'
require 'digest/md5'
require 'rubygems'
require 'locale'
require 'locale/info'
require 'gst'
require 'pocketsphinx_server/handlers/base'
require 'pocketsphinx_server/handlers/jsgf_handler'
require 'pocketsphinx_server/handlers/pgf_handler'
require 'pocketsphinx_server/handlers/prettifier'
require 'pocketsphinx_server/recognizer'
require 'pocketsphinx_server/server'

Gst.init
