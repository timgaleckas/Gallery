require "bundler/setup"
require 'rubygems'
require 'sinatra'

#set :environment, :production

#disable :run, :reload
set :show_exceptions, true
set :dump_errors, true

require './app' # replace this with your sinatra app file
run Sinatra::Application
