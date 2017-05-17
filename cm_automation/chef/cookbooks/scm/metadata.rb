name             'scm'
maintainer       'Cloudwick'
maintainer_email 'ashrith@cloudwick.com'
license          'Apache v2.0'
description      'Installs/Configures cloudera manager'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

recipe "scm", "Installs and configures java and pre-reqs"
recipe "scm::server", "Installs and configures cloudera manager server daemon"
recipe "scm::agent", "Installs and configures cloudera manager agent daemon"
recipe "scm::repo", "Installs and configures cloudera manager repository for apt and yum"

depends          "apt"
depends          "yum"
depends          "java"

%w{ ubuntu centos redhat}.each do |os|
  supports os
end