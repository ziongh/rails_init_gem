project_name = Rails.application.class.parent_name
if ENV["REDISCLOUD_URL"]
    uri = URI.parse(ENV["REDISCLOUD_URL"])
    $redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
else
	$redis = Redis::Namespace.new(project_name, :redis => Redis.new)
end