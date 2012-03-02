require "bundler/capistrano"

# main application
set :application, "ppl-signator"
role :web, "dev.pplsa.ch"                          # Your HTTP server, Apache/etc
role :app, "dev.pplsa.ch"                          # This may be the same as your `Web` server
role :db,  "dev.pplsa.ch", :primary => true # This is where Rails migrations will run

# server details
set :deploy_to, "/home/gitlabhq/ppl_signator"
set :user, "gitlabhq"
#set :sudo_prompt, ""
set :use_sudo, false

# repo details
set :scm, :git
set :repository,  "git@dev.pplsa.ch:ppl_signator.git"
set :branch, "master"



namespace :deploy do
  desc "Tell Passenger to restart the app."
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
end
