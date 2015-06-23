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
# Configure nagios server, nagios cgi
# Add services status monitoring and their contacts
#
class lma_infra_alerting (
  $openstack_management_vip = $lma_infra_alerting::params::openstack_management_vip,
  $openstack_public_vip = $lma_infra_alerting::params::openstack_public_vip,
  $user = $lma_infra_alerting::params::nagios_http_user,
  $password = $lma_infra_alerting::params::nagios_http_password,
  $openstack_services = [],
  $contact_email = $lma_infra_alerting::params::nagios_contact_email,
) inherits lma_infra_alerting::params {

  include nagios::server_service

  $nagios_openstack_vhostname = $lma_infra_alerting::params::nagios_openstack_dummy_hostname

  $core_openstack_services = $lma_infra_alerting::params::openstack_core_services
  if count($openstack_services) > 0{
    $all_openstack_services = union($core_openstack_services, $openstack_services)
  }else{
    $all_openstack_services = $core_openstack_services
  }

  # hiera data
  $notify_critical_only_enabled = true
  $email_all = 'foo@foo.bar'
  $alias_all = 'Foo'
  $name_all = regsubst($email_all, '@', '_AT_')
  $email_critical = 'foo@critical.fr'
  $alias_critical = 'Bar Foo 42'
  $name_critical = regsubst($email_critical, '@', '_AT_')

  $contactgroup_all = $lma_infra_alerting::params::nagios_contactgroup_all
  $contactgroup_critical = $lma_infra_alerting::params::nagios_contactgroup_critical
  if $notify_critical_only_enabled {
    $contact_groups = [$contactgroup_all, $contactgroup_critical]
  }else{
    $contact_groups = [$contactgroup_all]
  }

  $contacts = {
    "${contactgroup_all}" => {
        name => "${contactgroup_all}_${name_all}",
        email => $email_all,
        aliass => $alias_all,  # alias is a metaparam
        contact_groups => $contactgroup_all,
        service_notification_options => 'w,u,c,r',
        host_notification_options => 'd,u,r,f,s'},
  }

  if $notify_critical_only_enabled {
    $contacts["${contactgroup_critical}"] = {
        name => "${contactgroup_critical}_${name_critical}",
        email => $email_critical,
        aliass => $alias_critical,  # alias is a metaparam
        contact_groups => $contactgroup_critical,
        service_notification_options => 'u,c,r',
        host_notification_options => 'd,u,r',
    }
  }

  # Install and configure nagios server
  class { 'lma_infra_alerting::nagios::base':
    http_user => $user,
    http_password => $password,
  }

  class { 'lma_infra_alerting::nagios::service_status':
    ip => $openstack_management_vip,
    hostname => $nagios_openstack_vhostname,
    services => $all_openstack_services,
    contact_groups => $contact_groups,
    require => Class['lma_infra_alerting::nagios::base'],
  }

  class { 'lma_infra_alerting::nagios::contact':
    contacts => $contacts,
    require => Class['lma_infra_alerting::nagios::service_status'],
  }
}
