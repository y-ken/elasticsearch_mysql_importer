# coding: utf-8
require 'elasticsearch_mysql_importer'

importer = ElasticsearchMysqlImporter::Importer.new
importer.configure do |config|
  # required
  config.mysql_host = 'localhost'
  config.mysql_username = 'your_mysql_username'
  config.mysql_password = 'your_mysql_password'
  config.mysql_database = 'some_database'

  # optional, but it is required only generating nested documents
  config.prepared_query = '
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
  # required for importing into elasticsearch
  config.query = '
    SELECT
      members.id AS member_id,
      members.name AS member_name,
      "SELECT skill_name, skill_url FROM tmp_member_skill WHERE member_id = ${member_id}" AS skills
    FROM
      members
    ;
  '
  # required for using unique index into elasticsearch
  config.primary_key = 'member_id'

  # required for specifying elasticsearch index and type
  config.elasticsearch_index = 'importer_example'
  config.elasticsearch_type = 'member_skill'

  # required for writing output file path
  config.output_file = 'example/requests.json'
end

importer.write_file
puts "Done."
puts "The output file is written at '#{importer.output_file}'"
puts "Let's try importing file with following curl command."
puts "e.g.) curl -s -XPOST localhost:9200/_bulk --data-binary @#{importer.output_file}"
