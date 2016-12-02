require 'helper'

class MysqlAppenderMultiInputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
    # stubs
    stub(File).exist?{:true}
  end

  CONFIG = %[
    host            localhost
    interval        30
    yaml_path       hoge
  ]

  def create_driver(conf=CONFIG)
    Fluent::Test::InputTestDriver.new(Fluent::MysqlAppenderMultiInput).configure(conf)
  end

  def test_configure
    # run test
    d = create_driver
    assert_equal 'localhost', d.instance.host
    assert_equal 30, d.instance.interval
    assert_equal 'appender_multi', d.instance.tag
  end

  def test_polling
    str = <<EOS
- table_name: test_tbl1
  primary_key: id
  time_column: created_at
  limit: 1000
  columns:
    - id
    - column1
    - column2
    - created_at
  last_id: -1
  entry_time: created_at
  delay: 3h
  td_database: sample_datasets
- table_name: test_tbl2
  primary_key: id
  time_column: created_at
  limit: 1000
  columns:
    - id
    - column1
    - column2
    - created_at
  last_id: -1
  entry_time: created_at
  delay: 3h
  td_database: sample_datasets
EOS
    conf = YAML.load(str)
    stub(YAML).load_file{conf}

    d = create_driver
    d.run do
      sleep 2
    end
  end
end
