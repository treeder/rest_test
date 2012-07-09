require 'sinatra'

# enable :sessions
set :ip_session, {}

get '/' do
  "This is the Rest Test. See https://github.com/treeder/rest_test for info."
end

def code(params)
  code = params[:code].to_i
  if params[:switch_after]
    sa = params[:switch_after].to_i
    st = params[:switch_to].to_i
    return cret(400, "switch_after must be greater than 1") if sa < 2
    return cret(400, "switch_to must be valid http code") if st < 100 || st >= 600
    s = "code_#{code}_count"
    settings.ip_session[s] ||= 0
    settings.ip_session[s] += 1
    puts "#{s}: #{settings.ip_session[s]}"
    if settings.ip_session[s] >= sa
      settings.ip_session[s] = 0
      return cret(st)
    end
  end
  cret(code)
end

get '/code/:code' do
  code(params)
end

post '/code/:code' do
  code(params)
end

def cret(code, msg=nil)
  code = code.to_i
  if code < 100 || code >= 600
    return [400, "Invalid code: #{code}"]
  end
  [code, msg || "#{code}"]
end
