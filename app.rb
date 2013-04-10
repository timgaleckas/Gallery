require 'sinatra'
require 'haml'
require 'fileutils'
require 'redis'
require 'mini_magick'

require 'pry'

#IMAGE_FILES=Dir.glob(File.dirname(__FILE__)+"/public/photos/{Videos,Pictures}/[12][0-9][0-9][0-9]/**/*.[jJmMPp3][pPoONng][gGvV4p]").sort
LOCAL_IMAGE_FILES=Dir.glob(File.dirname(__FILE__)+"/public/photos/Pictures/[12][0-9][0-9][0-9]/**/*.[jJmMPp3][pPoONng][gGvV4p]").sort.reverse
IMAGE_URLS=LOCAL_IMAGE_FILES.map{|file|file.gsub(File.dirname(__FILE__)+"/public/photos/",'')}

def redis
  @redis ||= Redis.new
end
helpers do
def key_for_photo(operation,url)
  "image:#{operation}:#{url}:selected"
end

def photo_from_key(operation,key)
  key.gsub("image:#{operation}:",'').gsub(':selected','')
end

end

get '/' do
  haml :home
end

get %r{/(delete|censor|publish)(?:/(all|selected))?(?:/([^\/?#]+)(?:\.|%2E)?([^\/?#]+)?)?$} do |operation, filter, page, format|
  @filter = filter || 'all'
  @images = case @filter
              when 'all', nil
                IMAGE_URLS
              when 'selected'
                IMAGE_URLS & redis.keys(key_for_photo(operation, '*')).map{|key| photo_from_key(operation, key)}.sort.reverse
              when 'not_selected'
                IMAGE_URLS - redis.keys(key_for_photo(operation, '*')).map{|key| photo_from_key(operation, key)}.sort.reverse
              end
  @pagenum = page.to_i
  @operation = operation
  @prefix = "/#{operation}/#{filter}"
  haml :index
end

get "/:operation/select/*" do |operation, splat|
  photo = params[:splat][0].gsub(/\/resize\/[^\/]*\//,'')
  key   = key_for_photo(operation,photo)

  if redis.exists(key)
    redis.del(key)
    "removed:#{photo}"
  else
    redis.set(key, true)
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
