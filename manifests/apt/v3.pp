#
# [*manage_repo*]
# Manage the apt repo for puppetlabs
#
# [*apt_location*]
# URL for apt repo for puppetlabs
#
# [*apt_repos*]
# Which repositories to include from apt
#
class puppetversion::apt::v3(
  $apt_location = 'http://apt.puppetlabs.com',
  $apt_repos = 'main dependencies',
  $manage_repo = true,
) {
  validate_absolute_path($::agent_rundir)

  $puppet_packages = ['puppet','puppet-common']

  if $manage_repo {
    apt::source { 'puppetlabs':
      location => $apt_location,
      repos    => $apt_repos,
      key      => {
        'id'      => '6F6B15509CF8E59E6E469F327F438280EF8D349F',
        'content' => template('puppetversion/puppetlabs.gpg'),
      },
    }
  }

  $package_require = $manage_repo ? {
    true    => Apt::Source['puppetlabs'],
    default => undef,
  }

  if $::lsbdistrelease == '16.04' {
    $full_version = $puppetversion::version
  } else {
    $full_version = "${puppetversion::version}-1puppetlabs1"
  }

  package { $puppet_packages:
    ensure  => $full_version,
    require => $package_require,
  }

  -> ini_setting { 'update init.d script PIDFILE to use agent_rundir':
    ensure  => present,
    section => '',
    setting => 'PIDFILE',
    value   => "\"${::agent_rundir}/\${NAME}.pid\"",
    path    => '/etc/init.d/puppet',
  }

  if versioncmp($::rubyversion, '2.0.0') >= 0 {
    if ($::operatingsystem == 'Ubuntu') and ($::lsbdistrelease == '12.04') {
      package { ['libaugeas0', 'augeas-lenses' ]:
        ensure  => '1.2.0-0ubuntu1.1~ubuntu12.04.1',
      }
      -> package { 'libaugeas-dev':
        ensure  => '1.2.0-0ubuntu1.1~ubuntu12.04.1',
      }
    } else {
      package { ['libaugeas0', 'augeas-lenses' ]:
        ensure => installed,
      }
      -> package { 'libaugeas-dev':
        ensure  => installed,
      }
    }

    package { ['pkg-config', 'build-essential']:
      ensure => present,
      before => Package['ruby-augeas'],
    }

    package { 'ruby-augeas':
      ensure          => present,
      provider        => 'gem',
      install_options => { '-v' => $puppetversion::ruby_augeas_version },
    }
  }
}
