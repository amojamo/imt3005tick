
class profile::tickmaster {

    $admin_usr = lookup('influxdb::admin_usr')
    $admin_pwd = lookup('influxdb::admin_pwd')

    package { ['influxdb','telegraf','kapacitor','chronograf']:
    ensure  => latest,
    notify => Service['influxdb'],
  }

  #Wait for InfluxDB to fully start
  exec { 'Wait for InfluxDB':
    command => '/bin/sleep 8',
  }
  exec { 'Create admin user in InfluxDB':
    command => "/usr/bin/influx -execute \"CREATE USER '$influxdb::admin_usr' WITH PASSWORD '$influxdb::admin_pwd' WITH ALL PRIVILEGES\"",
    require => Exec['Wait for InfluxDB'],
  }
  
  #Syntax from https://github.com/puppetlabs/puppetlabs-inifile

  #InfluxDB
  ini_setting { 'influxdb':
    ensure      => present,
    path      => '/etc/influxdb/influxdb.conf',
    section     => 'http',
    setting     => 'auth-enabled',
    value       => 'true',
    indent_char   => " ",
    indent_width  => 2,
  }

  #$defaults_telegraf = { 
  #  'path' => '/etc/telegraf/telegraf.conf',
  #  'indent_char' => " ",
  #  'indent_width' => 2,
  #}
  #$userpw_telegraf = { 
  #  'outputs.influxdb' => {           #section of config file
  #    'username' => '$influxdb::admin_usr', #setting in config file
  #    'password' => '$influxdb::admin_pwd',   #setting in config file
  #  } 
  #}

  #create_ini_settings($userpw_telegraf, $defaults_telegraf)


  service { ['influxdb','telegraf','kapacitor','chronograf']:
    ensure  => running,
    enable  => true,
    require => Package['influxdb'],
  }

}
