require_relative 'cm_api'
require 'pp'

# Name of the cluster that will be managed by CM
CLUSTER = "prod001"

# Initialize the cloudera manager object using the cm server hostname and credentials to login
cm_api = CMApi.new("admin", "admin", "ec2-54-214-230-205.us-west-2.compute.amazonaws.com")
# Check the hosts connected to the cm server
hosts = cm_api.get('/hosts').parsed_response['items']

# Create new cluster, with specified CDH version
cm_api.create_cluster(CLUSTER, "CDH4")

# Create a service, with the logical name of the service and type of the service
cm_api.create_service(CLUSTER, "hdfs001", "HDFS")

# Create hosts, on which the services will be managed on
HOSTNAMES = [
  ["ip-10-250-78-178.us-west-2.compute.internal", "10.250.78.178"],
  ["ip-10-251-57-189.us-west-2.compute.internal", "10.251.57.189"],
  ["ip-10-224-23-22.us-west-2.compute.internal", "10.224.23.22"],
  ["ip-10-224-19-190.us-west-2.compute.internal", "10.224.19.190"]
]

# Create host objects if they are not already added to the cloudera manager
HOSTNAMES.each do |host|
  cm_api.create_host(
    host[0],  # hostid
    host[0],  # host name (fqdn)
    host[1]   # ip address
  )
end

# Install cloudera manager agents on hosts, supports from v6 of the api
=begin
hosts = [] # hosts to install cm agents on
HOSTNAMES.each do |host|
  hosts << host[0]
end
cmd_ids = cm_api.install_cm_agent("root", hosts, :privateKey => File.expand_path('~/.ssh/ankus'))
cmd_ids.each do |cmd|
  cm_api.command_status(cmd)
end
=end

# Create roles for servers
cm_api.create_role(CLUSTER, "hdfs001", "hdfs001-nn", "NAMENODE", HOSTNAMES[0][0])
cm_api.create_role(CLUSTER, "hdfs001", "hdfs001-snn", "SECONDARYNAMENODE", HOSTNAMES[0][0])
HOSTNAMES[1..-1].each_with_index do |host, index|
  cm_api.create_role(CLUSTER, "hdfs001", "hdfs001-dn#{index+1}", "DATANODE", host[0])
end

# Download, Distribute and Activate Parcels - CDH
available_parcels = cm_api.list_available_parcels(CLUSTER) # => {"IMPALA"=>"1.2.3-1.p0.97", "SOLR"=>"1.1.0-1.cdh4.3.0.p0.21", "CDH"=>"4.5.0-1.cdh4.5.0.p0.30"}
cm_api.start_parcel_download(CLUSTER, 'CDH', available_parcels['CDH'])
cm_api.distribute_parcel(CLUSTER, 'CDH', available_parcels['CDH'])
cm_api.activate_parcel(CLUSTER, 'CDH', available_parcels['CDH'])

# Update config for the several hdfs roles
hdfs_service_config = {
  'dfs_replication' => '1'
}
nn_config = {
  'dfs_name_dir_list' => '/dfs/nn',
  'dfs_namenode_handler_count' => '30'
}
snn_config = {
  'fs_checkpoint_dir_list' => '/dfs/snn'
}
dn_config = {
  'dfs_data_dir_list' => '/dfs/dn1,/dfs/dn2,/dfs/dn3',
  'dfs_datanode_failed_volumes_tolerated' => '1',  
}
cm_api.update_service_config(CLUSTER, "hdfs001", hdfs_service_config)
cm_api.update_role_config(CLUSTER, "hdfs001", "hdfs001-nn", nn_config)
cm_api.update_role_config(CLUSTER, "hdfs001", "hdfs001-snn", snn_config)
HOSTNAMES[1..-1].each_with_index do |host, index|
  cm_api.update_role_config(CLUSTER, "hdfs001", "hdfs001-dn#{index+1}", dn_config)
end

# Format hdfs
cmd_id = cm_api.format_hdfs(CLUSTER, "hdfs001", "hdfs001-nn")
cm_api.command_status(cmd_id)

# Start hdfs
hdfs_roles = ["hdfs001-nn", "hdfs001-snn"]
HOSTNAMES[1..-1].each_with_index do |host, index|
  hdfs_roles << "hdfs001-dn#{index+1}"
end  
cmd_ids = cm_api.start_service(CLUSTER, "hdfs001", hdfs_roles)
cmd_ids.each do |cmd|
  cm_api.command_status(cmd)
end