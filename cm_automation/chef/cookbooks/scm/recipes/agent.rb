# Author:: Ashrith (<ashrith@cloudwick.com>)
# Cookbook Name:: scm
# Recipe:: agent
#
# Copyright 2013, cloudwick
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include_recipe "scm"

package "cloudera-manager-agent" do
  action :install
end

package "cloudera-manager-daemons" do
  action :install
end

template "/etc/default/cloudera-scm-agent" do
  source "cloudera-scm-agent.erb"
  owner "root"
  group "root"
  mode "0644"
  variables({
      :java_home => node[:scm][:java_home]
    })
  notifies :restart, "service[cloudera-scm-agent]"
end

# find the scm server
scm_server = search(:node, 'recipes:scm\:\:server')

template "/etc/cloudera-scm-agent/config.ini" do
  source "scm-config.ini.erb"
  owner "root"
  group "root"
  mode "0644"
  variables({
      :server_host => scm_server.first[:ipaddress],
      :server_port => node[:scm][:server_port]
    })
  notifies :restart, "service[cloudera-scm-agent]"
end

service "cloudera-scm-agent" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end