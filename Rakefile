require 'uber_config'
require 'uber_config/pusher'

@config = UberConfig.load
p @config

namespace :config do
  task :push do
    UberConfig::Pusher.push_heroku
  end
end
