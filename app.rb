require 'sinatra'

require './config'
require './models/s3_cache'
require './models/news_resource'

get '/news/:id' do
  object_id = params[:id]

  cache = S3Cache.new

  begin
    result = cache.get(object_id)
    Thread.new do
      resource = NewsResource.new(object_id)
      cache.put(object_id,resource.render)
    end

    return result + "<p>cached</p>"
  rescue AWS::S3::Errors::NoSuchKey
    puts "No cache found for #{object_id}"
  end

  resource = NewsResource.new(object_id)
  Thread.new do
    cache.put(object_id,resource.render)
  end

  resource.render + "<p>uncached</P>"
end


