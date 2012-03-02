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





#role :db,  "your slave db-server here"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
