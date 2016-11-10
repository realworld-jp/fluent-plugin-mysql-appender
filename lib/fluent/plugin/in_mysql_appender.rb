module Fluent
  class MysqlAppenderInput < Fluent::Input
    Plugin.register_input('mysql_appender', self)

    # Define `router` method to support v0.10.57 or earlier
    unless method_defined?(:router)
      define_method("router") { Engine }
    end

    def initialize
      require 'mysql2'
      super
    end

    config_param :host, :string, :default => 'localhost'
    config_param :port, :integer, :default => 3306
    config_param :username, :string, :default => 'root'
    config_param :password, :string, :default => nil, :secret => true
    config_param :database, :string, :default => nil
    config_param :encoding, :string, :default => 'utf8'
    config_param :last_id, :integer, :default => -1
    config_param :limit, :integer, :default => 100
    config_param :query, :string
    config_param :time_column, :string, :default => nil
    config_param :primary_key, :string, :default => 'id'
    config_param :interval, :string, :default => '1m'
    config_param :tag, :string, :default => nil

    def configure(conf)
      super
      @interval = Config.time_value(@interval)

      if @tag.nil?
        raise Fluent::ConfigError, "mysql_appender: missing 'tag' parameter. Please add following line into config like 'tag replicator.mydatabase.mytable.${event}.${primary_key}'"
      end

      $log.info "adding mysql_appender worker. :tag=>#{tag} :query=>#{@query} :limit=>#{limit} :interval=>#{@interval} sec "
    end

    def start
      @thread = Thread.new(&method(:run))
    end

    def shutdown
      Thread.kill(@thread)
    end

    def run
      begin
        poll
      rescue StandardError => e
        $log.error "mysql_appender: failed to execute query."
        $log.error "error: #{e.message}"
        $log.error e.backtrace.join("\n")
      end
    end

    def poll
      con = get_connection()
      loop do
        rows_count = 0
        start_time = Time.now
        select_query = @query.gsub(/"/,'') + " where #{primary_key} > #{last_id} order by #{primary_key} asc limit #{limit}"
        rows, con = query(select_query, con)
        rows.each_with_index do |row, index|
          tag = format_tag(@tag, {:event => :insert})
          if @time_column.nil? then
              td_time = Engine.now
          else
              td_time = Time.parse(row[@time_column]).to_i
          end
          row.each {|k, v| row[k] = v.to_s if v.is_a?(Time) || v.is_a?(Date) || v.is_a?(BigDecimal)}
          router.emit(tag, td_time, row)
          rows_count += 1
          if index == rows.size - 1
            @last_id = row[@primary_key]
          end
        end
        con.close
        elapsed_time = sprintf("%0.02f", Time.now - start_time)
        $log.info "mysql_appender: finished execution :tag=>#{tag} :rows_count=>#{rows_count} :last_id=>#{last_id} :elapsed_time=>#{elapsed_time} sec"
        sleep @interval
      end
    end

    def format_tag(tag, param)
      pattern = {'${event}' => param[:event].to_s, '${primary_key}' => @primary_key}
      tag.gsub(/(\${[a-z_]+})/) do
        $log.warn "mysql_appender: missing placeholder. :tag=>#{tag} :placeholder=>#{$1}" unless pattern.include?($1)
        pattern[$1]
      end
    end

    def query(query, con = nil)
      begin
        con = con.nil? ? get_connection : con
        con = con.ping ? con : get_connection
        return con.query(query), con
      rescue Exception => e
        $log.warn "mysql_appender: #{e}"
        sleep @interval
        retry
      end
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
