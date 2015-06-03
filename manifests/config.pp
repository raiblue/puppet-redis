# = Class: redis::config
#
# This class provides configuration for Redis.
#
class redis::config {

  file {
    $::redis::config_dir:
      ensure => directory,
      owner  => $::redis::config_owner,
      group  => $::redis::config_group,
      mode   => $::redis::config_dir_mode,
      notify => Service[$::redis::service_name];

    $::redis::config_file_orig:
      ensure  => present,
      owner   => $::redis::config_owner,
      group   => $::redis::config_group,
      mode    => $::redis::config_file_mode,
      content => template($::redis::conf_template);

    $::redis::log_dir:
      ensure => directory,
      owner  => $::redis::service_user,
      group  => $::redis::service_group,
      mode   => $::redis::log_dir_mode,
      notify => Service[$::redis::service_name];
  }

  exec {
    "cp -p $::redis::config_file_orig $::redis::config_file":
      path        => '/usr/bin:/bin',
      subscribe   => File[$::redis::config_file_orig],
      notify      => Service[$::redis::service_name],
      refreshonly => true,
  }

  # Adjust /etc/default/redis-server on Debian systems
  case $::osfamily {
    'Debian': {
      file { '/etc/default/redis-server':
        ensure => present,
        group  => $::redis::config_group,
        mode   => $::redis::config_file_mode,
        owner  => $::redis::config_owner,
      }

      if $::redis::ulimit {
        augeas { 'redis ulimit' :
          context => '/files/etc/default/redis-server',
          changes => "set ULIMIT ${::redis::ulimit}",
        }
      }
    }

    default: {
    }
  }
}

