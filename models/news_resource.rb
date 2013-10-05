require 'rest_client'

class NewsResource
  BASE_URL = "http://www.bbc.co.uk/news"

  def initialize(id)
    @response = get(id)
  end

  def render
    @response.code == 200 ? @response.body : nil
  end

  private
  def get(object_id)
    RestClient.get "#{BASE_URL}/#{object_id}"
  end
end

