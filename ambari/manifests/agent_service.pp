# == Class ambari::agent_service
#
# This class is meant to be called from ambari.
# It ensure the service is running.
#
class ambari::agent_service {

  service { $::ambari::agent_service_name:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
