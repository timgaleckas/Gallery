require 'sinatra'
require 'haml'
require 'fileutils'


get '/' do
    haml :index
end

get '/about' do
    haml :about
end

get "/select/*" do
    photo = params[:splat][0]
    name = photo.split("/").last
    orig = "#{Dir.pwd}/public/#{photo}"
    dest = "#{Dir.pwd}/public/dest/#{name}"
    # "#{Dir.pwd}/public/#{photo[0]}"
    if File.exists?(dest)
        FileUtils.rm(dest)
        "<div class='alert'><a class='close' data-dismiss='alert' href='#'>&times;</a><strong>Removed:</strong> #{name}</div>"
    else
        FileUtils.cp(orig, dest)
        "<div class='alert alert-success'><a class='close' data-dismiss='alert' href='#'>&times;</a><strong>Added:</strong> #{name}</div>"
    end
end

get '/:page' do
    haml :index
end