# == Class ambari::agent_config
#
# This class is called from ambari for service config.
#
class ambari::agent_config {

  file_line { 'ambari-agent-ini-hostname':
    ensure  => present,
    path    => '/etc/ambari-agent/conf/ambari-agent.ini',
    line    => "hostname=${::ambari::serverhostname}", # server host name
    match   => 'hostname=*',
    require => Class['ambari::agent_install']
  }
}
