require 'sinatra'

require './config'
require './models/s3_cache'
require './models/news_resource'

class Time
  def to_ms
    (self.to_f * 1000.0).to_i
  end
end

get '/news/:id' do
  start_time = Time.now.to_ms
  object_id = params[:id]

  cache = S3Cache.new

  freshen_if_older_than_ms = 60000

  begin
    result = cache.get(object_id)
    last_updated = cache.last_updated(object_id).to_i
    time_since_last_update = Time.now.to_ms - last_updated

    puts "LOG: time_since_last_update #{time_since_last_update}"
    if(time_since_last_update > freshen_if_older_than_ms)
      puts "LOG: Cache expired for #{object_id}, refreshing ..."
      Thread.new do
        resource = NewsResource.new(object_id)
        cache.put(object_id,resource.render)
      end
    end

    puts "LOG: Writing to page at #{Time.now.to_ms}"
    return result + "<p>(#{Time.now.to_ms}) cached: #{Time.now.to_ms - start_time}</p>"
  rescue AWS::S3::Errors::NoSuchKey
    puts "LOG: No cache found for #{object_id}"
  end

  resource = NewsResource.new(object_id)
  Thread.new do
    cache.put(object_id,resource.render)
  end

  puts "LOG: Writing to page at #{Time.now.to_ms}"
  resource.render + "<p>(#{Time.now.to_ms})uncached: #{Time.now.to_ms - start_time}</P>"
end


