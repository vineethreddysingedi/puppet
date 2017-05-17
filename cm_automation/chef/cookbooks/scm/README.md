scm Cookbook
============
Installs and configures cloudera manager server and agent daemons

Requirements
------------
This cookbook depends on these external cookbooks

* apt
* yum

Install the dependencies:

```
knife cookbook site install apt
knife cookbook site install yum
```

Attributes
----------
* `scm[:version]` - Cloudera manager version to install
* `scm[:reposerver]` - root path from where to install cm packages from
* `scm[:server_port]` - port on which cmserver should listen on
* `scm[:java_home]` - java path to use

Usage
-----
Load the roles of cloduera manager and cloudera agent from the file using:

```
knife role from file roles/cmserver.rb
knife role from file roles/cmsagent.rb
```

Initialize `cmserver` on cmserver.cw.com:

```
knife node run_list add cmserver.cw.com 'role[cmserver]'
knife ssh 'name:cmserver.cw.com' 'sudo chef-client'
```

Initialize `cmagent` on cmagent1.cw.com and cmagent2.cw.com:

```
knife bootstrap cmagent1.cw.com -x ubuntu -i ~/.ssh/id_rsa --sudo -r 'role[cmagent]'
knife bootstrap cmagent2.cw.com -x ubuntu -i ~/.ssh/id_rsa --sudo -r 'role[cmagent]'
```

License and Authors
-------------------
Authors: [Ashrith](ashrith@cloudwick.com)

Copyright: 2013, Cloudwick

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

```
http://www.apache.org/licenses/LICENSE-2.0
```

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.