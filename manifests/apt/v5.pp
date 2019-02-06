class puppetversion::apt::v5(
  $apt_location = 'http://apt.puppetlabs.com',
  $apt_repos = 'main puppet5',
  $manage_repo = true,
) {
  if $puppetversion::manage_repo {
    apt::source { 'puppet5':
      location => $apt_location,
      repos    => $apt_repos,
      key      => {
        'id'      => '6F6B15509CF8E59E6E469F327F438280EF8D349F',
        'content' => template('puppetversion/puppetlabs.gpg'),
      },
    }
  }

}
