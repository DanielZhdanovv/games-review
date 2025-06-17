require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
require "rails/test_unit/railtie"
# Fix for LoggerThreadSafeLevel in Rails 6.1 + Ruby 3.1
require "logger"
module ActiveSupport
  module LoggerThreadSafeLevel
    Logger::Severity.constants.each do |severity|
      class_eval <<-EOT, __FILE__, __LINE__ + 1
        def #{severity.downcase}?                # def debug?
          Logger::#{severity} <= level          #   DEBUG <= level
        end                                      # end
      EOT
    end
  end
end

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RailsStaffGroupProject
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
