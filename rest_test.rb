require 'sinatra'

enable :sessions

get '/' do
  'Hello world!'
end

get '/code/:code' do
  code = params[:code].to_i
  if params[:switch_after]
    sa = params[:switch_after].to_i
    st = params[:switch_to].to_i
    return cret(400, "switch_after must be greater than 1") if sa < 2
    return cret(400, "switch_to must be valid http code") if st < 100 || st >= 600
    s = "code_#{code}_count"
    session[s] ||= 0
    session[s] += 1
    puts "#{s}: #{session[s]}"
    if session[s] >= sa
      session[s] = 0
      return cret(st)
    end
  end
  cret(code)
end

def cret(code, msg=nil)
  code = code.to_i
  if code < 100 || code >= 600
    return [400, "Invalid code: #{code}"]
  end
  [code, msg || "#{code}"]
end
