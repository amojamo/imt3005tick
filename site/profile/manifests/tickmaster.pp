
class profile::tickmaster {

    package { ['influxdb','telegraf','kapacitor','chronograf']:
    ensure  => latest,
    Notify => Service['influxdb'],
  }
#what is this
  exec { 'Wait for InfluxDB':
    command => '/bin/sleep 8',
  }
  exec { 'Create admin user in InfluxDB':
    command => "/usr/bin/influx -execute \"CREATE USER '$admin_usr' WITH PASSWORD '$admin_pwd' WITH ALL PRIVILEGES\"",
    require => Exec['Wait for InfluxDB'],
  }
  
}
