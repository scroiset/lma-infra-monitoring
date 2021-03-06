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
class lma_infra_alerting::params {
  $nagios_http_user = 'nagiosadmin'
  $nagios_http_password = ''

  # Following hostname must match with lma_collector::params::nagios_hostname_service_status
  $nagios_openstack_dummy_hostname = 'openstack-management-vip'
  $nagios_contactgroup_all = 'openstack'
  $nagios_contactgroup_critical = 'openstack-critical'
  $nagios_contact_email = 'root@localhost'
  $nagios_contact_alias = 'Admin'
  $nagios_contact_critical_email = 'root@localhost'
  $nagios_contact_critical_alias = 'SuperHero'

  # default VIPs with fuel-devops
  $openstack_management_vip = '10.109.2.2'
  $openstack_public_vip = '10.109.1.2'

  # Following service names must be coherent with lma_collector nagios output
  # plugin names.
  $openstack_core_services = [
      'openstack.keystone.status',
      'openstack.nova.status',
      'openstack.glance.status',
      'openstack.cinder.status',
      'openstack.neutron.status',
      'openstack.heat.status',
  ]
  $openstack_others_services_map = {
      'ceilometer' => 'openstack.ceilometer.status',
  }
}
