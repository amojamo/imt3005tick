
class profile::tickmaster {

    $admin_usr = lookup('influxdb::admin_usr')
    $admin_pwd = lookup('influxdb::admin_pwd')

    package { ['influxdb','telegraf','kapacitor','chronograf']:
    ensure => latest,
    notify => Service['influxdb'],
  } ->

  exec { 'Create admin user in InfluxDB':
    command => "/usr/bin/influx -execute \"CREATE USER \"${admin_usr}\" WITH PASSWORD \'${admin_pwd}\' WITH ALL PRIVILEGES\"",
    require => [
      Package['influxdb'],
    ],
    unless => "/usr/bin/influx -username \"${admin_usr}\" -password \'${admin_pwd}\' -execute \'SHOW USERS\' | tail -n+3 | grep ${admin_usr}",
    
  }

# InfluxDB
  ini_setting { 'influxdb':
    ensure        => present,
    require       => Package['influxdb'],
    path          => '/etc/influxdb/influxdb.conf',
    section       => 'http',
    setting       => 'auth-enabled',
    value         => 'true',
    indent_char   => " ",
    indent_width  => 2,
    notify        => Service['influxdb'],
  }

# Kapacitor

  $defaults_kapacitor = {
    #'ensure'          => 'present',
    'require'         => Package['kapacitor'],
    'notify'          => Service['kapacitor'],
    'path'            => '/etc/kapacitor/kapacitor.conf',
    'section_prefix'  => '[[',
    'section_suffix'  => ']]',
    'indent_char'     => " ",
    'indent_width'    => 2,
  }
  $userpw_kapacitor = {
    'influxdb'    => {
      'username'  => "\"${admin_usr}\"",
      'password'  => "\"${admin_pwd}\"",
    }
  }
  create_ini_settings($userpw_kapacitor, $defaults_kapacitor)

  $defaults_kapacitorSMTP = {
    #'ensure'          => 'present',
    'require'         => Package['kapacitor'],
    'notify'          => Service['kapacitor'],
    'path'            => '/etc/kapacitor/kapacitor.conf',
    #'section_prefix'  => '[[',
    #'section_suffix'  => ']]',
    'indent_char'     => " ",
    'indent_width'    => 2,
  }
  $userpw_kapacitorSMTP = {
    'smtp'    => {
      'username'  => "\"\"",
      'password'  => "\"\"",
    }
  }
  create_ini_settings($userpw_kapacitorSMTP, $defaults_kapacitorSMTP)

  #ini_setting { '[kapacitor] user':
  #  ensure          => present,
  #  require         => Package['kapacitor'],
  #  path            => '/etc/kapacitor/kapacitor.conf',
  #  section_prefix  => '[[',
  #  section_suffix  => ']]',
  #  section         => 'influxdb',
  # setting         => 'username',
  #  value           => "\"${admin_usr}\"",
  #  indent_char     => " ",
  #  indent_width    => 2,
  #  notify          => Service['kapacitor'],
  #} 
 
# Telegraf
 #Syntax from https://github.com/puppetlabs/puppetlabs-inifile
  $defaults_telegraf = { 
    'require'        => Package['telegraf'],
    'notify'         => Service['telegraf'],
    'path'           => '/etc/telegraf/telegraf.conf',
    'section_prefix' => '[[',
    'section_suffix' => ']]',
    'indent_char'    => " ",
    'indent_width'   => 2,
  }
  $userpw_telegraf = { 
    'outputs.influxdb'  => {           #section of config file
      'username'        => "\"${admin_usr}\"", #setting in config file
      'password'        => "\"${admin_pwd}\"",   #setting in config file
    } 
  }
  create_ini_settings($userpw_telegraf, $defaults_telegraf)


  service { ['influxdb','telegraf','kapacitor','chronograf']:
    ensure  => running,
    enable  => true,
    require => Package['influxdb'],
    before  => Exec['Create admin user in InfluxDB'],
    }
  }

  

