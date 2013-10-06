require './models/s3_cache'
require './models/news_resource'

class NewsService

  class ::Time
    def to_ms
      (self.to_f * 1000.0).to_i
    end
  end

  def initialize(cache = S3Cache.new)
    @cache = cache
  end

  def get(id)
    @start_time = Time.now.to_ms

    begin
      cached_data = @cache.get(id)

      if(stale? id)
        Thread.new do
          resource = NewsResource.new(id)
          @cache.put(id,resource.render)
        end
      end

      return render(cached_data, "cached")
    rescue AWS::S3::Errors::NoSuchKey
      puts "LOG: No cache found for #{id}"
    rescue
      puts "LOG: Something else went wrong ...."
    end

    resource = NewsResource.new(id)
    Thread.new do
      @cache.put(id,resource.render)
    end

    render(resource.render, "uncached")
  end

  private
  def stale?(id)
    last_updated = @cache.last_updated(id).to_i
    time_since_last_update = Time.now.to_ms - last_updated
    expired = time_since_last_update > CACHE_EXPIRE_AFTER_MS
    puts "LOG: Cache #{expired ? 'GOOD' : 'BAD' } for #{id}, last updated #{time_since_last_update}"

    expired
  end

  def render(data,cache_status)
    puts "LOG: Rendering at #{Time.now.to_ms}"
    data + "<p>(#{Time.now.to_ms}) #{cache_status}: #{Time.now.to_ms - @start_time}</P>"
  end

end
