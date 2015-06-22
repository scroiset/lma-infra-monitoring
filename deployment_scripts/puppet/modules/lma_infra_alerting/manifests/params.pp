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
    $nagios_http_password = 'r00tme'
    $nagios_config_dir = '/etc/nagios3'
    $nagios_main_conf_file = '/etc/nagios3/nagios.cfg'
    $nagios_openstack_dummy_hostname = 'openstack-management-vip'
    $nagios_debug = false
    $nagios_service_name = 'nagios3'
    $nagios_htpasswd_file = '/etc/nagios3/htpasswd.users'
    $nagios_contact_email = 'root@localhost'

    $apache_service_name = 'apache2'

    # default management VIP with fuel-devops
    $openstack_management_vip = '10.109.2.2'

    # following service names must be coherent with lma_collector nagios output
    # plugin names
    $openstack_core_services = [
        'openstack_nova_status',
        'openstack_glance_status',
        'openstack_cinder_status',
        'openstack_neutron_status',
    ]
}
