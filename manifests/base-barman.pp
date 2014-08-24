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
}->
package { "postgresql-client-9.1": 
  ensure => "installed" 
}->
package { "barman": 
  ensure => "installed" 
}

host { 'postgres':
    ip => '192.168.33.10',
}

file { "/etc/barman.conf":
  replace => "yes",
  source => "/vagrant/manifests/files/barman.conf",
  mode => 644,
}

file { "/var/lib/barman":
  ensure => "directory",
  owner => barman,
  group => barman,
  require => Package['barman']
}->
file { "/var/lib/barman/.ssh":
  ensure => "directory",
  owner => barman,
  group => barman,
}->
file { "/var/lib/barman/.ssh/config":
  source => "/vagrant/manifests/files/ssh_config",
  mode => 600,
  owner => barman,
  group => barman,
}->
file {"/var/lib/barman/.ssh/id_rsa":
  source => "/vagrant/manifests/files/id_rsa",
  mode => 600,
  owner => barman,
  group => barman,
}->
file { "/var/lib/barman/.ssh/id_rsa.pub":
  source => "/vagrant/manifests/files/id_rsa.pub",
  mode => 644,
  owner => barman,
  group => barman,
}->
ssh_authorized_key { "ssh_key":
  ensure => "present",
  key    => "AAAAB3NzaC1yc2EAAAADAQABAAABAQDp2g1O/rmLXxA2kVBhfgpioQGalEwVZmVCp4o0x+/rlCYaYOQCm8zEKUuRlIK50MsbWh/95pH9SgQtZw9s/uLAV26SYfDMVWubjOtd9HJgGj9UWajUziKgzgkXAU7fGv+xcWvyH8L++AxoNuFhk8qWufH0Mw9XWWTIhOWvARxZe2pRslVtRGdxESSVuWaVRE7MTa/SEbK7ko7a+SQvsofjLOiG1po8a5alMHV3w3u4X99k/BpGpf6IoVOGA1pEpMg+5AsqltUYADwLKjFxEpeYK+Ev+z7LzJuNktVhASIoqjusAZ/jaivqCNADVaSNswWhcn9xK5a+nmo1vF6nVpUv",
  type   => "ssh-rsa",
  user   => "barman",
  require => File['/var/lib/barman/.ssh/id_rsa.pub']
}