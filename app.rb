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

  begin
    result = cache.get(object_id)
    Thread.new do
      resource = NewsResource.new(object_id)
      cache.put(object_id,resource.render)
    end

    return result + "<p>(#{Time.now.to_ms}) cached: #{Time.now.to_ms - start_time}</p>"
  rescue AWS::S3::Errors::NoSuchKey
    puts "No cache found for #{object_id}"
  end

  resource = NewsResource.new(object_id)
  Thread.new do
    cache.put(object_id,resource.render)
  end

  resource.render + "<p>(#{Time.now.to_ms})uncached: #{Time.now.to_ms - start_time}</P>"
end


