# Elastic Stack config

## Logstash

### Grok patterns
https://github.com/logstash-plugins/logstash-patterns-core/blob/master/patterns/grok-patterns

### Merging logs using a common field
If your logs have a `log_id` or something along those lines, it is possible to merge the logs into a single event before indexing. To do so, use the logstash `aggregate` filter.

### Getting correct dates
`@timestamp` defaults to the time of indexing. To use a correct log timestamp (due to delays or indexing older data), you will have to parse a date field in your log with the `date` filter:

    date {
      match => [ "logdate" , "yyyy-MM-dd HH:mm:ss" ]
    }

This defaults to updating `@timestamp`. If you are using another field as time-field, you can specify this with `target => "field_to_update"`.

### Raw string
If your messages are getting broken up (analyzed) in Kibana visualizations, you could change your elasticsearch index to begin with `logstash-`. E.g. instead of `applog-api-YYYY-MM-DD`, use `logstash-api-YYYY-MM-DD` instead. This will create fields ending with `.raw`, which will keep entire strings.

### Getting fields for Time-field

    date {
      match => [ "logdate" , "yyyy-MM-dd HH:mm:ss.SSS" ]
      target => "time"
    }

### Testing configuration changes
If you want to run a test on a config file, set output to stdout only: 

    output {
      stdout { codec => rubydebug }
    }

...and test it with the following command:

    /opt/logstash/bin/logstash -f logstash_test.conf -v  --debug --verbose
    
### Getting spatial information (coordinates and country)
Use the `geoip` filter to create a GeoJSON object with locational information from IP address.

    geoip {
      source => "[incoming_content][headers][true-client-ip]"
    }

Note that you should use `true-client-ip`.

# Elastic Stack 5.x migration

## Upgrading
Add repo and upgrade for elasticsearch, kibana and logstash instances:

    echo '[elasticsearch-5.x]
    name=Elasticsearch repository for 5.x packages
    baseurl=https://artifacts.elastic.co/packages/5.x/yum
    gpgcheck=1
    gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
    enabled=1
    autorefresh=1
    type=rpm-md' >  /etc/yum.repos.d/elasticsearch.repo

    sudo yum install elasticsearch -y
 
## Elasticsearch changes
Plugins are now combined

    sudo /usr/share/elasticsearch/bin/elasticsearch-plugin remove cloud-aws
    sudo /usr/share/elasticsearch/bin/elasticsearch-plugin remove marvel-agent
    sudo /usr/share/elasticsearch/bin/elasticsearch-plugin remove license
    echo 'y' | sudo /usr/share/elasticsearch/bin/elasticsearch-plugin install discovery-ec2
    echo 'y' | sudo /usr/share/elasticsearch/bin/elasticsearch-plugin install x-pack

Configurations changed
    
    sed -i 's/node.rack/node.attr.rack/g' /etc/elasticsearch/elasticsearch.yml
    sed -i 's/bootstrap.mlockall/bootstrap.memory_lock/g' /etc/elasticsearch/elasticsearch.yml
    sed -i '/indices.recovery.concurrent_streams/d' /etc/elasticsearch/elasticsearch.yml
    sed -i 's/discovery.zen.ping.timeout/discovery.zen.ping_timeout/g' /etc/elasticsearch/elasticsearch.yml
    sed -i '/discovery.zen.ping.multicast.enabled/d' /etc/elasticsearch/elasticsearch.yml
    sed -i '/action.disable_shutdown/d' /etc/elasticsearch/elasticsearch.yml
    sed -i '/action.disable_delete_all_indices/d' /etc/elasticsearch/elasticsearch.yml
    sed -i 's/65535/65536/g' /etc/security/limits.d/elasticsearch.conf

## Disabling security
    xpack.security.enabled: false
    
## Non-ingest nodes
    node.ingest: false
