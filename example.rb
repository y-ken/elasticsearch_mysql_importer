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
  # required
  config.query = '
    SELECT
      members.id AS member_id,
      members.name AS member_name,
      "SELECT skill_name, skill_url FROM tmp_member_skill WHERE member_id = ${member_id}" AS skills,
      current_timestamp
    FROM
      members
    ;
  '
  # required for using unique index for elasticsearch
  config.primary_key = 'member_id'

  # required for outputs file path
  config.output_file = 'requests.json'
end

importer.write_file
p importer.output_file
