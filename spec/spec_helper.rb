require 'bundler/setup'
Bundler.setup

require 'activemodel_flags_spec' # and any other gems you need
require 'temping'

RSpec.configure do |config|
  config.after do
    Temping.teardown
  end
  config.color = true
end