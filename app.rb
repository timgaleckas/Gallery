require 'sinatra'
require 'haml'
require 'fileutils'

use Rack::ShowExceptions

IMAGE_FILES=Dir.glob("public/photos/{Videos,Pictures}/[12][0-9][0-9][0-9]/**/*.[jJmMPp3][pPoONng][gGvV4p]").sort

get '/' do
    haml :index
end

get '/about' do
    haml :about
end

get "/select/*" do
    photo = params[:splat][0]
    orig = "#{Dir.pwd}/public/#{photo}"
    FileUtils.mkdir_p "#{Dir.pwd}/public/dest/#{photo.split("/")[0..-2].join('/')}"
    dest = "#{Dir.pwd}/public/dest/#{photo}"
    # "#{Dir.pwd}/public/#{photo[0]}"
    if File.exists?(dest)
        FileUtils.rm(dest)
        "<div class='alert'><a class='close' data-dismiss='alert' href='#'>&times;</a><strong>Removed:</strong> #{name}</div>"
    else
        FileUtils.touch(orig, dest)
        "<div class='alert alert-success'><a class='close' data-dismiss='alert' href='#'>&times;</a><strong>Added:</strong> #{name}</div>"
    end
end

get '/:page' do
    haml :index
end
