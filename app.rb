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

get %r{/(?<filter>unsorted|deleted|censored|published)/?(?<page>[0-9]*)$} do |filter, page|
  start_index = [page.to_i, 0].max
  @images = case filter
            when 'unsorted'
              IMAGE_URLS - deleted_urls - censored_urls - published_urls
            when 'deleted'
              deleted_urls
            when 'censored'
              censored_urls
            when 'published'
              published_urls
            end
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

get %r{(?:(?:/resize/([0-9]+x[0-9]+))|(?:/rotate/([0-9]+)))+/(.*)$} do |resize_dimensions,rotate_degrees,photo|
  image = MiniMagick::Image.open("#{Dir.pwd}/public/photos/#{photo}")

  image.combine_options do |command|
    #
    # The box filter majorly decreases processing time without much
    # decrease in quality
    #
    if resize_dimensions
      command.filter("box")
      command.resize(resize_dimensions)
    end
    if rotate_degrees
      command.rotate(rotate_degrees)
    end
  end
  dest = "#{Dir.pwd}/public/"
  dest += "resize/#{resize_dimensions}/" if resize_dimensions
  dest += "rotate/#{rotate_degrees}/" if rotate_degrees
  dest += photo
  FileUtils.mkdir_p(File.dirname(dest))
  image.write(dest)

  send_file(image.path, :disposition => "inline")
end
