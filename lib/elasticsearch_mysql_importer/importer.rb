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

    def write_elasticsearch
      call_elasticsearch_bulk_api
    end

    private
    def validate_configuration
      if @configuration.mysql_database.nil? or @configuration.query.nil?
        raise "Missing Configuration: 'mysql_database' and 'query' are required."
      end
      if @configuration.elasticsearch_index.nil? or @configuration.elasticsearch_type.nil?
        raise "Missing Configuration: 'elasticsearch_index' and 'elasticsearch_type' are required."
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
      file.seek 0
      return file.path
    end

    def call_elasticsearch_bulk_api
      begin
        elasticsearch_bulk_uri = "http://#{@configuration.elasticsearch_host}:#{@configuration.elasticsearch_port}/_bulk"
        uri = URI.parse(elasticsearch_bulk_uri)
        data = File.open(@output_file, 'r').read
        raise "Error: generated import file is empty." if data.empty?
        http = Net::HTTP.new(uri.host, uri.port)
        response, body = http.post(uri.path, data, {'Content-type'=>'application/json'})
      rescue Timeout::Error, StandardError => e
        puts "Failed to call Bulk API: #{e.message}"
      end
    end
  end
end
