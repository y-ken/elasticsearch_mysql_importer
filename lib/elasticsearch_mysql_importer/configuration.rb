module ElasticsearchMysqlImporter
  class Configuration
    attr_accessor :mysql_host, :mysql_port, :mysql_socket, :mysql_username, :mysql_password, :mysql_encoding
    attr_accessor :mysql_database, :mysql_options, :prepared_query, :query, :primary_key, :output_file

    def initialize
      super

      @mysql_host = 'localhost'
      @mysql_port = '3306'
      @mysql_socket = nil
      @mysql_username = 'root'
      @mysql_password = ''
      @mysql_encoding = 'utf8'
      @mysql_options = { :cast => false, :cache_rows => true }
      @primary_key = 'id'
    end
  end
end
