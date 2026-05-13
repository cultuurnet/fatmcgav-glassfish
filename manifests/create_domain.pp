# == Define: glassfish::create_domain
#
# Create a glassfish domain on installation.
#
# === Parameters
#
# [*asadmin_path*] - Path to asadmin binary.
#  Defaults to $glassfish::glassfish_asadmin_path
#
# [*asadmin_user*] - Asadmin username.
#  Defaults to $glassfish::asadmin_user
#
# [*asadmin_passfile*] - Asadmin password file.
#  Defaults to $glassfish::asadmin_passfile
#
# [*create_service*] - Should a service init file be created?
#  Defaults to $glassfish::start_domain
#
# [*domain_template*] - Domain template to use.
#  Defaults to $glassfish::domain_template
#
# [*domain_name*] - Name of domain to create.
#  Defaults to the resource name if not specified
#
# [*domain_user*] - User account under which to run domain.
#  Defaults to $glassfish::user
#
# [*enable_secure_admin*] - Enable secure admin on domain.
#  Defaults to the $glassfish::enable_secure_admin
#
# [*portbase*] - Portbase to use for domain.
#  Defaults to $glassfish::portbase
#
# [*service_name*] - Specify a custom service name.
#  Defaults to `glassfish_${domain_name}`
#
# [*start_domain*] - Should the domain be started upon creation?
#  Defaults to $glassfish::start_domain
#
# === Examples
#
#
# === Authors
#
# Gavin Williams <fatmcgav@gmail.com>
#
# === Copyright
#
# Copyright 2014 Gavin Williams, unless otherwise noted.
#
define glassfish::create_domain (
  Stdlib::Absolutepath $asadmin_path        = $glassfish::glassfish_asadmin_path,
  String $asadmin_user        = $glassfish::asadmin_user,
  Stdlib::Absolutepath $asadmin_passfile    = $glassfish::asadmin_passfile,
  Boolean $create_service      = $glassfish::create_service,
  $domain_name         = $name,
  Optional[Stdlib::Absolutepath] $domain_template     = $glassfish::domain_template,
  $domain_user         = $glassfish::user,
  Boolean $enable_secure_admin = $glassfish::enable_secure_admin,
  $ensure              = present,
  String $portbase            = $glassfish::portbase,
  $service_name        = $glassfish::service_name,
  Boolean $start_domain        = $glassfish::start_domain) {
  # Service name
  if ($service_name == undef) {
    $svc_name = "glassfish_${domain_name}"
  } else {
    $svc_name = $service_name
  }

  # Create the domain
  domain { $domain_name:
    ensure            => $ensure,
    user              => $domain_user,
    asadminuser       => $asadmin_user,
    passwordfile      => $asadmin_passfile,
    portbase          => $portbase,
    startoncreate     => $start_domain,
    enablesecureadmin => $enable_secure_admin,
    template          => $domain_template
  }

  # Create a init.d service if required
  if $create_service {
    glassfish::create_service { $domain_name:
      running      => $start_domain,
      mode         => 'domain',
      domain_name  => $domain_name,
      service_name => $svc_name,
      runuser      => $domain_user,
      require      => Domain[$domain_name]
    }
  }

  # Run Create_domain resources before Create_cluster and Create_node resources
  Glassfish::Create_domain <| |> -> Glassfish::Create_cluster <| |>
  Glassfish::Create_domain <| |> -> Glassfish::Create_node <| |>

}
