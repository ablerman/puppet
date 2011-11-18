import "classes/*.pp"

$mysql_password = "1234567890"

Exec { path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" }

class apache2 {
	package {
		'apache2':
			ensure	=> installed
	}

	service {
		'apache2':
			ensure	=> stopped,
			enable	=> false,
			require	=> Package['apache2']
	}
}

package {
	'vim':
		ensure	=> installed
}


class ntp {
	package { "ntp":
		ensure => installed
	}

	service { "ntp":
		ensure => running
	}
}


# Create "/tmp/testfile" if it doesn't exist
class test_class {
	file { "/tmp/testfile":
		ensure	=> present,
		mode	=> 600,
		owner	=> root,
		group	=> root,
	}
}

class www_dir {
	file { "/var/www/home/":
		ensure	=> present,
		mode	=> 600,
		owner	=> www-data,
		group	=> www-data,
	}
}

define mysqldb( $user, $password ) {
	exec { "create-${name}-db":
      		unless => "/usr/bin/mysql -u${user} -p${password} ${name}",
      		command => "/usr/bin/mysql -uroot -p$mysql_password -e \"create database ${name}; grant all on ${name}.* to ${user}@localhost identified by '$password';\"",
      		require => Service["mysql"],
    	}
}


# tell puppet on which client to run the class
node puppet1 {
	include test_class
	include ntp
	include apache2
	include hosts

	include rabbitmq

	include nginx
	nginx::site { "home" :
		domain	=> "test.com",
		root 	=> "/var/www/home",	
	}

	# http://itand.me/using-puppet-to-manage-users-passwords-and-ss
	add_user { sandy:
		email => "sandy@presencelearning.com",
		uid => 5001
	}

	include mysql::server
	
	mysqldb { "testdb":
		user	=> "user",
		password => "user1",
	}
}

