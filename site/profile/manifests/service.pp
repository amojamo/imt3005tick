class profile::service{
  service { ['influxdb','telegraf','kapacitor','chronograf']:
    ensure  => running,
    enable  => true,
    require => Package['influxdb'],
  }
}
