# DNS Server setup
class profile::dns::server {

  include dns::server

  # Forwarder
  dns::server::options { '/etc/bind/named.conf.options':
    forwarders => ['129.241.0.201', ],
  }

  dns::zone { 'wanna.believe':
    soa         => 'manager.star.wars',
    soa_email   => 'admin.star.wars',
    nameservers => ['manager'],
  }

  # Collect all the records from other nodes
  Dns::Record::A <<||>>
}