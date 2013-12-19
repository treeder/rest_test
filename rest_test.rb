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

# Seems to buffer stdout: https://groups.google.com/forum/?fromgroups=#!topic/heroku/NTTpcQlaM2A
$stdout.sync = true

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

put '/code/:code' do
  code(params)
end

delete '/code/:code' do
  code(params)
end

# Retrieves a stored value
get '/stored/:key' do
  check_cache
  puts "key: #{params[:key]}"
  item = IRON_CACHE.cache(requests_cache_name).get(params[:key])
  if item
    puts "item from cache: " + item.value.inspect
    return item.value
  end
  cresp 404, "No request stored at #{params[:key]}"
end

def sessions_cache_name
  "sessions"
end

def requests_cache_name
  "requests"
end

def namespace_key(params, s)
  # default if no namespace
  return s unless params[:namespace]
  "#{params[:namespace]}::#{s}"
end

def code(params)
  puts "IN CODE"
  if params[:store]
    puts "storing"
    check_cache
    body = request.body.read
    #p extract_headers
    cache_value = {body: body, url: request.url, headers: extract_headers}
    #p cache_value
    puts "Storing at #{params[:store]} value: #{cache_value.inspect}"
    IRON_CACHE.cache(requests_cache_name()).put(params[:store], cache_value.to_json, expires_in: 3600)
  end
  code = params[:code].to_i
  if params[:switch_after]
    sa = params[:switch_after].to_i
    st = params[:switch_to].to_i
    return cresp(400, "switch_after must be greater than 1") if sa < 2
    return cresp(400, "switch_to must be valid http code") if st < 100 || st >= 600
    s = "code_#{code}_count"
    cache = IRON_CACHE.cache(sessions_cache_name)
    hit_count = cache.get(namespace_key(params, s))
    if hit_count
      hit_count = hit_count.value
    else
      hit_count = 0
    end
    hit_count += 1
    puts "HIT COUNT: #{namespace_key(params, s)}: #{hit_count}"
    if hit_count > sa
      hit_count = 0
      #return cresp(st)
      code = st
    end
    cache.put(namespace_key(params, s), hit_count, expires_in: 3600)
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

def extract_headers
  headers = {}
  env.select { |k, v| k.start_with? 'HTTP_' }.collect { |pair| headers[pair[0].sub(/^HTTP_/, '')] = pair[1] }
  #[200, {'Content-Type' => 'text/html'}, headers]
  headers
end