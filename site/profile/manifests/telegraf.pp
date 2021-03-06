# Installs and configures Telegraf
class profile::telegraf {

    $admin_usr = lookup('influxdb::admin_usr')
    $admin_pwd = lookup('influxdb::admin_pwd')

    package { ['telegraf']:
    ensure => latest,
    notify => Service['telegraf'],
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
    'outputs.influxdb'  => {
      'username'        => "\"${admin_usr}\"",
      'password'        => "\"${admin_pwd}\"",
      'insecure_skip_verify' => true,
      'urls'                 => "[\"https://manager.star.wars:8086\"]",
    }
  }
  create_ini_settings($userpw_telegraf, $defaults_telegraf)

  service { ['telegraf']:
    ensure  => running,
    enable  => true,
    require => Package['telegraf'],
    }
  }
