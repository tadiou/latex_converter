require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'unicorn'
require 'json'
require 'mathematical'

require File.expand_path '../app.rb', __FILE__

run App