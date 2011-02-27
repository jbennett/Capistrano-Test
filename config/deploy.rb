set :application, "set your application name here"
set :repository,  "set your repository location here"

set :scm, :subversion
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :app, "ccistaging.com"                          # This may be the same as your `Web` server
role :db,  "localhost", :primary => true # This is where Rails migrations will run




namespace :deploy do
  
  namespace :joomla do
    task :setup do
      # dl joomla.zip
      # extract joomla.zip
    end
    
    task :deploy do 
      # install DB
      # 
    end
    
    task :cleanup do
    end
  end
  
  
  task :start do ; end
  task :stop do ; end
  task :restart do ; end
end