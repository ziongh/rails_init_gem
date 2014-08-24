
# config/unicorn.rb



root = "/home/ziongh/railsProjects/current/ww"
working_directory root
pid "#{root}/tmp/pids/unicorn.pid"
stderr_path "#{root}/log/unicorn.log"
stdout_path "#{root}/log/unicorn.log"

worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)
timeout 15
preload_app true


listen "/tmp/unicorn.Ww.sock"

# Force the bundler gemfile environment variable to
# reference the capistrano "current" symlink
before_exec do |_|
  ENV["BUNDLE_GEMFILE"] = File.join(root, 'Gemfile')
end

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  if defined?(Redis)
    # this throws errors
    # Redis.current tries to connect localhost
    Redis.current.quit
  end

  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!

  # Before forking, kill the master process that belongs to the .oldbin PID.
  # This enables 0 downtime deploys.
  old_pid = "/tmp/unicorn.Ww.pid.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|

  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end
  
  # the following is *required* for Rails + "preload_app true",
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection

  if defined?(Redis)
    if ENV["REDISCLOUD_URL"]
        uri = URI.parse(ENV["REDISCLOUD_URL"])
        $redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
    else
      $redis = Redis::Namespace.new("Ww", :redis => Redis.new)
    end
    # Redis.current = Redis.new(url: ENV['REDIS_URI'])
  end

  # if preload_app is true, then you may also want to check and
  # restart any other shared sockets/descriptors such as Memcached,
  # and Redis.  TokyoCabinet file handles are safe to reuse
  # between any number of forked children (assuming your kernel
  # correctly implements pread()/pwrite() system calls)
end