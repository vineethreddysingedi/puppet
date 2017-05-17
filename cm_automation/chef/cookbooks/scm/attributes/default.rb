# Author:: Ashrith (<ashrith@cloudwick.com>)
# Cookbook Name:: scm
# Attributes:: default
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

include_attribute "java" # loads java/attributes/default.rb

default[:scm][:version] = '4'
default[:scm][:reposerver] = 'http://archive.cloudera.com'
case node['platform']
when "redhat","centos"
  default[:scm][:yumbase] = "/cm#{node[:scm][:version]}/redhat/#{node['platform_version'].split(".")[0]}/#{node['kernel']['machine']}/cm"
  default[:scm][:yumpath] = "#{node[:scm][:yumbase]}/#{node[:scm][:version]}"
  default[:scm][:gpgkey] = "#{node[:scm][:yumbase]}/RPM-GPG-KEY-cloudera"
when "ubuntu"
  default[:scm][:aptpath] = "/cm#{node[:scm][:version]}/ubuntu/#{node['lsb']['codename']}/#{node['kernel']['machine']  =~ /x86_64/ ? 'amd64' : 'i686'}/cm"
  default[:scm][:aptrelease] = "#{node['lsb']['codename']}-cm#{node[:scm][:version]}"
  default[:scm][:aptrepos] = " contrib"
  default[:scm][:archive_key] = "#{node[:scm][:reposerver]}#{node[:scm][:aptpath]}/archive.key"
else
  Chef::Log.error("Unknown Platform Family [#{node['platform']}]")
end
default[:scm][:server_port] = '7182'
default[:scm][:java_home] = node[:java][:home]
