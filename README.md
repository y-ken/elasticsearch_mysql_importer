# elasticsearch_mysql_importer

It is importing from mysql table with SQL to elasticsearch. Not only that, it could generating nested documents.

## Usage

    # Clone repository
    $ git clone https://github.com/y-ken/elasticsearch_mysql_importer.git
    $ cd elasticsearch_mysql_importer
    $ bundle install --path vendor/bundle
    
    # Setup mysql connection and query
    $ vim example.rb
    
    # Execute script, then it outputs result into ./requests.json
    $ bundle exec ruby example/example.rb 
    
    # Index document for elasticsearch
    $ curl -s -XPOST localhost:9200/_bulk --data-binary @example/requests.json

## TODO

Pull requests are very welcome!!

* add test
* support thread
* call elasticsearch bluk api directory
* support CLI command

## Contributing

1. Fork it ( https://github.com/y-ken/elasticsearch_mysql_importer/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Copyright

Copyright © 2014- Kentaro Yoshida ([@yoshi_ken](https://twitter.com/yoshi_ken))

## License

MIT License
