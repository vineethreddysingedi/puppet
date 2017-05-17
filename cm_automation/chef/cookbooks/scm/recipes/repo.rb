# Author:: Ashrith (<ashrith@cloudwick.com>)
# Cookbook Name:: scm
# Recipe:: repo
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

case node['platform']
when "ubuntu"
  apt_repository "cloudera-manager" do
    # deb [arch=amd64] http://archive.cloudera.com/cdh4/ubuntu/lucid/amd64/cm lucid-cm4 contrib      
    uri "[arch=#{node['kernel']['machine']  =~ /x86_64/ ? 'amd64' : 'i686'}] #{node[:scm][:reposerver]}#{node[:scm][:aptpath]}"
    distribution node[:scm][:aptrelease]
    components ["contrib"]
    deb_src true
    key node[:scm][:archive_key]
    action :add
  end
when "redhat","centos"
  yum_repository "cloudera-manager" do
    description "Cloudera Manager RPM Repository"
    url "#{node[:scm][:reposerver]}#{node[:scm][:yumpath]}"
    action :add
    gpgkey "#{node[:scm][:reposerver]}#{node[:scm][:gpgkey]}"
  end
else
  Chef::Log.warn("Adding the #{node['platform_family']} cloudera-manager repository is not yet not supported by this cookbook")
end