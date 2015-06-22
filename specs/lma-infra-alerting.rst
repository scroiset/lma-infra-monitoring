..
 This work is licensed under a Creative Commons Attribution 3.0 Unported
 License.

 http://creativecommons.org/licenses/by/3.0/legalcode

=====================================================
Fuel plugin for the OpenStack Infrastructure Alarming
=====================================================


https://blueprints.launchpad.net/fuel/+spec/lma-infra-alerting-plugin

The `LMA Infrastructure Alerting` plugin is composed of several services
running on a node (base-os role). It provides alerting functionality for the
OpenStack Infrastruture inside the `LMA toolchain` [1]_ plugins suite.


Problem description
===================

Current implementation of the `LMA toolchain` [1]_ doesn't provide the alerting
functionnality.

This specification aims to address the following use cases:

* OpenStack operator(s) want to be notified when the status of a component
  within the infrastructure changes:

  * OpenStack service status has changed (for example OK -> FAIL)
  * Cluster (RabbitMQ, MySQL, ..)  status has changed (for example OK -> WARN)
  * ..

* OpenStack operators(s) want to be notified when a particular condition is meet
  in regard of system metrics.

  * Load average is too hight on a controller node.
  * Filesystem is nearly full on a node.
  * ..

Proposed changes
================

Implement a Fuel plugin that will install and configure the LMA infrastructure
alerting system for an OpenStack environement.

The initial implementation of this plugin plan to install and configure
Nagios [2]_ to manage alerts and send notifications to operators by email.

There are two types of alerts which are initially supported:

   * Leverage Service status determination computed by the `LMA collector`
     plugins.
   * Provide the ability to configure alarms over metrics by querying the
     time series database provided by the `Influxdb-Grafana` plugin [8]_

In order to integrate this new `LMA infrastructure alerting` plugin into the
`LMA toolchain` its necessary to:

* Plug the `LMA collector` [3]_ to this new alerting system with the native
  Hekad [4]_ NagiosOutputPlugin [5]_ for the glue.
* Plug Nagios to the time serie database InfluxDB [6]_ by developing
  specialized a Nagios plugin [7]_ to allow to define alarm over metrics.

Alternatives
------------

There is no available alternative to notify operators. With the `LMA toolchain`
the only way to determine critical state would be to keep an eye on dashboards
provided by the `Influxdb-Grafana plugin` [8]_.


Alert severities
----------------

The service Statutes computed by the `LMA collector` and the states defined by
Nagios map like this:

+---------------+----------+
| LMA collector | Nagios   |
+===============+==========+
| OKAY          | OK       |
+---------------+----------+
| WARN          | WARNING  |
+---------------+----------+
| FAIL          | CRITICAL |
+---------------+----------+
| UNKNOWN       | UNKNOWN  |
+---------------+----------+

Contacts, Alerting and Escalation
---------------------------------



Limitations
-----------

Adding and removing node(s) to/from the OpenStack cluster won't re-configure
the Nagios server.

This is a limitation of the Fuel Plugin Framework which don't trigger `task`
when those actions are performed. This limitation should be addressed by a
fuel blueprint [9]_ in a future but might be not ready for MOS 7.0.

This limitation is leading the user to adjust manually the Nagios
configuration:

 * to don't receive alert notifications about a deleted node,
 * to add the new node(s) to Nagios configuration.

A possible workaround for the 'adding case' would be to use a SSH command from
the new node(s) deployed to run the approriate Puppet manifest on the Nagios
node. This workaround won't be explored in first glance.

Data model impact
-----------------

None

REST API impact
---------------
None

Upgrade impact
--------------

None

Security impact
---------------

None

Notifications impact
--------------------

None

Other end user impact
---------------------

None

Performance Impact
------------------

None

Other deployer impact
---------------------

New configuration options:

* email(s) of the operator
* SMTP gateway (optiontal)

Developer impact
----------------

None

Infrastructure impact
---------------------

None

Implementation
==============

Assignee(s)
-----------

Primary assignee:
  Swann Croiset <scroiset@mirantis.com> (developer)

Other contributors:
  Guillaume Thouvenin <gthouvenin@mirantis.com> (developer)
  Simon Pasquier <spasquier@mirantis.com> (feature lead, developer)
  Irina Povolotskaya <ipovolotskaya@mirantis.com> (tech writer)

Work Items
----------

* Implement the Puppet manifests for both Ubuntu and CentOS to configure Nagios

  * Commands, Services and Hosts
  * Contacts

* Add support for Nagios output plugin of the LMA collector.

* Implement the Nagios plugin to querying InfluxDB to be able to set alarms over
  metrics.

* Testing.

* Write the documentation.

Dependencies
============

* Fuel 6.1 and higher.

* LMA Collector Fuel plugin.

Testing
=======

* Prepare a test plan.

* Test the plugin by deploying environments with all Fuel deployment modes and
  the LMA toolchain configured.

* Create integration tests with the LMA toolchain

Acceptance criteria
-------------------

The operator must be notified by email when the state of an
OpenStack service change (OK -> DOWN, OK -> WARN, DOWN -> OK).

Documentation Impact
====================


* Write the User Guide for this plugin: deploy and configure the solution.

* Test Plan.

* Test Report.

References
==========

.. [1] The LMA toolchain is currently composed of several Fuel plugins:

        * LMA collector plugin
        * InfluxDB-Grafana plugin
        * Elasticsearch-Kibana plugin

.. [2] http://nagios.org

.. [3] https://github.com/stackforge/fuel-plugin-lma-collector

.. [4] http://hekad.readthedocs.org/

.. [5] http://hekad.readthedocs.org/en/v0.9.2/config/outputs/nagios.html

.. [6] http://www.influxdb.com/

.. [7] https://github.com/shaharke/influx-nagios-plugin

.. [8] https://github.com/stackforge/fuel-plugin-influxdb-grafana

.. [9] https://blueprints.launchpad.net/fuel/+spec/fuel-task-notify-other-nodes
