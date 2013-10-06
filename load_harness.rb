require './config'
require './models/news_service'

CACHE_EXPIRE_AFTER_MS = 0
STORY_ID = 'uk-24411075'

num_tests = 100
tasks = {
  :threaded => Proc.new {
    news = NewsService.new
    news.get(STORY_ID)
  }
}

tasks.each do |key,task|

  total_time = 0
  num_tests.times do

    t_0 = Time.now
    task.call
    t_1 = Time.now

    time_ms = (t_1-t_0) * 1000.0
    total_time += time_ms
  end

  puts "AVG time for #{key} #{total_time/num_tests}"

end
