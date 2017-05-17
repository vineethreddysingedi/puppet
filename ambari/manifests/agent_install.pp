# == Class ambari::agent_install
#
# This class is called from ambari for install.
#
class ambari::agent_install {

  package { $::ambari::agent_package_name:
    ensure => present,
  }
}
