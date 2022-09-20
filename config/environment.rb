# Load the Rails application.
require_relative "application"

# Debug Zeitwerk
Rails.autoloaders.log!

# Initialize the Rails application.
Rails.application.initialize!
