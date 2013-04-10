set :shared_children, %w( public/resize )
set :domain, "timgaleckas.dyndns-home.com"
set :port, 8970
set :application, "pictures"
set :deploy_to, "/srv/www/#{application}"

set :user, "tim"
set :use_sudo, false

set :scm, :git
set :repository,  "git@github.com:timgaleckas/Gallery.git"
set :branch, 'master'
set :git_shallow_clone, 1

role :web, domain
role :app, domain
role :db,  domain, :primary => true

set :deploy_via, :copy

namespace :bundle do
  desc "run bundle install and ensure all gem requirements are met"
  task :install do
    run "cd #{current_path} && bundle install  --without=test"
    run "ln -s /mnt/NASDisk0001/Pictures /srv/www/pictures/current/public/photos"
  end
end

before "deploy:restart", "bundle:install"
