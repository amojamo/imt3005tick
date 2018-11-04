# Installs and configures TICK
class profile::telegraf {

    $admin_usr = lookup('influxdb::admin_usr')
    $admin_pwd = lookup('influxdb::admin_pwd')
 
    package { ['influxdb','telegraf','kapacitor','chronograf']:
    ensure => latest,
    notify => Service['influxdb'],
  }
# Telegraf
# Syntax from https://github.com/puppetlabs/puppetlabs-inifile
  $defaults_telegraf = {
    'ensure'          => present,
    'require'        => Package['telegraf'],
    'notify'         => Service['telegraf'],
    'path'           => '/etc/telegraf/telegraf.conf',
    'section_prefix' => '[[',
    'section_suffix' => ']]',
    'indent_char'    => ' ',
    'indent_width'   => 2,
  }
  $userpw_telegraf = {
    'outputs.influxdb'  => {           #section of config file
      'username'        => "\"${admin_usr}\"", #setting in config file
      'password'        => "\"${admin_pwd}\"",   #setting in config file
      'urls'            => "[\"http://manager.star.wars:8086\"]"
    }
  }
  create_ini_settings($userpw_telegraf, $defaults_telegraf)

  service { ['influxdb','telegraf','kapacitor','chronograf']:
    ensure  => running,
    enable  => true,
    require => Package['influxdb'],
    }
  }
