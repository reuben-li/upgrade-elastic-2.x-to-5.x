echo '[elasticsearch-5.x]
name=Elasticsearch repository for 5.x packages
baseurl=https://artifacts.elastic.co/packages/5.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md' >  /etc/yum.repos.d/elasticsearch.repo

sudo yum install elasticsearch -y
sudo chkconfig --add elasticsearch
sudo /usr/share/elasticsearch/bin/elasticsearch-plugin remove cloud-aws
sudo /usr/share/elasticsearch/bin/elasticsearch-plugin remove marvel-agent
sudo /usr/share/elasticsearch/bin/elasticsearch-plugin remove license
echo 'y' | sudo /usr/share/elasticsearch/bin/elasticsearch-plugin install discovery-ec2
echo 'y' | sudo /usr/share/elasticsearch/bin/elasticsearch-plugin install x-pack
sed -i 's/node.rack/node.attr.rack/g' /etc/elasticsearch/elasticsearch.yml
sed -i 's/bootstrap.mlockall/bootstrap.memory_lock/g' /etc/elasticsearch/elasticsearch.yml
sed -i '/indices.recovery.concurrent_streams/d' /etc/elasticsearch/elasticsearch.yml
sed -i 's/discovery.zen.ping.timeout/discovery.zen.ping_timeout/g' /etc/elasticsearch/elasticsearch.yml
sed -i '/discovery.zen.ping.multicast.enabled/d' /etc/elasticsearch/elasticsearch.yml
sed -i '/action.disable_shutdown/d' /etc/elasticsearch/elasticsearch.yml
sed -i '/action.disable_delete_all_indices/d' /etc/elasticsearch/elasticsearch.yml
sed -i 's/65535/65536/g' /etc/security/limits.d/elasticsearch.conf
sudo service elasticsearch restart
sudo service elasticsearch status
