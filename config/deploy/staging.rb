# repository info
set :branch, "development"

# This may be the same as your `Web` server
role :app, "ccistaging.com"

# directories
set :deploy_to, "/home/staging/subdomains/cap/dev"
set :public, "#{deploy_to}/public_html"
set :extensions, %w[template component]
