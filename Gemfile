source 'https://rubygems.org'
ruby '2.0.0'

gem 'unicorn'
gem 'sinatra', require: 'sinatra/base'
gem 'uuidtools'
gem 'json'
gem 'locale'
gem 'iconv'
gem 'glib2', '~> 1.2.6'
# requires native libraries
#   brew install gstreamer010
#   brew install libxml2
#   brew install gst-plugins-base010
gem 'gstreamer', '1.2.6'  # install older version gstreamer 
gem 'redcarpet'

group :test do
  gem 'rack-test', require: 'rack/test'
  gem 'minitest',  require: 'minitest/autorun'
end

group :production do
  gem 'thin'
  gem 'dalli'
  gem 'rack-cache'
end

group :development do
  # gem 'aws-s3'
  # gem 'warbler', platform: :jruby
  gem 'shotgun', platform: :mri
  gem 'debugger'
end
