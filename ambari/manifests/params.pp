# == Class ambari::params
#
# This class is meant to be called from ambari.
# It sets variables according to platform.
#
class ambari::params {
  
  $operatingsystemmajorrelease = regsubst($::operatingsystemrelease, '([^.]*)[.].*', '\1')
  
  $version = '2.5.0.3'
  
  case $::osfamily {
    'RedHat', 'Amazon': {
      $agent_package_name  = 'ambari-agent'
      $agent_service_name  = 'ambari-agent'
      $server_package_name = 'ambari-server'
      $server_service_name = 'ambari-server'
      $yum_baseurl         = "http://public-repo-1.hortonworks.com/ambari/centos${operatingsystemmajorrelease}/2.x/updates/${version}"
      $yum_gpgkey          = "http://public-repo-1.hortonworks.com/ambari/centos${operatingsystemmajorrelease}/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins"
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
