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
class lma_infra_alerting::nagios::server(
  $service_name = $lma_infra_alerting::params::nagios_service_name,
  $service_enable = true,
  $service_ensure = 'running',
  $service_manage = true,
  $main_config = $lma_infra_alerting::params::nagios_main_conf_file,
){
  validate_bool($service_enable)
  validate_bool($service_manage)

  package { $service_name:
    ensure => present,
  }

  # update inline main nagios configuration
  # TODO enable external_command (option + chmod)
  augeas{ $main_config:
    incl => $main_config,
    lens => 'nagioscfg.lns',
    changes => [
        # passive check
        "set accept_passive_service_checks 1",

        # TODO configure in an other lma_infra_alerting::nagios::configure
        "set use_syslog 1",
        "set enable_notifications 1",
        "set enable_flap_detection 1",
        # Don't overide performance data collection, lets operators configure it
        #set process_performance_data 0",

        # TODO pass by param
        "set debug_level 0",

        # TODO check if we need to enable at global level?
        #"set check_service_freshness 1",
        #"set service_freshness_check_interval 60",
        ],
    notify => Service[$service_name],
  }

  if $service_manage {
    service {$service_name:
      ensure => $service_ensure,
      require => Package[$service_name],
      enable => $service_enable,
    }
  }

}
