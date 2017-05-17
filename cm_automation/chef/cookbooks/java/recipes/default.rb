# Author:: Ashrith (<ashrith@cloudwick.com>)
# Cookbook Name:: java
# Recipe:: default
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

directory node[:java][:base_dir] do
  recursive true
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

cookbook_file "#{node[:java][:base_dir]}/#{node[:java][:tarball]}" do
  source node[:java][:tarball]
  mode 0755
  owner 'root'
  group 'root'
end

execute "extract jdk" do
  cwd node[:java][:base_dir]
  command "tar xzf #{node[:java][:tarball]}"
  creates node[:java][:home]
end

include_recipe 'java::set_java_home'
