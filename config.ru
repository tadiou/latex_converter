require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require './app'
require 'json'
require 'mathematical'

set :environment, :development
set :run, false
set :raise_errors, true

run App