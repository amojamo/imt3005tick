class profile::base {
  

  $_operatingsystem = downcase($::facts['os']['name'])
  $_oscodename = downcase($::facts['os']['distro']['codename'])

  apt::source { 'influxdb':
    location => "https://repos.influxdata.com/${_operatingsystem}",
    repos    => 'stable',
    release  => $_oscodename,
    key      => {
      'id'     => '05CE15085FC09D18E99EFB22684A14CF2582E0C5',
      'source' => 'https://repos.influxdata.com/influxdb.key',
    },
  }
}
