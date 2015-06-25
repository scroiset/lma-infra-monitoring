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

# TODO check base-os role
# TODO check node name w/ user param

$management_vip = hiera('management_vip')
$public_vip = hiera('public_vip')

$plugin = hiera('lma_infrastructure_alerting')
$user = $plugin['nagios_http_user']
$password = $plugin['nagios_http_password']
$email = $plugin['email_all_notification']
$alias = $plugin['alias_all_notification']
$email_critical = $plugin['email_critical_notification']
$alias_critical = $plugin['alias_critical_notification']

if $plugin['node_name'] == hiera('user_node_name') {

  class { 'lma_infra_alerting::nagios':
    user => $user,
    password => $password,
    contact_email => $email,
    contact_alias => $alias,
    contact_email_critical => $email_critical,
    contact_alias_critical => $alias_critical,
    openstack_management_vip => $management_vip,
    # additional services
    services => ['foo_bar'],
  }
}
