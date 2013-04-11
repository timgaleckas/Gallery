require 'sinatra'
require 'haml'
require 'fileutils'
require 'redis'
require 'mini_magick'

require 'pry'

#IMAGE_FILES=Dir.glob(File.dirname(__FILE__)+"/public/photos/{Videos,Pictures}/[12][0-9][0-9][0-9]/**/*.[jJmMPp3][pPoONng][gGvV4p]").sort
LOCAL_IMAGE_FILES=Dir.glob(File.dirname(__FILE__)+"/public/photos/Pictures/[12][0-9][0-9][0-9]/**/*.[jJmMPp3][pPoONng][gGvV4p]").sort.reverse
IMAGE_URLS=LOCAL_IMAGE_FILES.map{|file|file.gsub(File.dirname(__FILE__)+"/public/photos/",'')}

REDIS_PREFIX='pictures:'

helpers do
def redis
  @redis ||= Redis.new
end

def deleted_urls
  IMAGE_URLS & redis.hgetall(REDIS_PREFIX + 'selections').map{|a,b| a if b=='delete'}.compact
end

def censored_urls
  IMAGE_URLS & redis.hgetall(REDIS_PREFIX + 'selections').map{|a,b| a if b=='censor'}.compact
end

def published_urls
  IMAGE_URLS & redis.hgetall(REDIS_PREFIX + 'selections').map{|a,b| a if b=='publish'}.compact
end

def unselect(operation, photo)
  if selected?(operation, photo)
    redis.hdel REDIS_PREFIX + 'selections', photo
  end
end
def select(operation, photo)
  redis.hset REDIS_PREFIX + 'selections', photo, operation
end
def selected?(operation, photo)
  redis.hget( REDIS_PREFIX + 'selections', photo ) == operation
end
end

get '/' do
  redirect '/unsorted'
end

get '/unsorted/?:page?' do |page|
  start_index = [page.to_i, 0].max
  @images = IMAGE_URLS - deleted_urls - censored_urls - published_urls
  @images = @images[start_index, 99]
  @previous_start_index = [start_index - 99, 0].max
  haml :index
end
get '/deleted/?:page?' do |page|
  start_index = [page.to_i, 0].max
  @images = deleted_urls
  @images = @images[start_index, 99]
  @previous_start_index = [start_index - 99, 0].max
  haml :index
end
get '/censored/?:page?' do |page|
  start_index = [page.to_i, 0].max
  @images = censored_urls
  @images = @images[start_index, 99]
  @previous_start_index = [start_index - 99, 0].max
  haml :index
end
get '/published/?:page?' do |page|
  start_index = [page.to_i, 0].max
  @images = published_urls
  @images = @images[start_index, 99]
  @previous_start_index = [start_index - 99, 0].max
  haml :index
end

get "/:operation/select/*" do |operation, splat|
  photo = params[:splat][0].gsub(/\/resize\/[^\/]*\//,'')

  if selected?(operation, photo)
    unselect(operation, photo)
    "removed:#{photo}"
  else
    select(operation, photo)
    "added:#{photo}"
  end
end

get '/resize/:dimensions/*' do |dimensions, url|
  image = MiniMagick::Image.open("#{Dir.pwd}/public/photos/#{url}")

  image.combine_options do |command|
    #
    # The box filter majorly decreases processing time without much
    # decrease in quality
    #
    command.filter("box")
    command.resize(dimensions)
  end
  dest = "#{Dir.pwd}/public/resize/#{dimensions}/#{url}"
  FileUtils.mkdir_p(File.dirname(dest))
  image.write(dest)

  send_file(image.path, :disposition => "inline")
end
