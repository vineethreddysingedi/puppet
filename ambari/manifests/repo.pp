# == Class: ambari::repo
#
# This class exists to install and manage yum repositories
# that contain official ambari packages
#
#
# === Parameters
#
# This class does not provide any parameters.
#
#
# === Examples
#
# This class may be imported by other classes to use its functionality:
#   class { 'ambari::repo': }
#
# It is not intended to be used directly by external resources like node
# definitions or other modules.
#
class ambari::repo {
  
  $operatingsystemmajorrelease = regsubst($::operatingsystemrelease, '([^.]*)[.].*', '\1')
  
  case $::osfamily {
    'RedHat': {
      yumrepo { 'ambari':
        descr    => 'ambari',
        baseurl  => $::ambari::yum_baseurl,
        gpgcheck => 1,
        gpgkey   => $::ambari::yum_gpgkey,
        enabled  => 1,
      }
    }
    default: {
      fail("\"${module_name}\" provides no repository information for OSfamily \"${::osfamily}\"")
    }
  }
}