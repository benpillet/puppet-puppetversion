class puppetversion::yum::v3() {
  class { '::puppetlabs_yum': }

  package{ 'puppet' :
    ensure  => "${version}-1.el${::operatingsystemmajrelease}",
    require => Class['puppetlabs_yum'],
  }
}
