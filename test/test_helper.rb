f = File.dirname(__FILE__)

$:.unshift(f + '/../lib')

RAILS_ENV = 'test'

require 'test/unit'
require 'breakpoint'
require File.expand_path(File.join(f, '../../../../config/environment.rb'))
require 'active_record/fixtures'

config = YAML::load(IO.read(f + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(f + '/debug.log')
ActiveRecord::Base.establish_connection(config[ENV['DB'] || 'sqlite3'])

load(f + '/schema.rb')

Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) + "/fixtures/"

class Test::Unit::TestCase #:nodoc:
  def create_fixtures(*table_names)
    if block_given?
      Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, table_names) { yield }
    else
      Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, table_names)
    end
  end
end