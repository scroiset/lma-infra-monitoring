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
# Configure a Nagios host object targeting the management VIP
# Configure related services corresponding to OpenStack services status.
#
class lma_infra_alerting::nagios::service_status (
  $ip = undef,
  $hostname = undef,
  $services = [],
  $contact_groups = $lma_infra_alerting::params::contact_groups_openstack,
){

  validate_array($services, $contact_groups)
  validate_string($ip, $hostname)

  include nagios::server_service

  $nagios_config_dir = $nagios::params::config_dir

  $_host_filename = "${nagios_config_dir}/host_${hostname}.cfg"
  nagios_host { $hostname:
    target => $_host_filename,
    #mode => '0644',
    ensure => present,
    host_name => $hostname,
    address =>  $ip,
    contact_groups => join($contact_groups, ','),
    passive_checks_enabled => 1,
    register => 1,
    use => 'generic-host',
    notify => Class['nagios::server_service'],
  }
  # 'mode' option doesn't exist for nagios_service resource
  # with puppet 3.4
  file { $_host_filename:
    mode => '0644',
    require => Nagios_Host[$hostname],
    notify => Class['nagios::server_service'],
  }

  nagios::service { $services:
    path => "${nagios_config_dir}",
    hostname => $hostname,
    passive_check => true,
    contact_groups => $contact_groups,
  }
}
