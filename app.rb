require 'sinatra'
require './config'

require './models/news_service'

get '/news/:id' do
  news = NewsService.new
  news.get(params[:id])
end

