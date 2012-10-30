require 'sinatra'
require 'uber_config'
require 'iron_cache'
require 'logger'

CONFIG = UberConfig.load
p CONFIG
if CONFIG[:iron]
  puts "Iron on board!"
  IRON_CACHE = IronCache::Client.new(CONFIG[:iron])
end
LOGGER = Logger.new(STDOUT)
LOGGER.level = Logger::INFO

# enable :sessions
set :ip_session, {}

before do
  @ip = request.ip
end

get '/' do
  "This is Rest Test. See <a href=\"https://github.com/treeder/rest_test\">https://github.com/treeder/rest_test</a> for info."
end

get '/code/:code' do
  code(params)
end

post '/code/:code' do
  code(params)
end

# Retrieves a stored value
get '/stored/:key' do
  check_cache
  puts "key: #{params[:key]}"
  IRON_CACHE.cache("requests").get(params[:key]).value
end

def code(params)
  if params[:store]
    puts "storing"
    check_cache
    body = request.body.read
    cache_value = {body: body, url: request.url}
    p cache_value
    IRON_CACHE.cache("requests").put(params[:store], cache_value.to_json, expires_in: 3600)
  end
  code = params[:code].to_i
  if params[:switch_after]
    sa = params[:switch_after].to_i
    st = params[:switch_to].to_i
    return cresp(400, "switch_after must be greater than 1") if sa < 2
    return cresp(400, "switch_to must be valid http code") if st < 100 || st >= 600
    s = "code_#{code}_count"
    settings.ip_session[s] ||= 0
    settings.ip_session[s] += 1
    puts "#{s}: #{settings.ip_session[s]}"
    if settings.ip_session[s] >= sa
      settings.ip_session[s] = 0
      return cresp(st)
    end
  end
  cresp(code)
end

def cresp(code, msg=nil)
  code = code.to_i
  if code < 100 || code >= 600
    return [400, "Invalid code: #{code}"]
  end
  [code, msg || "#{code}"]
end

def check_cache
  unless IRON_CACHE
    raise "NO CACHE FOUND!"
  end
end