require 'yaml'
YAML.load("test: data", aliases: true) # Forces alias support globally
# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
Rails.application.initialize!
