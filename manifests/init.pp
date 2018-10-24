class influxdb (

String $operatingsystem,
String $oscodename,
String $admin_usr,
String $admin_pwd,
)
Class['profile::base'] -> Class['profile::tickmaster'] -> Class['profile::service']
