require 'sinatra'
require 'java'
require 'aws-sdk'
require 'rest_client'

require './config'

java_import 'java.util.concurrent.Callable'
java_import 'java.util.concurrent.FutureTask'
java_import 'java.util.concurrent.LinkedBlockingQueue'
java_import 'java.util.concurrent.ThreadPoolExecutor'
java_import 'java.util.concurrent.TimeUnit'

AWS.config(
  access_key_id: AWS_ACCESS_KEY,
  secret_access_key: AWS_SECRET_KEY
)

get '/resource/:id' do

  object_id = params[:id]

  # Use non-blocking thread to freshen s3 cache
  executor = ThreadPoolExecutor.new(4, 4, 60, TimeUnit::SECONDS, LinkedBlockingQueue.new)
  task = FutureTask.new(FreshenS3Cache.new(object_id))
  executor.execute(task)
  executor.shutdown()

  begin
    s3 = AWS::S3.new
    obj = s3.buckets[S3_BUCKET].objects[object_id] # no request made
    from_s3 = obj.read

    return from_s3
  rescue
    response = Resource::get(object_id)

    return response.body
  end
end

class Resource
  BASE_URL = "http://m.bbc.co.uk/news"

  def self.get(id)
    puts "Getting #{BASE_URL}/#{@s3_object_id}"

    RestClient.get "#{BASE_URL}/#{@s3_object_id}"
  end
end

class FreshenS3Cache
  include Callable

  @s3_object_id = false

  def initialize(object_id)
    @s3_object_id = object_id
  end

  def call
    response = Resource::get(@s3_object_id)
    if(response.code == 200)
      puts "Caching #{@s3_object_id}"

      s3 = AWS::S3.new
      obj = s3.buckets[S3_BUCKET].objects[@s3_object_id]
      obj.write(response.body)
    end
  end
end
