require "bundler/setup"
require 'rubygems'
require 'sinatra'

set :public, File.expand_path(File.dirname(__FILE__) + '/public') # Include your public folder
set :views, File.expand_path(File.dirname(__FILE__) + '/views')  # Include the views

#set :environment, :production

#disable :run, :reload
set :show_exceptions, true
set :dump_errors, true

require './app' # replace this with your sinatra app file
run Sinatra::Application
