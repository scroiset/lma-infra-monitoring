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

  # hiera data
  $email_all = 'root@localhost'
  $alias_all = 'Foo'
  $email_critical = 'root@localhost'
  $alias_critical = 'Bar Foo 42'


  # Install and configure nagios server
  class { 'lma_infra_alerting::nagios::base':
    http_user => $user,
    http_password => $password,
  }

  class { 'lma_infra_alerting::nagios::service_status':
    ip => $openstack_management_vip,
    hostname => $nagios_openstack_vhostname,
    services => $all_openstack_services,
    require => Class['lma_infra_alerting::nagios::base'],
  }

  class { 'lma_infra_alerting::nagios::contact':
    email_all_notif => $email_all,
    alias_all_notif => $alias_all,
    email_only_critical_notif => undef,
    alias_only_critical_notif => undef,
    require => Class['lma_infra_alerting::nagios::service_status'],
  }


}
