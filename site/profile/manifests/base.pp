class profile::base {
  #the base profile should include component modules that will be on all nodes
  class { 'apt':
    always_apt_update => true,
  }

  apt::key { 'influxdb.key':
    source => 'https://repos.influxdata.com/influxdb.key',
  } ->
  apt::source { 'influxdb':
    architecture => 'amd64',
    location     => 'https://repos.influxdata.com/ubuntu',
    repos        => 'stable',
    release      => $::lsbdistcodename,
  } ->
  package { 'influxdb':
    ensure  => 'latest',
    require => Exec['apt_update'],
  }
}
