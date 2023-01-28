## 0.4.2 (unreleased)

- Add VMware VMM domains to critical resources to ensure domains are provisioned before being associated to EPGs

## 0.4.1

- Add `snapshot` parameter to config export policies
- Add PTP `global_domain`, `profile`, `announce_interval`, `announce_timeout`, `sync_interval`, `delay_interval` attributes
- Fix dependency between keyrings and CA certificates

## 0.4.0

- Add support for smart licensing
- Fix regex validation of VMware VMM vCenter username to allow for `domain\username` format
- Add health score evaluation policy
- Add support for enhanced LAGs and uplink configuration for VMware VMM domains
- Add fabric SPAN destination group
- Add fabric SPAN source group
- Include default values in module
- BREAKING CHANGE: `depends_on` can no longer be used to express explicit dependencies between NaC modules. The variable `dependencies` and the output `critical_resources_done` can be used instead, to ensure a certain order of operations.
- Add config passphrase

## 0.3.4

- Add support for `auto_generate_pod_profiles`, `auto_generate_fabric_leaf_switch_interface_profiles` and `auto_generate_fabric_spine_switch_interface_profiles` flags
- Fix auto-generated pod profile selector name

## 0.3.3

- Fix fabric-wide setting module version

## 0.3.2

- Add reallocate GIPO fabric-wide setting

## 0.3.1

- Add syslog policy flags and `minimum_severity`
- Add `management_access_policy` option to pod policy groups
- Add `type` attribute to pod profile selector
- Add `name` and `protocol` attributes to syslog destinations

## 0.3.0

- Add L2 MTU module
- Add interface type module
- Fix SNMP policy client entry dependencies
- Add management access policy module
- Pin module dependencies

## 0.2.0

- Use Terraform 1.3 compatible modules

## 0.1.2

- Update readme and add link to Nexus-as-Code project documentation

## 0.1.1

- Improve pod ID lookups

## 0.1.0

- Initial release
