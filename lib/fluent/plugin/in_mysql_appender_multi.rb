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
      require 'td'
      require 'td-client'
      super
    end

    config_param :host, :string, :default => 'localhost'
    config_param :port, :integer, :default => 3306
    config_param :username, :string, :default => 'root'
    config_param :password, :string, :default => nil, :secret => true
    config_param :database, :string, :default => 'sample_db'
    config_param :encoding, :string, :default => 'utf8'
    config_param :interval, :string, :default => '1m'
    config_param :tag, :string, :default => 'appender_multi'
    config_param :yaml_path, :string, :default => nil

    def configure(conf)
      super
      @interval = Config.time_value(@interval)

      if @yaml_path.nil?
        raise Fluent::ConfigError, "mysql_appender_multi: missing 'yaml_path' parameter."
      end

      if !File.exist?(@yaml_path)
        raise Fluent::ConfigError, "mysql_appender_multi: No such file in 'yaml_path'."
      end
    end

    def start
      @thread = Thread.new(&method(:run))
    end

    def shutdown
      Thread.kill(@thread)
    end

    private

    def run
      begin
        # initialize
        configs = YAML.load_file(@yaml_path)
        configs.each do |config|
          config['last_id'] = get_lastid(config)
          config['tag'] = format_tag(config)
          config['delay'] = Config.time_value(config['delay'] || 0)
        end

        loop do
          db = get_connection
          configs.each do |config|
            db.query(get_query(config)).each do |row|
              rows_count = 0
              if !config['entry_time'].nil? then
                entry_time = get_time(row[config['entry_time']])
                if (start_time - config['delay']) < entry_time then
                  break
                end
              end
              if config['time_column'].nil? then
                  td_time = Engine.now
              else
                td_time = get_time(row[config['time_column']]).to_i
              end
              row.each {|k, v| row[k] = v.to_s if v.is_a?(Time) || v.is_a?(Date) || v.is_a?(BigDecimal)}
              router.emit(config['tag'], td_time, row)
              rows_count += 1
              config['last_id'] = row[config['primary_key']]
              $log.info "mysql_appender_multi: :tag=>#{config['tag']} :rows_count=>#{rows_count} :last_id=>#{config['last_id']} "
            end
          end
          db.close
          $log.info "mysql_appender_multi: finished execution :elapsed_time=>#{elapsed_time} sec"
          sleep @interval
        end
      rescue => e
        $log.error "mysql_appender_multi: failed to execute query. :config=>#{masked_config}"
        $log.error "error: #{e.message}"
        $log.error e.backtrace.join("\n")
      end
    end

    def get_lastid(config)
      begin
        if !ENV.key?('TD_APIKEY') || !ENV.key?('TD_ENDPOINT') || !ENV.key?('TD_DATABASE') then
          return -1
        end
        cln = TreasureData::Client.new(ENV['TD_APIKEY'],{:endpoint => "https://" + ENV['TD_ENDPOINT']})
        table_exists = false
        cln.databases.each { |db|
          db.tables.each { |tbl|
            if tbl.db_name == ENV['TD_DATABASE'] && tbl.table_name == config['table_name'] then
                table_exists = true
                break
            end
          }
        }
        if table_exists then
          query = "SELECT MAX(#{config['primary_key']}) FROM #{config['table_name']}"
          job = cln.query(ENV['TD_DATABASE'], query, nil, nil, nil , {:type => :presto})
          until job.finished?
            sleep 2
            job.update_progress!
          end
          job.update_status!  # get latest info
          job.result_each { |row|
            $log.info  "mysql_appender_multi: #{ENV['TD_DATABASE']}.#{config['table_name']}'s last_id is #{row.first} "
            return row.first
          }
        else
          $log.info "mysql_appender_multi: #{ENV['TD_DATABASE']}.#{config['table_name']} is not found. "
          return -1
        end
      rescue => e
        $log.warn "mysql_appender_multi: failed to get lastid. #{config}"
        $log.error "error: #{e.message}"
        $log.error e.backtrace.join("\n")
      end
    end

    def get_query(config)
      "SELECT #{config['columns'].join(",")} FROM #{config['table_name']} where #{config['primary_key']} > #{config['last_id']} order by #{config['primary_key']} asc limit #{config['limit']}"
    end

    def format_tag(config)
      add_db = ENV.key?('TD_DATABASE') ? ENV['TD_DATABASE'] + '.' : ''
      "#{tag}.#{add_db}#{config['table_name']}"
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
      rescue Mysql2::Error => e
        $log.warn "mysql_appender_multi: #{e}"
        sleep @interval
        retry
      end
    end

    def get_time(in_time)
      if in_time.kind_of?(Time) then
        in_time
      else
        Time.parse(in_time.to_s)
      end
    end
  end
end
