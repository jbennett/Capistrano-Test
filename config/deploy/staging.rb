set :application, "Website"

# repository info
set :repository,  "git@github.com:jbennett/Capistrano-Test.git"
set :scm, :git
set :branch, "development"

# This may be the same as your `Web` server
role :app, "ccistaging.com"

# directories
set :deploy_to, "/home/staging/subdomains/cap"
set :public, "#{deploy_to}/public_html"
set :extensions, %w[template component]
