require 'helper'

class ElasticsearchMysqlImporterTest < Test::Unit::TestCase

  TEST_MYSQL_CONFIG = {
    :host => '127.0.0.1',
    :port => '3306',
    :username => 'travis',
    :password => '',
    :database => 'elasticsearch_mysql_importer',
    :encoding => 'utf8'
  }

  TEST_PREPARED_QUERY = '
    CREATE TEMPORARY TABLE tmp_member_skill
    SELECT 
      members.id AS member_id,
      skills.name AS skill_name,
      skills.url AS skill_url
    FROM
      members
      LEFT JOIN member_skill_relation ON members.id = member_id
      LEFT JOIN skills ON skills.id = skill_id;
  '
  TEST_QUERY = '
    SELECT
      members.id AS member_id,
      members.name AS member_name,
      "SELECT skill_name, skill_url FROM tmp_member_skill WHERE member_id = ${member_id}" AS skills
    FROM
      members
    ;
  '
  TEST_QUERY_PRIMARY_KEY = 'member_id'
  TEST_WRITE_FILE_PATH = '/tmp/elasticsearch_mysql_importer_generated_requests.json'

  TEST_ELASTICSEARCH_CONFIG = {
    :host => '127.0.0.1',
    :port => '9200',
    :index => 'importer_example',
    :type => 'member_skill'
  }

  def setup
    setup_database
    setup_importer
  end

  def setup_database
    # demo tables has imported in .travis.yml
  end

  def setup_importer
    @importer = ElasticsearchMysqlImporter::Importer.new
    @importer.configure do |config|
      # Configure mysql connection
      config.mysql_host = TEST_MYSQL_CONFIG[:host]
      config.mysql_username = TEST_MYSQL_CONFIG[:username]
      config.mysql_password = TEST_MYSQL_CONFIG[:password]
      config.mysql_database = TEST_MYSQL_CONFIG[:database]
      config.mysql_encoding = TEST_MYSQL_CONFIG[:encoding]

      # Configure database queries
      config.prepared_query = TEST_PREPARED_QUERY
      config.query = TEST_QUERY
      config.primary_key = TEST_QUERY_PRIMARY_KEY
      config.output_file = TEST_WRITE_FILE_PATH

      # Configure elasticsearch connection
      config.elasticsearch_host = TEST_ELASTICSEARCH_CONFIG[:host]
      config.elasticsearch_port = TEST_ELASTICSEARCH_CONFIG[:port]
      config.elasticsearch_index = TEST_ELASTICSEARCH_CONFIG[:index]
      config.elasticsearch_type = TEST_ELASTICSEARCH_CONFIG[:type]
    end
  end
 
  def test_write_file
    @importer.write_file
    expect_file = IO.read("test/data/elasticsearch_bulk_import_file.json")
    generated_file = IO.read(TEST_WRITE_FILE_PATH)
    assert_equal(expect_file, generated_file)
  end

  def test_write_elasticsearch
    @importer.write_file
    @importer.write_elasticsearch
    elasticsearch_uri_endpoint = "http://#{TEST_ELASTICSEARCH_CONFIG[:host]}:#{TEST_ELASTICSEARCH_CONFIG[:port]}/#{TEST_ELASTICSEARCH_CONFIG[:index]}/#{TEST_ELASTICSEARCH_CONFIG[:type]}"
    expect_result_hits = Yajl::Parser.parse(IO.read("test/data/elasticsearch_search_result.json"))['expect_records']
    expect_result_hits.each.with_index(1) do |expect_record, id|
      search_response = Net::HTTP.get(URI.parse("#{elasticsearch_uri_endpoint}/#{id}"))
      current_result_hits = Yajl::Parser.parse(search_response)
      assert_equal(expect_record, current_result_hits)
    end
  end
end
