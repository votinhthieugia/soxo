#require 'mongrel'
#require 'mongrel_cluster/recipes'

set :application, "luckynumber"
set :repository, "svn://ec2-75-101-240-240.compute-1.amazonaws.com/svnrepos/luckynumber"
set :scm, :subversion
set :user, "root"
set :runner, 'root'

set :deploy_to, '/var/www/apps/luckynumber'
set :mongrel_conf, "#{deploy_to}/current/config/mongrel_cluster.yml"
set :revision, ENV['revision'] if ENV['revision']
set :keep_releases, 5

ssh_options[:keys] = ["#{ENV['HOME']}/.ec2/ec2-keypair.pem"]

role :web, "ec2-75-101-240-240.compute-1.amazonaws.com"
role :app, "ec2-75-101-240-240.compute-1.amazonaws.com"
role :db, "ec2-75-101-240-240.compute-1.amazonaws.com", :primary => true

namespace :luckynumber do
  before "luckynumber:update", "luckynumber:stop"
  after "luckynumber:update", "luckynumber:start"

  task :cleanup do
    count = fetch(:keep_releases, 5).to_i
    unless count >= releases.length
      directories = (releases - releases.last(count)).map { |release|
        File.join(releases_path, release) }.join(" ")
        run "rm -fr #{directories}"
    end
  end

  task :update_code do
    run "svn --username doananh --password quachuoi --quiet --force export #{repository} #{releases_path}/#{release_name}"
  end

  task :symlink do
    run "rm -fr #{current_path} && ln -s #{releases_path}/#{release_name} #{current_path}"
  end

  task :createdb, :roles => :web do
    run "cd #{current_path}; rake db:create RAILS_ENV=production"
  end

  task :dropdb, :roles => :web do
    run "cd #{current_path}; rake db:drop RAILS_ENV=production"
  end

  task :migratedb, :roles => :web do
    run "cd #{current_path}; rake db:migrate RAILS_ENV=production"
  end

  task :update do
    transaction do
      cleanup
      update_code
      symlink
    end
  end

  task :start do
    run "cd #{current_path} && /usr/local/bin/mongrel_rails cluster::start -C /var/www/apps/luckynumber/current/config/mongrel_cluster.yml"
  end

  task :stop do
    run "cd #{current_path} && /usr/local/bin/mongrel_rails cluster::stop -C /var/www/apps/luckynumber/current/config/mongrel_cluster.yml"
  end

  task :restart do
    run "cd #{current_path} && /usr/local/bin/mongrel_rails cluster::restart -C /var/www/apps/luckynumber/current/config/mongrel_cluster.yml"
  end
end
