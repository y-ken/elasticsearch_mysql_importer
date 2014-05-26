require 'mysql2'
require 'yajl'
require 'tempfile'
require "net/http"
require "uri"

module ElasticsearchMysqlImporter
  class Importer

    attr_accessor :output_file

    def configure
      @configuration ||= Configuration.new
      yield(@configuration) if block_given?
      validate_configuration
    end

    def write_file
      if @configuration.output_file.nil?
        raise "Missing Configuration: 'output_file' is required."
      end
      create_import_file
    end

    private
    def validate_configuration
      if @configuration.mysql_database.nil? or @configuration.query.nil?
        raise "Missing Configuration: 'mysql_database' or 'query' are required."
      end
    end

    def connect_db
      if not @configuration.mysql_socket.nil?
        # not tested yet
        Mysql2::Client.new({
          :host => @configuration.mysql_host,
          :socket => @configuration.mysql_socket,
          :username => @configuration.mysql_username,
          :password => @configuration.mysql_password,
          :database => @configuration.mysql_database,
          :encoding => @configuration.mysql_encoding,
          :reconnect => true
        })
      else
        Mysql2::Client.new({
          :host => @configuration.mysql_host,
          :port => @configuration.mysql_port,
          :username => @configuration.mysql_username,
          :password => @configuration.mysql_password,
          :database => @configuration.mysql_database,
          :encoding => @configuration.mysql_encoding,
          :reconnect => true
        })
      end
    end

    def get_file_io_object
      if @configuration.output_file.nil?
        file = Tempfile.open(['elasticsearch_mysql_importer_','.json'])
      else
        file = File.open(@configuration.output_file, 'w+')
      end
      @output_file = file.path
      return file
    end

    def create_import_file
      file = get_file_io_object
      db = connect_db
      db.query(@configuration.prepared_query, @configuration.mysql_options)
      db.query(@configuration.query, @configuration.mysql_options).each do |row|
        row.select {|k, v| v.to_s.strip.match(/^SELECT/i) }.each do |k, v|
          row[k] = [] unless row[k].is_a?(Array)
          db.query(v.gsub(/\$\{([^\}]+)\}/) {|matched| row[$1].to_s}).each do |nest_row|
            row[k] << nest_row
          end
        end
        header = { 
          "index" => {
            "_index" => @configuration.elasticsearch_index,
            "_type" => @configuration.elasticsearch_type,
            "_id" => row[@configuration.primary_key]
          }
        }
        file.puts(Yajl::Encoder.encode(header))
        file.puts(Yajl::Encoder.encode(row))
      end
      return file.path
    end
  end
end
