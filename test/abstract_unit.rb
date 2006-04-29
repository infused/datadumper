f = File.dirname(__FILE__)

$:.unshift(f + '/../lib')

require 'test/unit'
require File.expand_path(File.join(f, '../../../../config/environment.rb'))
require 'active_record/fixtures'

config = YAML::load(IO.read(f + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(f + '/debug.log')
ActiveRecord::Base.establish_connection('sqlite')

#load(f + '/schema.rb')