# DNS client setup
class profile::dns::client {

@@dns::record::a { $::hostname:
  zone => 'star.wars',
  data => $::ipaddress,
}

# rumored ugly hack, remove since its in bash script (heat)?

  exec { '/usr/sbin/netplan apply': }

}