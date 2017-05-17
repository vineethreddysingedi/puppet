# == Class: scm::repo
#
# This class install repositories required for cloudera manager
#
# === Parameters:
#
# [*cm_reposerver*]
#   URI of the YUM server.
#   Default: http://archive.cloudera.com
#
# [*cm_version*]
#   The version of Cloudera Manager to install.
#   Default: 4
#
# === Requires:
#
# puppetlabs-apt
#
# === Sample Usage:
#
#   class { 'scm::repo':
#     cm_version  => '4.1',
#   }
#
# === Authors:
#
# Ashrith <ashrith@cloudwick.com>
#
# === Copyright:
#
# Copyright (C) 2013 Cloudwick, unless otherwise noted.
#
class scm::repo (
  $cm_reposerver  = $scm::params::cm_reposerver,
  $cm_version     = $scm::params::cm_version,
  ) inherits scm::params {
  case $::operatingsystem {
    'Ubuntu': {
      # deb http://archive.cloudera.com/cm4/<OS-release-arch-cm> <RELEASE>-cm4 contrib
      # deb [arch=amd64] http://archive.cloudera.com/cdh4/ubuntu/lucid/amd64/cm lucid-cm4 contrib      
      include apt
      apt::source { 'cloudera-manager':
        location    => "[arch=${::architecture}] ${cm_reposerver}${scm::params::cm_aptpath}",
        release     => "${scm::params::cm_aptrelease}",
        repos       => "${scm::params::cm_aptrepos}",
        include_src => true,
        notify      => [Exec["apt-update"], Exec["cloudera-manager-repo-key"]]
      }
      exec { 'cloudera-manager-repo-key':
        command => "curl -s ${cm_reposerver}${scm::params::cm_aptpath}${scm::params::cm_archive_key} | sudo apt-key add -",
        refreshonly => true,
      }      
      exec { "apt-update":
        command => "/usr/bin/apt-get update",
        refreshonly => true,
      }
    }
    'CentOS', 'Redhat': {
      # http://archive.cloudera.com/cm4/redhat/6/x86_64/cm/4/
      yumrepo { 'cloudera-manager':
        descr          => 'Cloudera Manager',
        enabled        => 1,
        gpgcheck       => 1,
        gpgkey         => "${cm_reposerver}${scm::params::cm_gpgkey}",
        baseurl        => "${cm_reposerver}${scm::params::cm_yumpath}",
        priority       => $scm::params::yum_priority,
        protect        => $scm::params::yum_protect
      }
    }
    default: {
      fail('Supported OS are CentOS, Ubuntu')
    }
  }
}