#    Copyright 2015 Mirantis, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
#
# Configure nagios server, add services status monitoring
# Configure  Apache
class lma_infra_alerting (
  $openstack_management_vip = $lma_infra_alerting::params::openstack_management_vip,
  $user = $lma_infra_alerting::params::nagios_http_user,
  $password = $lma_infra_alerting::params::nagios_http_password,
  $openstack_services = [],
  $contact_email = $lma_infra_alerting::params::nagios_contact_email
) inherits lma_infra_alerting::params {

  $nagios_openstack_vhostname = $lma_infra_alerting::params::nagios_openstack_dummy_hostname
  $apache_service_name = $lma_infra_alerting::params::apache_service_name
  $nagios_htpasswd_file = $lma_infra_alerting::params::nagios_htpasswd_file

  $core_openstack_services = $lma_infra_alerting::params::openstack_core_services
  if count($openstack_services) > 0{
    $all_openstack_services = union($core_openstack_services, $openstack_services)
  }else{
    $all_openstack_services = $core_openstack_services
  }

  $nagios_main_conf_file = lma_infra_alerting::params::nagios_main_conf_file
  $nagios_cmd_dummy_host = $lma_infra_alerting::params::nagios_cmd_dummy_host


  class { 'lma_infra_alerting::nagios::server':
  }

  class { 'lma_infra_alerting::nagios::service_status':
    ip => $openstack_management_vip,
    hostname => $nagios_openstack_vhostname,
    services => $all_openstack_services,
    notify => Class['lma_infra_alerting::nagios::server'],
  }

  # TODO create and configure contacts

  # Configure apache
  # TODO http port and vhost
  package {$apache_service_name:
    ensure => present,
  }

  service {$apache_service_name:
    ensure => running,
    require => Package[$apache_service_name],
  }

  htpasswd { $user:
    # TODO randomize salt?
    cryptpasswd => ht_md5($password, 'salt'),
    target      => $nagios_htpasswd_file,
  #  notify => Service[$apache_service_name],
  }

  # TODO
  $apache_user = 'www-data'
  file { $nagios_htpasswd_file:
    owner => $apache_user,
    group => $apache_user,
    mode  => '0640',
    require => Htpasswd[$user],
  }
}
