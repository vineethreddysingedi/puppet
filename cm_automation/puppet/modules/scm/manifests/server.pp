# Class: scm::server
#
# Only supports embedded postrgres for now.
# TODO: support for mysql, oracle, external postrgres
class scm::server(
  $ensure         = $scm::params::ensure,
  $autoupgrade    = $scm::params::safe_autoupgrade,
  $service_ensure = $scm::params::service_ensure,
  ) inherits scm::params {
  validate_bool($autoupgrade)

  require java
  require scm::repo

  case $ensure {
    /(present)/: {
      if $autoupgrade == true {
        $package_ensure = 'latest'
      } else {
        $package_ensure = 'present'
      }
      if $service_ensure in [ running, stopped ] {
        $service_ensure_real = $service_ensure
        $service_enable = true
      } else {
        fail('service_ensure parameter must be running or stopped')
      }    
      $file_ensure = 'present'
    }
    /(absent)/: {
      $package_ensure = 'absent'
      $service_ensure_real = 'stopped'
      $service_enable = false
      $file_ensure = 'absent'
    }
    default: {
      fail('ensure parameter must be present or absent')
    }
  }

  package { 'cloudera-manager-server':
    ensure  => $package_ensure,
  }

  file { "/etc/default/cloudera-scm-server":
    ensure => $file_ensure,
    content => template('scm/cloudera-scm-server.erb'),
    require => Package['cloudera-manager-server'],
    notify => Service['cloudera-scm-server']
  }

  service { 'cloudera-scm-server':
    ensure     => $service_ensure_real,
    enable     => $service_enable,
    hasrestart => true,
    hasstatus  => true,
    require    => Package['cloudera-manager-server'],
  }

  package { 'cloudera-manager-server-db':
    ensure  => $package_ensure,
  }

  exec { 'cloudera-manager-server-db':
    command => 'service cloudera-scm-server-db initdb',
    path => '/sbin:/usr/sbin:/usr/bin:/bin',
    creates => '/etc/cloudera-scm-server/db.mgmt.properties',
    require => Package['cloudera-manager-server-db'],
  }

  service { 'cloudera-scm-server-db':
    ensure     => $service_ensure_real,
    enable     => $service_enable,
    hasrestart => true,
    hasstatus  => true,
    require    => Exec['cloudera-manager-server-db'],
    before     => Service['cloudera-scm-server'],
  }
}