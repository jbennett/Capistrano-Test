set :application, "Website"

set :repository,  "git@github.com:jbennett/Capistrano-Test.git"
set :scm, :git
set :branch, "master"

role :app, "ccistaging.com" # This may be the same as your `Web` server

set :user, "staging"
set :use_sudo, false

# directories
set :deploy_to, "/home/staging/subdomains/cap"
set :public, "#{deploy_to}/public_html"
set :extensions, %w[template component]

# Joomla
set :joomla_url, "http://joomlacode.org/gf/download/frsrelease/13105/57240/Joomla_1.5.22-Stable-Full_Package.zip"

set :joomla_db_name, ""
set :joomla_db_user, ""
set :joomla_db_pass, ""

set :joomla_admin_pass, ""

namespace :deploy do

  namespace :joomla do
    task :setup do
      download
      deploy
      install_default
      symlink
      cleanup
    end

    task :download do
      run <<-cmd
        cd #{public} &&
        wget -q #{joomla_url} -O joomla.zip &&
        unzip -qo joomla.zip
      cmd
    end

    task :deploy do
      require 'erb'
      require 'digest/sha1'

      # get db info
      db_name = Capistrano::CLI.ui.ask("Enter MySQL database name: ")
      db_user = Capistrano::CLI.ui.ask("Enter MySQL database user: ")
      db_pass = Capistrano::CLI.ui.ask("Enter MySQL database password: ")
      db_prefix = Capistrano::CLI.ui.ask("Enter Joomla DB prefix: ")
      title   = Capistrano::CLI.ui.ask("Enter Site name: ")

      # create config.php
      secret_hash = Digest::SHA1.hexdigest(Time.now.to_s)[0..15]
      template = ERB.new(File.read('config/templates/config.php.erb'), nil, '<>')
      result = template.result(binding)
      put result, "#{deploy_to}/shared/config.php"

      # install DB and create default admin
      template = ERB.new(File.read('config/templates/joomla.sql.erb'), nil, '<>')
      result = template.result(binding)
      t = <<-sql
        INSERT INTO #{db_prefix}users values (62, 'Administrator', 'admin', 'dummy@example.com', concat(md5(concat('asdf', '1234')), ':1234'), 'Super Administrator', 0, 1, 25, '0000-00-00', '0000-00-00', '', '');
        INSERT INTO #{db_prefix}core_acl_aro VALUES(10, 'users', '62', 0, 'Administrator', 0);
        INSERT INTO #{db_prefix}core_acl_groups_aro_map VALUES (25, '', 10);
      sql
      put "#{result}#{t}", "#{deploy_to}/shared/joomla.sql"
      run "mysql -u#{db_user} -p#{db_pass} -hlocalhost #{db_name} < #{deploy_to}/shared/joomla.sql"
    end

    task :symlink do
      run <<-cmd
        ln -nfs #{deploy_to}/shared/config.php #{public}/configuration.php
      cmd
    end

    task :install_default do
      # install sh404sef
      # install jce
      # install akeeba
    end

    task :cleanup do
      run "rm -rf #{public}/installation"
      run "mv #{public}/htaccess.txt #{public}/.htaccess"
    end
  end

  task :setup do
    transaction do
      run "mkdir -p #{deploy_to}/releases"
      run "mkdir -p #{deploy_to}/shared"
      run "mkdir -p #{public}"

      run <<-CMD
        cd #{deploy_to}/shared &&
        curl -s https://github.com/jbennett/symlinker/raw/master/link.php > symlinker &&
        chmod +x symlinker
      CMD
    end
  end

  task :finalize_update, :except => { :no_release => true } do
    run "chmod -R g+w #{latest_release}" if fetch(:group_writable, true)
  end

  task :symlink_modules, :except => { :no_release => true } do
    extensions.each do |path|
      run "#{deploy_to}/shared/symlinker #{current_path}/#{path} #{public}"
    end
  end

  task :start do ; end
  task :stop do ; end
  task :restart do ; end
end

after "deploy:symlink", "deploy:symlink_modules"

