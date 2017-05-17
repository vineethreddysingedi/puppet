Java Cookbook
============
Install and manages open jdk

Requirements
------------
#### operating systems
- Redhat
- Debian

Attributes
----------

Usage
-----
#### java::default

Just include `java` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[java]"
  ]
}
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