require 'uber_config'

@config = UberConfig.load
p @config

namespace :config do
  task :push do
    UberConfig::Pusher.push
  end
end
