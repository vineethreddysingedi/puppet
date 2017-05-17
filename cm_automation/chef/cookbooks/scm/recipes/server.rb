# Author:: Ashrith (<ashrith@cloudwick.com>)
# Cookbook Name:: scm
# Recipe:: server
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

package "cloudera-manager-server" do
  action :install
end

template "/etc/default/cloudera-scm-server" do
  source "cloudera-scm-server.erb"
  owner "root"
  group "root"
  mode "0644"
  variables({
      :java_home => node[:scm][:java_home]
    })
  notifies :restart, "service[cloudera-scm-server]"
end

package "cloudera-manager-server-db" do
  action :install
end

execute "cloudera-manager-server-db" do
  command "service cloudera-scm-server-db initdb"
  creates "/etc/cloudera-scm-server/db.mgmt.properties"
  action :run
end

service "cloudera-scm-server-db" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

service "cloudera-scm-server" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end