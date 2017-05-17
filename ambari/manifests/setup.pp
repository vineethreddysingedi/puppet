class ambari::server::setup (
    database=mysql
    databasehost=compute-56.cloudwickdc.local
    databaseport=3306
    databaseusername=ambari
    databasepassword=ambari
) {

  $cmd = $default_install ? {
    true  => 'ambari-server setup -s',
    false => 'NOT_IMPLEMENTED'
  }

  if $cmd == 'NOT_IMPLEMENTED' {
    fail('Only :default_install => true is supported')
  }

  exec { 'run ambari-server setup':
    command => "${cmd} && touch /etc/ambari-server/conf/installed",
    path    => '/bin:/sbin:/usr/bin:/usr/sbin',
    creates => '/etc/ambari-server/conf/installed'
  }

}
