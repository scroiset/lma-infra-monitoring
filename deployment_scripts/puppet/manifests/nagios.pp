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

# check base-os role
# check node name w/ user param

# create contacts
#  emails from UI

$management_vip = hiera('management_vip')

class { 'lma_infra_alerting':
  user => 'nagiosadmin',
  password => 'foo!',
  contact_email => 'root@localhost',
  openstack_management_vip => $management_vip,
  # additional services services
  openstack_services => ['foo_bar'],
}
