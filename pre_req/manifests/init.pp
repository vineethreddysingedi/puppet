class pre_req {
      file { "/etc/selinux/config":
          mode   => "0644",
          owner  => 'root',
          group  => 'root',
          source => "puppet:///modules/pre_req/config",
 }

  exec { "vm.swapspaces": command => "/bin/echo 10 > /proc/sys/vm/swappiness" }

   service { 'iptables':
      ensure => stopped,
      enable => false,
 }
  service { 'ip6tables':
     ensure => stopped,
     enable => false,
 }
}



