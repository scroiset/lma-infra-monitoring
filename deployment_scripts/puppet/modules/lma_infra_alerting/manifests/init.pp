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
  $contact_groups_openstack = $lma_infra_alerting::params::nagios_contact_groups_openstack,
  $contact_email = $lma_infra_alerting::params::nagios_contact_email,
) inherits lma_infra_alerting::params {

  include nagios::server_service

  validate_array($contact_groups_openstack)

  $nagios_openstack_vhostname = $lma_infra_alerting::params::nagios_openstack_dummy_hostname

  $core_openstack_services = $lma_infra_alerting::params::openstack_core_services
  if count($openstack_services) > 0{
    $all_openstack_services = union($core_openstack_services, $openstack_services)
  }else{
    $all_openstack_services = $core_openstack_services
  }

  $contact_all_group = $lma_infra_alerting::params::nagios_contact_group_openstack_all
  $email_all = 'foo@foo.bar'
  $alias_all = 'Foo'
  $contacts  = {
    "${contact_all_group}" => {email => $email_all, aliass => $alias_all, service_notification_options => 'w,u,c,r', host_notification_options => 'd,u,r,f,s'},
  #  $contact_critical_group => {email => 'foo@two.one', aliass => 'FOo twooo Name', service_notification_options => 'u,c,r'}
  }
  $contact_critical_group = $lma_infra_alerting::params::nagios_contact_group_openstack_critical

  # Install and configure nagios server
  class { 'lma_infra_alerting::nagios::base':
    http_user => $user,
    http_password => $password,
  }

  class { 'lma_infra_alerting::nagios::service_status':
    ip => $openstack_management_vip,
    hostname => $nagios_openstack_vhostname,
    services => $all_openstack_services,
    contact_groups => $contact_groups_openstack,
    require => Class['lma_infra_alerting::nagios::base'],
  #  notify => Class['nagios::server_service'],
  }
  # This explicit dependancy is important, because
  # require => Class[] DOESN'T work, certainly due to the create_resources() call
  # inside the lma_infra_alerting::nagios::contact
  class { 'lma_infra_alerting::nagios::contact':
    contacts => $contacts,
    require => Class['lma_infra_alerting::nagios::service_status'],
  }
}
