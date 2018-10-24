class influxdb::config {
	#Syntax from https://github.com/puppetlabs/puppetlabs-inifile

	#InfluxDB
	ini_setting { 'influxdb':
		ensure 			=> present,
		path 			=> '/etc/influxdb/influxdb.conf',
		section 		=> 'http',
		setting 		=> 'auth-enabled'
		value 			=> 'ture',
		indent_char 	=> " ",
		indent_width 	=> 2,
	}

	$defaults_telegraf = { 
		'path' => '/etc/telegraf/telegraf.conf',
		'indent_char' => " ",
		'indent_width' => 2,
	}
	$userpw_telegraf = { 
		'outputs.influxdb' => { 					#section of config file
			'username' => '$influxdb::admin_usr',	#setting in config file
			'password' => '$influxdb::admin_pwd', 	#setting in config file
		} 
	}

	create_ini_settings($userpw_telegraf, $defaults_telegraf)
}