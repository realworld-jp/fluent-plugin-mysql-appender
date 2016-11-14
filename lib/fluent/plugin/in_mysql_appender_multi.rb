module Fluent
  class MysqlAppenderMultiInput < Fluent::Input
    Plugin.register_input('mysql_appender_multi', self)

    # Define `router` method to support v0.10.57 or earlier
    unless method_defined?(:router)
      define_method("router") { Engine }
    end

    def initialize
      require 'mysql2'
      require 'time'
      require 'yaml'
      super
    end

    config_param :host, :string, :default => 'localhost'
    config_param :port, :integer, :default => 3306
    config_param :username, :string, :default => 'root'
    config_param :password, :string, :default => nil, :secret => true
    config_param :database, :string, :default => nil
    config_param :encoding, :string, :default => 'utf8'
    config_param :interval, :string, :default => '1m'
    config_param :tag, :string, :default => 'appender_multi'
    config_param :yaml_path, :string, :default=> nil

    def configure(conf)
      super
      if @tag.nil?
        raise Fluent::ConfigError, "mysql_appender_multi: missing 'tag' parameter. Please add following line into config like 'tag appender.${name}.${event}.${primary_key}'"
      end
    end

    def start
      begin
        @threads = []
        YAML.load_file(@yaml_path).each do |config|
          @threads << Thread.new {
            poll(config)
          }
        end
        $log.error "mysql_appender_multi: stop working due to empty configuration" if @threads.empty?
      rescue StandardError => e
        $log.error "error: #{e.message}"
        $log.error e.backtrace.join("\n")
      end
    end

    def shutdown
      @threads.each do |thread|
        Thread.kill(thread)
      end
    end

    def poll(config)
      begin
        con = get_connection()
        last_id = config['last_id']
        loop do
          rows_count = 0
          start_time = Time.now
          rows, con = query(get_query(config, last_id), con)
          rows.each_with_index do |row, index|
            tag = format_tag(config)
            if @time_column.nil? then
                td_time = Engine.now
            else
                if row[@time_column].kind_of?(Time) then
                  td_time = row[config['time_column']].to_i
                else
                  td_time = Time.parse(row[config['time_column']].to_s).to_i
                end
            end
            row.each {|k, v| row[k] = v.to_s if v.is_a?(Time) || v.is_a?(Date) || v.is_a?(BigDecimal)}
            router.emit(tag, td_time, row)
            rows_count += 1
            if index == rows.size - 1
              @last_id = row[config['primary_key']]
            end
          end
          con.close
          elapsed_time = sprintf("%0.02f", Time.now - start_time)
          sleep @interval
        end
      rescue StandardError => e
        $log.error "mysql_appender_multi: failed to execute query. :config=>#{masked_config}"
        $log.error "error: #{e.message}"
        $log.error e.backtrace.join("\n")
      end
    end

    def get_query(config, last_id)
      "SELECT #{config['columns'].join(",")} FROM #{config['table_name']} where #{config['primary_key']} > #{last_id} order by #{config['primary_key']} asc limit #{config['limit']}"
    end

    def query(query, con = nil)
      begin
        con = con.nil? ? get_connection : con
        con = con.ping ? con : get_connection
        return con.query(query), con
      rescue Exception => e
        $log.warn "mysql_appender_multi: #{e}"
        sleep @interval
        retry
      end
    end

    def format_tag(config)
      "#{tag}.#{config['database']}.#{config['table_name']}"
    end

    def get_connection
      begin
        return Mysql2::Client.new({
          :host => @host,
          :port => @port,
          :username => @username,
          :password => @password,
          :database => @database,
          :encoding => @encoding,
          :reconnect => true,
          :stream => true,
          :cache_rows => false
        })
      rescue Exception => e
        $log.warn "mysql_appender: #{e}"
        sleep @interval
        retry
      end
    end
  end
end
