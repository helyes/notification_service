$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'api'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'app'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'boot'
require 'erb'

Bundler.require :default, ENV['RACK_ENV']

require_rel '../app'
require_rel '../api'
require_rel '../lib'

db_config = YAML.load(ERB.new(File.read('config/database.yml')).result)[ENV['RACK_ENV']]

# env takes precedence
db_config.each_key { |key| db_config[key] = ENV["db_#{key}"] if ENV["db_#{key}"]}

ActiveRecord::Base.default_timezone = :utc
ActiveRecord::Base.establish_connection(db_config)

