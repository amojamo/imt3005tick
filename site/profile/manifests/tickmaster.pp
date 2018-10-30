
class profile::tickmaster {

    $admin_usr = lookup('influxdb::admin_usr')
    $admin_pwd = lookup('influxdb::admin_pwd')
    package { ['influxdb','telegraf','kapacitor','chronograf']:
    ensure  => latest,
    notify => Service['influxdb'],
  } ->

  #Wait for InfluxDB to fully start
  #exec { 'Wait for InfluxDB':
  #  command => '/bin/sleep 10',
  #} ->
  exec { 'Create admin user in InfluxDB':
    command => "/usr/bin/influx -execute \"CREATE USER \"${admin_usr}\" WITH PASSWORD \'${admin_pwd}\' WITH ALL PRIVILEGES\"",
    require => [
      #Exec['Wait for InfluxDB'],
      Package['influxdb'],
    ],
    unless => "/usr/bin/influx -username \"${admin_usr}\" -password \'${admin_pwd}\' -execute \'SHOW USERS\' | tail -n+3 | grep ${admin_usr}",
    
  }
  
  #Syntax from https://github.com/puppetlabs/puppetlabs-inifile

  #InfluxDB
  ini_setting { 'influxdb':
    ensure      => present,
    require => Package['influxdb'],
    path      => '/etc/influxdb/influxdb.conf',
    section     => 'http',
    setting     => 'auth-enabled',
    value       => 'true',
    indent_char   => " ",
    indent_width  => 2,
    notify => Service['influxdb']
  }

  #Hack solution since telegraf conf is wierd 
  #basicall find this line and replace with new user and password
  file_line {'username telegraf':
    require => Package['telegraf'],
    notify => Service['telegraf'],
    line      => "  username = \"${admin_usr}\"",
    path      => '/etc/telegraf/telegraf.conf',
    ensure   => 'present',
    match => '^\  #\ username',
  }
  file_line {'password telegraf':
    require => Package['telegraf'],
    notify => Service['telegraf'],
    line      => "  password = \"${admin_pwd}\"",
    path      => '/etc/telegraf/telegraf.conf',
    ensure   => 'present',
    match => '^\  #\ password',
  }

  ini_setting { '[kapacitor] user':
   ensure      => present,
    require => Package['kapacitor'],
    path => '/etc/kapacitor/kapacitor.conf',
    section_prefix => '[[',
    section_suffic => ']]',
    section => 'influxdb',
    setting => 'username',
    value => "\"${admin_usr}\"",
    indent_char   => " ",
    indent_width  => 2,
    notify => Service['kapacitor'],
  } 
 # file_line {'username kapacitor':
 #   require => Package['kapacitor'],
 #   notify => Service['kapacitor'],
 #   line      => "  username = \"${admin_usr}\"",
 #   path      => '/etc/kapacitor/kapacitor.conf',
 #   ensure   => 'present',
 #   match => 'username\ =\ ""',
 # }
 # file_line {'password kapacitor':
 #   require => Package['kapacitor'],
 #   notify => Service['kapacitor'],
 #   line      => "  password = \"${admin_pwd}\"",
 #   path      => '/etc/kapacitor/kapacitor.conf',
 #   ensure   => 'present',
 #   match => 'password\ =\ ""',
 # }

#  ini_setting { '[outputs.influxdb] user':
#   ensure      => present,
#    require => Package['telegraf'],
#    path => '/etc/telegraf/telegraf.conf',
#    section => "\[outputs.influxdb]",
#    setting => 'username',
#    value => "\"${admin_usr}\"",
#    indent_char   => " ",
#    indent_width  => 2,
#    notify => Service['telegraf'],
#  } 
#   ini_setting { '[outputs.influxdb] password':
#    ensure      => present,
#    require => Package['telegraf'],
#    path => '/etc/telegraf/telegraf.conf',
#    section => '[outputs.influxdb]',
#    setting => 'password',
#    value => "\"${admin_pwd}\"",
#    indent_char   => " ",
#    indent_width  => 2,
#    notify => Service['telegraf'],
  
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
    before => Exec['Create admin user in InfluxDB'],
    }
    }

  

