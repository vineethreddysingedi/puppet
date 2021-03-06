# Author:: Ashrith (<ashrith@cloudwick.com>)
# Cookbook Name:: java
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

# remove the deprecated Ubuntu jdk packages
default[:java][:remove_deprecated_packages] = false

# default jdk attributes
default[:java][:version] = '1.6.0_31'
default[:java][:base_dir] = '/opt/java'
default[:java][:tarball] = "jdk#{node[:java][:version]}.tar.gz"
default[:java][:home] = "#{node[:java][:base_dir]}/jdk#{node[:java][:version]}"
default[:java][:arch] = kernel['machine'] =~ /x86_64/ ? "x86_64" : "i586"