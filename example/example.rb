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

  # To post index directory into elasticsearch,
  # configure following two lines and call 'write_elasticsearch' method.
  # config.elasticsearch_host = 'localhost' # default: localhost
  # config.elasticsearch_port = 9200 # default: 9200

  # required for specifying elasticsearch index and type
  config.elasticsearch_index = 'importer_example'
  config.elasticsearch_type = 'member_skill'

  # required for writing output file path
  config.output_file = 'example/requests.json'
end

if importer.write_file
  puts "Finished to run importer.write_file."
  puts "The output file is written at '#{importer.output_file}'"
  puts "Let's try importing file with following curl command."
  puts "e.g.) curl -s -XPOST localhost:9200/_bulk --data-binary @#{importer.output_file}\n\n"
end

# To post index directory into elasticsearch, 
# uncommented out following line instead of calling 'write_file' method.
#if importer.write_elasticsearch 
#  puts "Finished to run importer.write_elasticsearch."
#  puts "Let's checking results of index with following curl command."
#  puts "e.g.) curl localhost:9200/importer_example/_search?pretty=1"
#end
