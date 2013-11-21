require 'rubygems'
require 'spork'

start_simplecov = -> do
  if ENV["COVERAGE"] != "false"
    require 'simplecov'
    SimpleCov.start 'rails' do
      minimum_coverage 80

      add_group "Services", "app/services"
      add_group "Workflows", "app/workflows"
      add_group "Workers", "app/workers"
    end
  else
    puts "skipping simplecov"
  end
end

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'

  Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

  start_simplecov.call if !ENV['DRB']

  WebMock.disable_net_connect!

  RSpec.configure do |config|
    config.fixture_path = "#{::Rails.root}/spec/fixtures"
    config.use_transactional_fixtures = true
    config.infer_base_class_for_anonymous_controllers = false
    config.order = "random"
    config.include FactoryGirl::Syntax::Methods
  end
end

Spork.each_run do
  ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)
  start_simplecov.call if ENV['DRB']
end

