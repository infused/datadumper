require File.join(File.dirname(__FILE__), 'abstract_unit')
require File.join(File.dirname(__FILE__), 'fixtures/widget')

class DatadumperTest < Test::Unit::TestCase
  fixtures :widgets
  
  def test_database_read_write
    assert_equal widgets(:widget_one), Widget.find(1)
    widget = Widget.new :name => 'Test Widget'
    assert widget.save
    assert_equal widget, Widget.find(widget.id)
  end
  
end