class pre_req {
      file { "/etc/selinux/config":
          mode   => "0644",
          owner  => 'root',
          group  => 'root',
          source => "puppet:///modules/pre_req/config",
 }

  exec { "vm.swapspaces": command => "/bin/echo 10 > /proc/sys/vm/swappiness" }
 }




