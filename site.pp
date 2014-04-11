$fuel_settings = parseyaml($astute_settings_yaml)
$fuel_version = parseyaml($fuel_version_yaml)

if is_hash($::fuel_version) and $::fuel_version['VERSION'] and $::fuel_version['VERSION']['production'] {
  $production = $::fuel_version['VERSION']['production']
}
else {
  $production = 'docker-build'
}

if $production == 'prod'{
  $env_path = "/usr"
  $staticdir = "/usr/share/nailgun/static"
} else {
  $env_path = "/opt/nailgun"
  $staticdir = "/opt/nailgun/share/nailgun/static"
}

Exec  {path => '/usr/bin:/bin:/usr/sbin:/sbin'}

if $production == "docker-build" {
  package { "supervisor": }
  package { "python-virtualenv": }
  package { "python-devel": }
  package { "postgresql-libs": }
  package { "postgresql-devel": }
  package { "ruby-devel": }
  package { "gcc": }
  package { "gcc-c++": }
  package { "make": }
  package { "rsyslog": }
  package { "fence-agents": }
  package { "nailgun-redhat-license": }
  package { "python-fuelclient": }
}

Class["nailgun::user"] ->
Class["nailgun::venv"]

$centos_repos =
[
 {
 "id" => "nailgun",
 "name" => "Nailgun",
 "url"  => "\$tree"
 },
]

$repo_root = "/var/www/nailgun"
$pip_repo = "/var/www/nailgun/eggs"
$gem_source = "http://${::fuel_settings['ADMIN_NETWORK']['ipaddress']}:8080/gems/"

$package = "Nailgun"
$version = "0.1.0"
$astute_version = "0.0.2"
$nailgun_group = "nailgun"
$nailgun_user = "nailgun"
$venv = $env_path

$pip_index = "--no-index"
$pip_find_links = "-f file://${pip_repo}"

$database_name = "nailgun"
$database_engine = "postgresql"
$database_host = $::fuel_settings['ADMIN_NETWORK']['ipaddress']
$database_port = "5432"
$database_user = "nailgun"
$database_passwd = "nailgun"

class { "nailgun::user":
  nailgun_group => $nailgun_group,
  nailgun_user => $nailgun_user,
}

class { "nailgun::venv":
  venv => $venv,
  venv_opts => "--system-site-packages",
  package => $package,
  version => $version,
  pip_opts => "${pip_index} ${pip_find_links}",
  production => $production,
  nailgun_user => $nailgun_user,
  nailgun_group => $nailgun_group,

  database_name => $database_name,
  database_engine => $database_engine,
  database_host => $database_host,
  database_port => $database_port,
  database_user => $database_user,
  database_passwd => $database_passwd,

  staticdir => $staticdir,
  templatedir => $$staticdir,
  rabbitmq_astute_user => $rabbitmq_astute_user,
  rabbitmq_astute_password => $rabbitmq_astute_password,

  admin_network         => ipcalc_network_by_address_netmask($::fuel_settings['ADMIN_NETWORK']['ipaddress'], $::fuel_settings['ADMIN_NETWORK']['netmask']),
  admin_network_cidr    => ipcalc_network_cidr_by_netmask($::fuel_settings['ADMIN_NETWORK']['netmask']),
  admin_network_size    => ipcalc_network_count_addresses($::fuel_settings['ADMIN_NETWORK']['ipaddress'], $::fuel_settings['ADMIN_NETWORK']['netmask']),
  admin_network_first   => $::fuel_settings['ADMIN_NETWORK']['static_pool_start'],
  admin_network_last    => $::fuel_settings['ADMIN_NETWORK']['static_pool_end'],
  admin_network_netmask => $::fuel_settings['ADMIN_NETWORK']['netmask'],
  admin_network_ip      => $::fuel_settings['ADMIN_NETWORK']['ipaddress']
}

