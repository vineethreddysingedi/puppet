require 'httparty'
require 'open-uri'
require 'pp'

class CMApi
  include HTTParty

  def initialize(user, pass, host)
    self.class.basic_auth user, pass
    self.class.base_uri "#{host}:7180/api/#{find_latest_api_version(host, user, pass)}"
  end

  def get(uri)
    self.class.get(uri)
  end

  def post(uri, body = {})
    self.class.post(
      uri, 
      :body => body.to_json, 
      :headers => { 'Content-Type' => 'application/json' }
    )
  end

  def put(uri, body = {})
    self.class.put(
      uri, 
      :body => body.to_json, 
      :headers => { 'Content-Type' => 'application/json' }
    )
  end

  def find_latest_api_version(host, user, pass)
    open("http://#{host}:7180/api/version", :http_basic_authentication=> [user, pass]).string
  end

  # Checks if a method is supported in the current api version
  def supports(version)
    api_version_avilable = find_latest_api_version[-1, 1].to_i
    api_version_passed = version.to_s[-1, 1].to_i
    unless api_version_avilable >= api_version_passed
      raise "method: #{caller[0][/`([^']*)'/, 1]} is not avaible in the current version api: v#{api_version_avilable}"
    end
  end

  def create_cluster(cluster_name, cdh_version)
    unless %w(CDH4 CDH3).include?(cdh_version)
      raise "Cluster version can be either 'CDH4' or 'CDH3'"
    end
    unless cluster_exists?(cluster_name)
      self.post('/clusters', {
          :items => [
            {
              :name => cluster_name,
              :version => cdh_version
            }
          ]
        })
    else
      puts "Cluster #{cluster_name} already exists"
    end
  end

  # checks if a cluster exists or not, returns true if cluster exists and flase if not
  def cluster_exists?(cluster_name)
    existing_clusters = self.get('/clusters')
    cluster_exists = false
    unless existing_clusters.nil?
      existing_clusters['items'].each do |cluster|
        if cluster['name'] == cluster_name.downcase
          cluster_exists = true
        end
      end
    end
    cluster_exists
  end

  def create_service(cluster_name, service_name, service_type)
    valid_services = %w(HDFS MapReduce YARN ZooKeeper HBase Hive Oozie Hue Flume Impala Sqoop Solr)
    unless valid_services.include?(service_type)
      raise "Invalid Service type, valid_services are: #{valid_services.join(', ')}"
    end
    unless self.cluster_exists?(cluster_name)
      raise "Cluster does not exist, please create the cluster first"
    end
    unless service_exists?(cluster_name, service_name)
      self.post("/clusters/#{cluster_name}/services", {
          :items => [
            {
              :name => service_name,
              :type => service_type
            }
          ]
        })
    else
      puts "Service #{service_name} already exists"      
    end
  end

  def service_exists?(cluster_name, service_name)
    existing_services = self.get("/clusters/#{cluster_name}/services")
    service_exists = false
    unless existing_services.nil?
      existing_services['items'].each do |service|
        if service['name'] == service_name.downcase
          service_exists = true
        end
      end
    end
    service_exists
  end

  # Creates a new host entity
  # hostid - unique id for the host
  # host_name - fqdn
  # ip_address - ip address of the host
  def create_host(host_id, host_name, ip_address, rack_id = "/default_rack")
    unless host_exists?(host_id)
      self.post("/hosts", {
          :items => [
            {
              :hostId => host_id,
              :hostname => host_name,
              :ipAddress => ip_address,
              :rackId => rack_id
            }
          ]
        })      
    else
      puts "Host #{host_id} already exists"
    end
  end

  # Checks if a host already exist
  def host_exists?(host_id)
    existing_hosts = self.get('/hosts')
    host_exists = false
    unless existing_hosts.nil?
      existing_hosts['items'].each do |host|
        if host['hostId'] == host_id
          host_exists = true
        end
      end
    end
    host_exists
  end

  # Installs cloudera manager agent on a list of specified hosts, availble from v6
  def install_cm_agent(ssh_username, hosts, opts = {})
    supports :v6
    raise "hosts should be an array" unless hosts.kind_of?(Array)
    default_opts = {
      :userName => ssh_username, # Root access to your hosts is required to install Cloudera packages
      :hostNames => hosts,
      :sshPort => 22,
      :parallelInstallCount => 10
    }
    if opts.has_key?(:password)
      # The password used to authenticate with the hosts. Specify either this or a private key. For 
      # password-less login, use an empty string as password.
      default_opts.merge!({
          :password => opts[:password]
        })
      opts.delete(:password)
    elsif opts.has_key?(:privateKey)
      # The private key to authenticate with the hosts. Specify either this or a password.
      default_opts.merge!({
          :privateKey => opts[:privateKey]
        })
      opts.delete(:privateKey)
      if opts.has_key?(:passphrase)
        default_opts.merge!({
            :passphrase => opts[:passphrase]
          })
        opts.delete(:passphrase)
      end
    end
    self.post("/cm/commands/hostinstall", {
        :items => [
          default_opts
        ]
      })
    if response.response.code == "200"
      response.parsed_response['items'].each do |item|
        cmds << item['id']
      end
      return cmds
    else
      puts "Failed issuing command to start service '#{service_name}'. Reason: #{response.parsed_response}"
      return [ -1 ]
    end    
  end

  # Assigns a role for a specific host
  def create_role(cluster_name, service_name, role_name, role_type, host_id)
    valid_roles = [
      "NAMENODE", "DATANODE", "SECONDARYNAMENODE", "BALANCER", "HTTPFS", 
      "FAILOVERCONTROLLER", "GATEWAY", "JOURNALNODE", "JOBTRACKER", "TASKTRACKER",
      "MASTER", "REGIONSERVER", "RESOURCEMANAGER", "NODEMANAGER", "JOBHISTORY",
      "OOZIE_SERVER", "SERVER", "HUE_SERVER", "BEESWAX_SERVER", "KT_RENEWER", "JOBSUBD",
      "AGENT", "IMPALAD", "STATESTORE", "HIVESERVER2", "HIVEMETASTORE", "WEBHCAT",
      "SOLR_SERVER", "SQOOP_SERVER"
    ]
    unless valid_roles.include?(role_type)
      raise "Invlid role type '#{role_type}', valid roles are: #{valid_roles.join(', ')}"
    end
    if cluster_exists?(cluster_name) && service_exists?(cluster_name, service_name) && host_exists?(host_id)
      self.post("/clusters/#{cluster_name}/services/#{service_name}/roles", {
          :items => [
            {
              :name => role_name,
              :type => role_type,
              :hostRef => {
                :hostId => host_id
              }
            }
          ]
        })
    else
      puts "Problem assigning the specified role '#{role_name}' to '#{host_id}'"
    end
  end

  def update_service_config(cluster_name, service_name, srvconfig)
    response = nil
    if cluster_exists?(cluster_name) && service_exists?(cluster_name, service_name)
      puts "Updating config for #{service_name}"
      response = self.put("/clusters/#{cluster_name}/services/#{service_name}/config", {
          :items => config_to_api_list(srvconfig)
        })
    else
      puts "Problem updating the config for '#{service_name}'"
    end
    if response.response.code == 400
      puts "Bad request: #{response.parsed_response}"
    else
      puts "Reponse: #{response.parsed_response}"
    end
    return response
  end

  def update_role_config(cluster_name, service_name, role_name, srvconfig)
    response = nil
    if cluster_exists?(cluster_name) && service_exists?(cluster_name, service_name)
      response = self.put("/clusters/#{cluster_name}/services/#{service_name}/roles/#{role_name}/config", {
          :items => config_to_api_list(srvconfig)
        })
    else
      puts "Problem updating the config for '#{role_name}'"
    end
    if response.response.code == 400
      puts "Bad request: #{response.parsed_response}"
    else
      puts "Reponse: #{response.parsed_response}"
    end
    return response    
  end

  def config_to_api_list(hash)
    config = []
    hash.each do |k, v|
      config << {:name => k, :value => v}
    end
    config
  end

  #
  # Parcels
  #

  # Returns hash of parcels as product => version
  def list_available_parcels(cluster_name)
    parcels = {}
    response = nil
    if cluster_exists?(cluster_name)
      response = self.get("/clusters/#{cluster_name}/parcels")
    end
    response.parsed_response['items'].each do |parcel|
      parcels[parcel['product']] = parcel['version']
    end
    parcels
  end

  def start_parcel_download(cluster_name, product_name, parcel_version)
    parcel_download_uri = "/clusters/#{cluster_name}/parcels/products/#{product_name}/versions/#{parcel_version}/commands/startDownload"
    parcel_query_uri = "/clusters/#{cluster_name}/parcels/products/#{product_name}/versions/#{parcel_version}"
    response = nil
    if cluster_exists?(cluster_name)
      response = self.post(parcel_download_uri)
    else
      raise "Unable to find the specified cluster '#{cluster_name}'"
    end
    if response.response.code != "200" && ! response.parsed_response['success']
      puts "Failed downloading parcel #{product_name}: #{parcel_version} for cluster: #{cluster_name}. Reason: #{response.parsed_response}"
    else
      puts "parcel downloading issued, waiting for the parcel download to complete"
      download_response = self.get(parcel_query_uri)
      sleep 5
      while download_response.parsed_response['stage'] == "DOWNLOADING"
        printf "\rprogress: #{download_response.parsed_response['state']['progress']}"
        sleep 1
        download_response = self.get(parcel_query_uri)
      end
      puts
      puts "Parcel #{product_name}-#{parcel_version} download complete!"
    end
  end

  def distribute_parcel(cluster_name, product_name, parcel_version)
    parcel_distribute_uri = "/clusters/#{cluster_name}/parcels/products/#{product_name}/versions/#{parcel_version}/commands/startDistribution"
    parcel_query_uri = "/clusters/#{cluster_name}/parcels/products/#{product_name}/versions/#{parcel_version}"
    response = nil
    if cluster_exists?(cluster_name)
      response = self.post(parcel_distribute_uri)
    else
      raise "Unable to find the specified cluster: '#{cluster_name}'"
    end
    if response.response.code != "200" && ! response.parsed_response['success']
      puts "Failed distributing parcel #{product_name}: #{parcel_version} for cluster: #{cluster_name}. Reason: #{response.parsed_response}"
    else
      puts "parcel distributing issued, waiting for the parcel distribution to complete"
      distribute_response = self.get(parcel_query_uri)
      sleep 5
      while distribute_response.parsed_response['stage'] == 'DISTRIBUTING'
        distribute_response =  self.get(parcel_query_uri)
        printf "\rprogress: #{distribute_response.parsed_response['state']['progress']}"
        sleep 1
      end
      puts
      puts "Parcel #{product_name}-#{parcel_version} distribution complete"
    end
  end

  def activate_parcel(cluster_name, product_name, parcel_version)
    parcel_activate_uri = "/clusters/#{cluster_name}/parcels/products/#{product_name}/versions/#{parcel_version}/commands/activate"
    parcel_query_uri = "/clusters/#{cluster_name}/parcels/products/#{product_name}/versions/#{parcel_version}"
    response = nil
    if cluster_exists?(cluster_name)
      response = self.post(parcel_activate_uri)
    else
      raise "Unable to find the specified cluster: '#{cluster_name}'"      
    end
    if response.response.code != "200" && ! response.parsed_response['success']
      puts "Failed activating parcel #{product_name}: #{parcel_version} for cluster: #{cluster_name}. Reason: #{response.parsed_response}"
    else
      puts "parcel activation issued, waiting for the parcel activation to complete"
      activate_response = self.get(parcel_query_uri)
      sleep 5
      while activate_response.parsed_response['stage'] == 'ACTIVATING'
        activate_response =  self.get(parcel_query_uri)
        printf "\rprogress: #{activate_response.parsed_response['state']['progress']}"
        sleep 1
      end
      puts
      puts "Parcel #{product_name}-#{parcel_version} activation complete"
    end    
  end

  #
  # Commands
  #
  def format_hdfs(cluster_name, service_name, role_name)
    response = nil
    if cluster_exists?(cluster_name) && service_exists?(cluster_name, service_name)
      response = self.post("/clusters/#{cluster_name}/services/#{service_name}/roleCommands/hdfsFormat", {
          :items => [ role_name ]
        })
      if response.response.code == "200"
        return response.parsed_response['items'].first['id']
      else
        puts "Failed issuing command to format hdfs. Reason: #{response.parsed_response}"
        return -1
      end      
    else
      raise "Unable to find service '#{service_name}' for cluster '#{cluster}'"
    end
  end

  def start_service(cluster_name, service_name, role_names = [])
    response = nil
    cmds = []
    if cluster_exists?(cluster_name) && service_exists?(cluster_name, service_name)
      response = self.post("/clusters/#{cluster_name}/services/#{service_name}/roleCommands/start", {
          :items => role_names
        })
      if response.response.code == "200"
        response.parsed_response['items'].each do |item|
          cmds << item['id']
        end
        return cmds
      else
        puts "Failed issuing command to start service '#{service_name}'. Reason: #{response.parsed_response}"
        return [ -1 ]
      end
    else
      raise "Unable to find service '#{service_name}' for cluster '#{cluster}'"
    end    
  end

  def command_status(command_id)
    response = self.get("/commands/#{command_id}")
    while response.parsed_response['active'] # command is still running
      printf "\rRunning command with id #{command_id}"
      sleep 1
      response = self.get("/commands/#{command_id}")
    end
    puts
    unless response.parsed_response['success']
      puts "Failed command, reason: #{response.parsed_response['resultMessage']}"
    else
      puts "Sucessfully executed command: #{response.parsed_response['name']}"
    end
  end
end