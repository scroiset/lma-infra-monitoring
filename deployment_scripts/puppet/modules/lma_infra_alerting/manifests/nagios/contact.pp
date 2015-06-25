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
# == Class: lma_infra_alerting::nagios::contact
#
# Configure contacts
#

class lma_infra_alerting::nagios::contact(
  $ensure = present,
  $email_all_notif = undef,
  $alias_all_notif = undef,
  $email_only_critical_notif = undef,
  $alias_only_critical_notif = undef,
){
  validate_string($email_all_notif)
  validate_string($alias_all_notif)

  $contactgroup_all = $lma_infra_alerting::params::nagios_contactgroup_all
  $contactgroup_critical = $lma_infra_alerting::params::nagios_contactgroup_critical

  $contact_groups = [$contactgroup_all, $contactgroup_critical]
  if $email_only_critical_notif != undef {
    # critical and recovery state for services
    $only_critical_service_notification_options = 'c,r'
    # down and recovery state for hosts
    $only_critical_host_notification_options = 'd,r'
  }else{
    # don't send any notification
    $email_only_critical = $nagios::params::default_contact_email
    $alias_only_critical = $nagios::params::default_contact_alias
    $only_critical_service_notification_options = 'n'
    $only_critical_host_notification_options = 'n'
  }

  $name_all = regsubst($email_all_notif, '@', '_AT_')
  $name_critical = regsubst($email_only_critical, '@', '_AT_')

  $contacts = {
    "${contactgroup_all}" => {
        name => "${contactgroup_all}_${name_all}",
        email => $email_all_notif,
        aliass => $alias_all_notif,  # alias is a metaparam
        contact_groups => $contactgroup_all,
        service_notification_options => 'w,u,c,r',
        host_notification_options => 'd,u,r,f,s'},
    "${contactgroup_critical}" => {
        name => "${contactgroup_critical}_${name_critical}",
        email => $email_only_critical,
        aliass => $alias_only_critical,  # alias is a metaparam
        contact_groups => $contactgroup_critical,
        service_notification_options => $only_critical_service_notification_options,
        host_notification_options => $only_critical_host_notification_options},
  }

  $groups = keys($contacts)
  nagios::contactgroup { $groups:
    ensure => $ensure,
    prefix => 'lma_'
  }

  $default = {
    ensure => $ensure,
    prefix => 'lma_'
  }

  create_resources(nagios::contact, $contacts, $default)
}
