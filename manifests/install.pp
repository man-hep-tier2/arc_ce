# Class arc_ce::install
# Installs the ARC6 package
class arc_ce::install (
  Enum['epel', 'nordugrid'] $install_from = 'epel',
  String $ensure = 'present',
  Optional[String] $gridftpd_ensure = 'present',
  Optional[String] $infosysldap_ensure = 'present',
) {

  # package names only differ between nordugrid and epel on CentOS 7,
  # on EL8/9 based OS the package names are the same
  $install_from_real = (Integer($facts['os']['release']['major']) < 8) ? {
    true    => $install_from,
    default => 'epel'
  }
  case $install_from_real {
    'epel': {
      $arex_package = 'nordugrid-arc6-arex'
      $gridftpd_package = 'nordugrid-arc6-gridftpd'
      $infosysldap_package = 'nordugrid-arc6-infosys-ldap'
      $lcmaps_plugin_package = 'nordugrid-arc6-plugins-lcas-lcmaps'
    }
    'nordugrid': {
      $arex_package = 'nordugrid-arc-arex'
      $gridftpd_package = 'nordugrid-arc-gridftpd'
      $infosysldap_package = 'nordugrid-arc-infosys-ldap'
      $lcmaps_plugin_package = 'nordugrid-arc-plugins-lcas-lcmaps'
    }
    default: {}
  }

  # the CRB repo needs to be enabled on Rocky 9
  package { 'nordugrid-arc-arex':
    ensure => $ensure,
    name   => $arex_package,
  }

  # define virtual resources for non-essential packages
  # they are realized when the related block in arc.conf is enabled

  if  $gridftpd_ensure !~ Undef {
    @package { 'arc-package-gridftpd':
      ensure => $gridftpd_ensure,
      name   => $gridftpd_package,
    }
  }

  if $infosysldap_ensure !~ Undef {
    @package { 'arc-package-infosys-ldap':
      ensure => $infosysldap_ensure,
      name   => $infosysldap_package,
    }
  }

  include arc_ce::lcmaps::install
  include arc_ce::lcas::install
}
