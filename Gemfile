source 'https://rubygems.org'

# Specify your gem's dependencies in que_mailer.gemspec
gemspec

rails_version = ENV["RAILS_VERSION"] || "default"

rails = case rails_version
when "master"
  {github: "rails/rails"}
when "default"
  "~> 4.0.0"
else
  "~> #{rails_version}"
end

gem 'actionmailer', rails