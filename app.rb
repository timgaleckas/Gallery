require 'sinatra'
require 'haml'
require 'fileutils'
require 'redis'

require 'pry'

#IMAGE_FILES=Dir.glob(File.dirname(__FILE__)+"/public/photos/{Videos,Pictures}/[12][0-9][0-9][0-9]/**/*.[jJmMPp3][pPoONng][gGvV4p]").sort
IMAGE_FILES=Dir.glob(File.dirname(__FILE__)+"/public/photos/{Pictures}/[12][0-9][0-9][0-9]/**/*.[jJmMPp3][pPoONng][gGvV4p]").sort.reverse

def redis
  @redis ||= Redis.new
end

get '/' do
  haml :index
end

get '/about' do
  haml :about
end

get "/select/*" do
  photo = params[:splat][0]
  key   = "image:#{photo}:selected"
  orig  = "#{Dir.pwd}/public/#{photo}"
  name  = photo.split("/").last

  if redis.exists(key)
    redis.del(key)
    "removed:#{photo}"
  else
    redis.set(key, true)
    "added:#{photo}"
  end
end

get '/:page' do
  haml :index
end
