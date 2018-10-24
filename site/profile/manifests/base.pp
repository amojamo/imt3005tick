class profile::base {
  #the base profile should include component modules that will be on all nodes

  apt::source { 'influxdb':
    location     => "https://repos.influxdata.com/$influxdb::operatingsystem",
    repos        => 'stable',
    release      => $influxdb::oscodename,
		key 				 => {
	    'id' 			 => '05CE15085FC09D18E99EFB22684A14CF2582E0C5',
			'source'   => 'https://repos.influxdata.com/influxdb.key',
		},
  }
}
