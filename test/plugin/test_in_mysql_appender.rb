require 'helper'

class MysqlAppenderInputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  def create_driver(conf=CONFIG,tag='test')
    Fluent::Test::OutputTestDriver.new(Fluent::MysqlAppenderInputTest, tag).configure(conf)
  end

  def test_configure
    d = create_driver %[
      host            localhost
      interval        30
      tag             input.mysql
      query           SELECT id, text from search_text
    ]
    assert_equal 'localhost', d.instance.host
    assert_equal 30, d.instance.interval
    assert_equal 'input.mysql', d.instance.tag
  end
end
