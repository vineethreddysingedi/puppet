# == Class: ambari
#
# Full description of class ambari here.
#
# === Parameters
#
# [*serverhostname*]
#   Points to the host running ambari-server.
#
class ambari (
  $serverhostname     = 'compute-56.cloudwickdc.local',
  $agent_package_name = $::ambari::params::agent_package_name,
  $agent_service_name = $::ambari::params::agent_service_name,
  $yum_baseurl        = $::ambari::params::yum_baseurl,
  $yum_gpgkey         = $::ambari::params::yum_gpgkey,
) inherits ::ambari::params {

  validate_string($serverhostname)

  class { '::ambari::repo': } ->
  class { '::ambari::agent_install': } ->
  class { '::ambari::agent_config': } ~>
  class { '::ambari::agent_service': } ->
  Class['::ambari']
}
