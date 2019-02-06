class puppetversion::apt::v5(
  $apt_location = 'http://apt.puppetlabs.com',
  $apt_repos = 'main puppet5',
  $manage_repo = true,
) {

  $puppet_packages = ['puppet-agent',]

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
    $full_version = '5.5.10-1'
  } else {
    $full_version = '5.5.10'
  }

  package { $puppet_packages:
    ensure  => $full_version,
    require => $package_require,
  }
}
