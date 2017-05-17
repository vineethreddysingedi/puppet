# Class: scm::params
#
#
class scm::params {
  # Repo parameters
  $cm_version  = '4'
  $yum_priority = '50'
  $yum_protect = '0'  
  $cm_reposerver = 'http://archive.cloudera.com'
  case $::operatingsystem {
    'CentOS', 'RedHat': {
      $cm_yumpath = "/cm${cm_version}/redhat/${::operatingsystemmajrelease}/${::architecture}/cm/${cm_version}/"
      $cm_gpgkey = "/cm${cm_version}/redhat/${::operatingsystemmajrelease}/${::architecture}/cm/RPM-GPG-KEY-cloudera"
    }
    'Ubuntu': {
      $cm_aptpath = "/cm${cm_version}/ubuntu/${::lsbdistcodename}/${::architecture}/cm"
      $cm_aptrelease = "${::lsbdistcodename}-cm${cm_version}"
      $cm_aptrepos = " contrib"
      $cm_archive_key = "/archive.key"
    }
    default: {
      fail("Module ${::module} is not supported on ${::operatingsystem}")
    }
  }

  $cm_server_host = $::cloudera_cm_server_host ? {
    undef   => 'localhost',
    default => $::cloudera_cm_server_host,
  }

  $cm_server_port = $::cloudera_cm_server_port ? {
    undef   => '7182',
    default => $::cloudera_cm_server_port,
  }  

  $ensure = $::cloudera_ensure ? {
    undef => 'present',
    default => $::cloudera_ensure,
  }

  $service_ensure = $::cloudera_service_ensure ? {
    undef => 'running',
    default => $::cloudera_service_ensure,
  }  

  $autoupgrade = $::cloudera_autoupgrade ? {
    undef => false,
    default => $::cloudera_autoupgrade,
  }
  if is_string($autoupgrade) {
    $safe_autoupgrade = str2bool($autoupgrade)
  } else {
    $safe_autoupgrade = $autoupgrade
  }

  $use_parcels = $::cloudera_use_parcels ? {
    undef => false,
    default => $::cloudera_use_parcels,
  }
  if is_string($use_parcels) {
    $safe_use_parcels = str2bool($use_parcels)
  } else {
    $safe_use_parcels = $use_parcels
  }  
}
