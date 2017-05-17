#CM Automation

##Automating Cloudera Manager Installation using Chef
###Installing Chef Server
You can manually install chef server or use automated script as below:

```
curl https://raw2.github.com/cloudwicklabs/scripts/master/chef_install.sh | bash /dev/stdin -s
```

Verfiy chef setup using 

```
knife client list
```

###Download required cookbooks
Get the `java` and `scm` cookbooks

```
git clone https://github.com/cloudwicklabs/cm_automation.git
```

Install dependency cookbooks:

```
knife cookbook site install apt -o cm_automation/chef/cookbooks
knife cookbook site install yum -o cm_automation/chef/cookbooks
```

Upload all the cookbooks to chef server:

```
knife cookbook upload -o cm_automation/chef/cookbooks --all
```

Also, upload required roles:

```
knife role from file cm_automation/chef/roles/*.rb
```

###Bootstraping chef agents
To install chef agents on the machines that you want to manage use `knife bootstrap`.

Assign roles to the nodes before bootstraping them:

1. Add `cmserver` role to chef server (ex: cs.cw.com):

    ```
    knife bootstrap cs.cw.com -i ~/.ssh/ankus -x root -r "role[cmserver]"
    ```

2. Bootsrap `cmagent` roles on agents (ex: ca[1-5].cw.com):

    ```
    knife bootstrap ca1.cw.com -i ~/.ssh/ankus -x root -r "role[cmagent]"
    knife bootstrap ca2.cw.com -i ~/.ssh/ankus -x root -r "role[cmagent]"
    knife bootstrap ca3.cw.com -i ~/.ssh/ankus -x root -r "role[cmagent]"
    knife bootstrap ca4.cw.com -i ~/.ssh/ankus -x root -r "role[cmagent]"
    knife bootstrap ca5.cw.com -i ~/.ssh/ankus -x root -r "role[cmagent]"
    ```

> Verify the nodes in the cm console @ http://${cmserver}:7180

##Automating Cloudera Manager Installation using Puppet
###Installing Puppet Server
You can manually install puppet server or use this automated script to do so:

```
curl https://raw2.github.com/cloudwicklabs/scripts/master/puppet_install.sh | bash /dev/stdin -s
```

###Installing Puppet Agents
On the machines you want to install puppet agents run the following command, replace the `SERVER_NAME` with your puppet server's fqdn:

```
curl https://raw2.github.com/cloudwicklabs/scripts/master/puppet_install.sh | bash /dev/stdin -c -H SERVER_NAME
```

###Downloading required puppet modules
Download `java` and `scm` puppet modules on the puppet server:

```
git clone https://github.com/cloudwicklabs/cm_automation.git
cp -r cm_automation/puppet/modules/java /etc/puppet/modules/
cp -r cm_automation/puppet/modules/scm /etc/puppet/modules/
```

Install dependency modules:

```
puppet module install puppetlabs-apt
```

###Setup Node Definitions
Now, define nodes (`/etc/puppet/manifests/site.pp`):


```puppet
node 'cs.cw.com' {
    include scm::server
}

node /^ca(\d+)\.cw\.com$/ {
    class { 'scm::agent':
        server_host => 'cs.cw.com'
    }
}
```

Run puppet on all the nodes to get configuration updated

##Deploy Cluster using cm_api
See `cm_api_ruby/example.rb` for usage