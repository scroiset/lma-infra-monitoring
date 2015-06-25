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
# Configure Nagios server and Nagios CGI
# Add services status monitoring and their contacts
#
class lma_infra_alerting::nagios (
  $openstack_management_vip = $lma_infra_alerting::params::openstack_management_vip,
  $user = $lma_infra_alerting::params::nagios_http_user,
  $password = $lma_infra_alerting::params::nagios_http_password,
  $services = [],
  $contact_email = $lma_infra_alerting::params::nagios_contact_email,
  $contact_alias = $lma_infra_alerting::params::nagios_contact_alias,
  $contact_email_critical = $lma_infra_alerting::params::nagios_contact_critical_email,
  $contact_alias_critical = $lma_infra_alerting::params::nagios_contact_critical_alias,
) inherits lma_infra_alerting::params {

  validate_array($services)

  $nagios_openstack_vhostname = $lma_infra_alerting::params::nagios_openstack_dummy_hostname

  $core_openstack_services = $lma_infra_alerting::params::openstack_core_services
  if count($services) > 0{
    $all_openstack_services = union($core_openstack_services, $services)
  }else{
    $all_openstack_services = $core_openstack_services
  }

  # Install and configure nagios server
  class { 'lma_infra_alerting::nagios::base':
    http_user => $user,
    http_password => $password,
  }

  # Configure services
  class { 'lma_infra_alerting::nagios::service_status':
    ip => $openstack_management_vip,
    hostname => $nagios_openstack_vhostname,
    services => $all_openstack_services,
    require => Class['lma_infra_alerting::nagios::base'],
  }

  # Configure contacts
  class { 'lma_infra_alerting::nagios::contact':
    email_all_notif => $contact_email,
    alias_all_notif => $contact_alias,
    email_only_critical_notif => $contact_email_critical,
    alias_only_critical_notif => $contact_alias_critical,
    require => Class['lma_infra_alerting::nagios::service_status'],
  }
}
