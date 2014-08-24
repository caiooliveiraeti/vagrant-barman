# Install PostgreSQL 9.3 server from the PGDG repository
class {'postgresql::globals':
  version => '9.3',
  manage_package_repo => true,
  encoding => 'LATIN1',
  locale  => 'C',
}->
class { 'postgresql::server':
  ensure => 'present',
  ip_mask_deny_postgres_user => '0.0.0.0/32',
  ip_mask_allow_all_users    => '0.0.0.0/0',
  listen_addresses => '*',
  manage_firewall => true,
  ipv4acls => ['host all all 0.0.0.0/0 md5'],
  postgres_password => 'postgres',
}

postgresql::server::pg_hba_rule { 'allow barman network to access database':
  description => "Open up postgresql for access from 192.168.33.12/32",
  type => 'host',
  database => 'all',
  user => 'all',
  order => '005',
  address => '192.168.33.12/32',
  auth_method => 'trust',
}

postgresql::server::config_entry {
  'wal_level'       : value => 'hot_standby';
  'archive_mode'    : value => 'on';
  'archive_command' : value => 'rsync -a %p barman@barman:/var/lib/barman/producao/incoming/%f';
}

postgresql::server::db { 'dados':
  user     => 'dados',
  password => postgresql_password('dados', 'dados'),
}

host { 'barman':
    ip => '192.168.33.12',
}

file { "/var/lib/postgresql":
  ensure => "directory",
  owner => barman,
  group => barman,
}

file { "/var/lib/postgresql/.ssh":
  ensure => "directory",
  owner => postgres,
  group => postgres,
}

file { "/var/lib/postgresql/.ssh/config":
  source => "/vagrant/manifests/files/ssh_config",
  mode => 600,
  owner => postgres,
  group => postgres,
}

file {"/var/lib/postgresql/.ssh/id_rsa":
  source => "/vagrant/manifests/files/id_rsa",
  mode => 600,
  owner => postgres,
  group => postgres,
}

file { "/var/lib/postgresql/.ssh/id_rsa.pub":
  source => "/vagrant/manifests/files/id_rsa.pub",
  mode => 644,
  owner => postgres,
  group => postgres,
}

ssh_authorized_key { "ssh_key":
  ensure => "present",
  key    => "AAAAB3NzaC1yc2EAAAADAQABAAABAQDp2g1O/rmLXxA2kVBhfgpioQGalEwVZmVCp4o0x+/rlCYaYOQCm8zEKUuRlIK50MsbWh/95pH9SgQtZw9s/uLAV26SYfDMVWubjOtd9HJgGj9UWajUziKgzgkXAU7fGv+xcWvyH8L++AxoNuFhk8qWufH0Mw9XWWTIhOWvARxZe2pRslVtRGdxESSVuWaVRE7MTa/SEbK7ko7a+SQvsofjLOiG1po8a5alMHV3w3u4X99k/BpGpf6IoVOGA1pEpMg+5AsqltUYADwLKjFxEpeYK+Ev+z7LzJuNktVhASIoqjusAZ/jaivqCNADVaSNswWhcn9xK5a+nmo1vF6nVpUv",
  type   => "ssh-rsa",
  user   => "postgres",
  require => File['/var/lib/postgresql/.ssh/id_rsa.pub']
}
