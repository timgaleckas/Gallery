require 'sinatra'
require 'haml'
require 'fileutils'
require 'redis'
require 'mini_magick'

require 'pry'

#IMAGE_FILES=Dir.glob(File.dirname(__FILE__)+"/public/photos/{Videos,Pictures}/[12][0-9][0-9][0-9]/**/*.[jJmMPp3][pPoONng][gGvV4p]").sort
IMAGE_FILES=Dir.glob(File.dirname(__FILE__)+"/public/photos/Pictures/[12][0-9][0-9][0-9]/**/*.[jJmMPp3][pPoONng][gGvV4p]").sort.reverse

def redis
  @redis ||= Redis.new
end

get '/' do
  @images = IMAGE_FILES
  haml :index
end

get '/selected' do
  @images = redis.keys('image:*:selected').map{|i|i.gsub('image:','').gsub(':selected','')}.sort.reverse
  @prefix = '/selected'
  haml :index
end

get '/selected/:page' do
  @images = redis.keys('image:*:selected').map{|i|i.gsub('image:','').gsub(':selected','')}.sort.reverse
  @prefix = '/selected'
  haml :index
end

get '/resize/:dimensions/*' do |dimensions, url|
  image = MiniMagick::Image.open("#{Dir.pwd}/public/#{url}")

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

get '/about' do
  haml :about
end

get '/:page' do
  @images = IMAGE_FILES
  haml :index
end
