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
define lma_infra_alerting::nagios::service (
  $path,
  $host,
  $ensure = present,
  $process_perf_data = false,
  $passive_check = false,
  $active_check = true,
  $check_command = undef,
  $check_interval = 30,
  $retry_interval = 30,
){
  validate_bool($process_perf_data, $passive_check, $active_check)
  #validate_integer($check_interval, $retry_interval)

  $target = "${path}/service_${name}.cfg"
  $_passive_check = bool2num($passive_check)
  $_active_check = bool2num($active_check)
  $_process_perf_data = bool2num($process_perf_data)

  if $passive_check{
    $max_check_attemmpts = 1
    $check_freshness = 1
    $freshness_threshold = floor($check_interval * 1.5)
  }else{
    $max_check_attemmpts = 3
    $check_freshness = 0
    $freshness_threshold = 0
  }

  if $check_command == undef {
    $_check_command = "return-unknown-${name}"
    $_cmd_target = "${path}/cmd_service_unknown_${name}.cfg"
    nagios_command{ $_check_command:
      ensure => $ensure,
      command_line => "/usr/lib/nagios/plugins/check_dummy 3 'No data recieved since at least ${freshness_threshold} seconds'",
      target => $_cmd_target,
    }

    file { $_cmd_target:
      mode => '0644',
      ensure => $ensure,
      require => Nagios_Command[$_check_command],
    }
  }else{
    $_check_command = $_check_command
  }

  nagios_service{ $name:
    ensure => $ensure,
    target => $target,
    service_description => "nagios_${name}",
    display_name => $name,
    host_name => $host,
    process_perf_data => "${_process_perf_data}",
    active_checks_enabled => "${_active_check}",
    passive_checks_enabled => "${_passive_check}",
    max_check_attempts => $max_check_attemmpts,
    check_command => $_check_command,
    check_freshness => "${check_freshness}",
    freshness_threshold => "${freshness_threshold}",
    check_interval => $check_interval,
    retry_interval => $retry_interval,
    use => 'generic-service',
    require => Nagios_Host[$host],
  }

  file { $target:
    mode => '0644',
    ensure => $ensure,
    require => Nagios_Service[$name],
  }
}

