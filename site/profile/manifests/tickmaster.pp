# Installs and configures TICK
class profile::tickmaster {

    $admin_usr = lookup('influxdb::admin_usr')
    $admin_pwd = lookup('influxdb::admin_pwd')

    package { ['influxdb','telegraf','kapacitor','chronograf']:
    ensure => latest,
    notify => Service['influxdb'],
  }

  -> exec { 'Create self signed certificate and private key':
    command => "/usr/bin/openssl req -x509 -nodes -newkey rsa:2048 -keyout /etc/ssl/influxdb-selfsigned.key -out /etc/ssl/influxdb-selfsigned.crt -subj \"/C=NO/ST=Oppland/L=Gjovik/O=NTNU/CN=Student\" -days 365", # lint:ignore:140chars
    require => [
      Package['influxdb'],
    ],
    unless  => '/bin/ls /etc/ssl/ | /bin/grep influx',  # lint:ignore:140chars
  }

  -> file { '/etc/ssl/influxdb-selfsigned.crt':
    ensure => file,
    path   => '/etc/ssl/influxdb-selfsigned.crt',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    before => Exec['Create admin user in InfluxDB'],
  }

  -> exec { 'Create admin user in InfluxDB':
    command => "/usr/bin/influx -ssl -unsafeSsl -execute \"CREATE USER \"${admin_usr}\" WITH PASSWORD \'${admin_pwd}\' WITH ALL PRIVILEGES\"", # lint:ignore:140chars
    require => [
      Package['influxdb'],
    ],
    unless  => "/usr/bin/influx -ssl -unsafeSsl -username \"${admin_usr}\" -password \'${admin_pwd}\' -execute \'SHOW USERS\' | tail -n+3 | grep ${admin_usr}",  # lint:ignore:140chars
  }

# InfluxDB
  $defaults_influxdb = {
    'ensure'          => present,
    'require'         => Package['influxdb'],
    'notify'          => Service['influxdb'],
    'path'            => '/etc/influxdb/influxdb.conf',
    'indent_char'     => ' ',
    'indent_width'    => 2,
  }

  $https_influxdb = {
    'http'    => { # Section in config file
      'https-enabled'      => true, # Setting in the given section
      'https-certificate'  => "\"/etc/ssl/influxdb-selfsigned.crt\"",
      'https-private-key'  => "\"/etc/ssl/influxdb-selfsigned.key\"",
      'auth-enabled'       => true,
    }
  }
  create_ini_settings($https_influxdb, $defaults_influxdb)

# Kapacitor

  $defaults_kapacitor = {
    'ensure'          => present,
    'require'         => Package['kapacitor'],
    'notify'          => Service['kapacitor'],
    'path'            => '/etc/kapacitor/kapacitor.conf',
    'section_prefix'  => '[[',
    'section_suffix'  => ']]',
    'indent_char'     => ' ',
    'indent_width'    => 2,
  }
  $userpw_kapacitor = {
    'influxdb'    => {
      'username'  => "\"${admin_usr}\"",
      'password'  => "\"${admin_pwd}\"",
    }
  }
  create_ini_settings($userpw_kapacitor, $defaults_kapacitor)

# Remove unintentional user login from previous create_init_settings
  $defaults_kapacitorsmtp = {
    'ensure'          => present,
    'require'         => Package['kapacitor'],
    'notify'          => Service['kapacitor'],
    'path'            => '/etc/kapacitor/kapacitor.conf',
    'indent_char'     => ' ',
    'indent_width'    => 2,
  }
  $userpw_kapacitorsmtp = {
    'smtp'    => {
      'username'  => "\"\"",
      'password'  => "\"\"",
    }
  }
  create_ini_settings($userpw_kapacitorsmtp, $defaults_kapacitorsmtp)

# Telegraf
# Syntax from https://github.com/puppetlabs/puppetlabs-inifile
  $defaults_telegraf = {
    'ensure'         => present,
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
      'urls'            => "[\"http://manager.star.wars:8086\"]",
      'insecure_skip_verify' => true,
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