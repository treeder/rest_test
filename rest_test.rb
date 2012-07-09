require 'sinatra'

get '/' do
  'Hello world!'
end

get '/503' do
  [503, "bad"]
end
