locals {
  defaults           = lookup(var.model, "defaults", {})
  modules            = lookup(var.model, "modules", {})
  apic               = lookup(var.model, "apic", {})
  fabric_policies    = lookup(local.apic, "fabric_policies", {})
  pod_policies       = lookup(local.apic, "pod_policies", {})
  node_policies      = lookup(local.apic, "node_policies", {})
  interface_policies = lookup(local.apic, "interface_policies", {})

  interface_types = flatten([
    for node in lookup(local.interface_policies, "nodes", []) : [
      for interface in lookup(node, "interfaces", []) : {
        key     = "${node.id}/${lookup(interface, "module", local.defaults.apic.interface_policies.nodes.interfaces.module)}/${interface.port}"
        pod_id  = try([for n in lookup(local.node_policies, "nodes", []) : lookup(n, "pod", local.defaults.apic.node_policies.nodes.pod) if n.id == node.id][0], local.defaults.apic.node_policies.nodes.pod)
        node_id = node.id
        module  = lookup(interface, "module", local.defaults.apic.interface_policies.nodes.interfaces.module)
        port    = interface.port
        type    = interface.type
      } if lookup(interface, "type", null) != null
    ]
  ])
}

module "aci_apic_connectivity_preference" {
  source  = "netascode/apic-connectivity-preference/aci"
  version = "0.1.0"

  count                = lookup(local.modules, "aci_apic_connectivity_preference", true) == false ? 0 : 1
  interface_preference = lookup(local.fabric_policies, "apic_conn_pref", local.defaults.apic.fabric_policies.apic_conn_pref)
}

module "aci_banner" {
  source  = "netascode/banner/aci"
  version = "0.1.1"

  count                   = lookup(local.modules, "aci_banner", true) == false ? 0 : 1
  apic_gui_banner_message = lookup(lookup(local.fabric_policies, "banners", {}), "apic_gui_banner_message", "")
  apic_gui_banner_url     = lookup(lookup(local.fabric_policies, "banners", {}), "apic_gui_banner_url", "")
  apic_gui_alias          = lookup(lookup(local.fabric_policies, "banners", {}), "apic_gui_alias", "")
  apic_cli_banner         = lookup(lookup(local.fabric_policies, "banners", {}), "apic_cli_banner", "")
  switch_cli_banner       = lookup(lookup(local.fabric_policies, "banners", {}), "switch_cli_banner", "")
}

module "aci_endpoint_loop_protection" {
  source  = "netascode/endpoint-loop-protection/aci"
  version = "0.1.0"

  count                = lookup(local.modules, "aci_endpoint_loop_protection", true) == false ? 0 : 1
  action               = lookup(lookup(local.fabric_policies, "ep_loop_protection", {}), "action", local.defaults.apic.fabric_policies.ep_loop_protection.action)
  admin_state          = lookup(lookup(local.fabric_policies, "ep_loop_protection", {}), "admin_state", local.defaults.apic.fabric_policies.ep_loop_protection.admin_state)
  detection_interval   = lookup(lookup(local.fabric_policies, "ep_loop_protection", {}), "detection_interval", local.defaults.apic.fabric_policies.ep_loop_protection.detection_interval)
  detection_multiplier = lookup(lookup(local.fabric_policies, "ep_loop_protection", {}), "detection_multiplier", local.defaults.apic.fabric_policies.ep_loop_protection.detection_multiplier)
}

module "aci_rogue_endpoint_control" {
  source  = "netascode/rogue-endpoint-control/aci"
  version = "0.1.0"

  count                = lookup(local.modules, "aci_rogue_endpoint_control", true) == false ? 0 : 1
  admin_state          = lookup(lookup(local.fabric_policies, "rogue_ep_control", {}), "admin_state", local.defaults.apic.fabric_policies.rogue_ep_control.admin_state)
  hold_interval        = lookup(lookup(local.fabric_policies, "rogue_ep_control", {}), "hold_interval", local.defaults.apic.fabric_policies.rogue_ep_control.hold_interval)
  detection_interval   = lookup(lookup(local.fabric_policies, "rogue_ep_control", {}), "detection_interval", local.defaults.apic.fabric_policies.rogue_ep_control.detection_interval)
  detection_multiplier = lookup(lookup(local.fabric_policies, "rogue_ep_control", {}), "detection_multiplier", local.defaults.apic.fabric_policies.rogue_ep_control.detection_multiplier)
}

module "aci_fabric_wide_settings" {
  source  = "netascode/fabric-wide-settings/aci"
  version = "0.1.1"

  count                         = lookup(local.modules, "aci_fabric_wide_settings", true) == false ? 0 : 1
  domain_validation             = lookup(lookup(local.fabric_policies, "global_settings", {}), "domain_validation", local.defaults.apic.fabric_policies.global_settings.domain_validation)
  enforce_subnet_check          = lookup(lookup(local.fabric_policies, "global_settings", {}), "enforce_subnet_check", local.defaults.apic.fabric_policies.global_settings.enforce_subnet_check)
  opflex_authentication         = lookup(lookup(local.fabric_policies, "global_settings", {}), "opflex_authentication", local.defaults.apic.fabric_policies.global_settings.opflex_authentication)
  disable_remote_endpoint_learn = lookup(lookup(local.fabric_policies, "global_settings", {}), "disable_remote_endpoint_learn", local.defaults.apic.fabric_policies.global_settings.disable_remote_endpoint_learn)
  overlapping_vlan_validation   = lookup(lookup(local.fabric_policies, "global_settings", {}), "overlapping_vlan_validation", local.defaults.apic.fabric_policies.global_settings.overlapping_vlan_validation)
  remote_leaf_direct            = lookup(lookup(local.fabric_policies, "global_settings", {}), "remote_leaf_direct", local.defaults.apic.fabric_policies.global_settings.remote_leaf_direct)
  reallocate_gipo               = lookup(lookup(local.fabric_policies, "global_settings", {}), "reallocate_gipo", local.defaults.apic.fabric_policies.global_settings.reallocate_gipo)
}

module "aci_port_tracking" {
  source  = "netascode/port-tracking/aci"
  version = "0.1.0"

  count       = lookup(local.modules, "aci_port_tracking", true) == false ? 0 : 1
  admin_state = lookup(lookup(local.fabric_policies, "port_tracking", {}), "admin_state", local.defaults.apic.fabric_policies.port_tracking.admin_state)
  delay       = lookup(lookup(local.fabric_policies, "port_tracking", {}), "delay", local.defaults.apic.fabric_policies.port_tracking.delay)
  min_links   = lookup(lookup(local.fabric_policies, "port_tracking", {}), "min_links", local.defaults.apic.fabric_policies.port_tracking.min_links)
}

module "aci_ptp" {
  source  = "netascode/ptp/aci"
  version = "0.1.0"

  count       = lookup(local.modules, "aci_ptp", true) == false ? 0 : 1
  admin_state = lookup(local.fabric_policies, "ptp_admin_state", local.defaults.apic.fabric_policies.ptp_admin_state)
}

module "aci_ip_aging" {
  source  = "netascode/ip-aging/aci"
  version = "0.1.0"

  count       = lookup(local.modules, "aci_ip_aging", true) == false ? 0 : 1
  admin_state = lookup(local.fabric_policies, "ip_aging", local.defaults.apic.fabric_policies.ip_aging)
}

module "aci_system_global_gipo" {
  source  = "netascode/system-global-gipo/aci"
  version = "0.1.0"

  count          = lookup(local.modules, "aci_system_global_gipo", true) == false ? 0 : 1
  use_infra_gipo = lookup(local.fabric_policies, "use_infra_gipo", local.defaults.apic.fabric_policies.use_infra_gipo)
}

module "aci_coop_policy" {
  source  = "netascode/coop-policy/aci"
  version = "0.1.0"

  count             = lookup(local.modules, "aci_coop_policy", true) == false ? 0 : 1
  coop_group_policy = lookup(local.fabric_policies, "coop_group_policy", local.defaults.apic.fabric_policies.coop_group_policy)
}

module "aci_fabric_isis_policy" {
  source  = "netascode/fabric-isis-policy/aci"
  version = "0.1.0"

  count               = lookup(local.modules, "aci_fabric_isis_policy", true) == false ? 0 : 1
  redistribute_metric = lookup(local.fabric_policies, "fabric_isis_redistribute_metric", local.defaults.apic.fabric_policies.fabric_isis_redistribute_metric)
}

module "aci_fabric_isis_bfd" {
  source  = "netascode/fabric-isis-bfd/aci"
  version = "0.1.0"

  count       = lookup(local.modules, "aci_fabric_isis_bfd", true) == false ? 0 : 1
  admin_state = lookup(local.fabric_policies, "fabric_isis_bfd", local.defaults.apic.fabric_policies.fabric_isis_bfd)
}

module "aci_fabric_l2_mtu" {
  source  = "netascode/fabric-l2-mtu/aci"
  version = "0.1.0"

  count       = lookup(local.modules, "aci_fabric_l2_mtu", true) == false ? 0 : 1
  l2_port_mtu = lookup(local.fabric_policies, "l2_port_mtu", local.defaults.apic.fabric_policies.l2_port_mtu)
}

module "aci_bgp_policy" {
  source  = "netascode/bgp-policy/aci"
  version = "0.2.0"

  count         = lookup(local.fabric_policies, "fabric_bgp_as", null) != null && lookup(local.modules, "aci_bgp_policy", true) ? 1 : 0
  fabric_bgp_as = lookup(local.fabric_policies, "fabric_bgp_as", null)
  fabric_bgp_rr = [for rr in lookup(local.fabric_policies, "fabric_bgp_rr", []) : {
    node_id = rr
    pod_id  = try([for node in lookup(local.node_policies, "nodes", []) : lookup(node, "pod", local.defaults.apic.fabric_policies.fabric_bgp_rr.pod_id) if node.id == rr][0], local.defaults.apic.node_policies.nodes.pod)
  }]
  fabric_bgp_external_rr = [for rr in lookup(local.fabric_policies, "fabric_bgp_ext_rr", []) : {
    node_id = rr
    pod_id  = try([for node in lookup(local.node_policies, "nodes", []) : lookup(node, "pod", local.defaults.apic.fabric_policies.fabric_bgp_ext_rr.pod_id) if node.id == rr][0], local.defaults.apic.node_policies.nodes.pod)
  }]
}

module "aci_date_time_format" {
  source  = "netascode/date-time-format/aci"
  version = "0.1.0"

  count          = lookup(local.modules, "aci_data_time_format", true) == false ? 0 : 1
  display_format = lookup(lookup(local.fabric_policies, "date_time_format", {}), "display_format", local.defaults.apic.fabric_policies.date_time_format.display_format)
  timezone       = lookup(lookup(local.fabric_policies, "date_time_format", {}), "timezone", local.defaults.apic.fabric_policies.date_time_format.timezone)
  show_offset    = lookup(lookup(local.fabric_policies, "date_time_format", {}), "show_offset", local.defaults.apic.fabric_policies.date_time_format.show_offset)
}

module "aci_dns_policy" {
  source  = "netascode/dns-policy/aci"
  version = "0.2.0"

  for_each      = { for policy in lookup(local.fabric_policies, "dns_policies", []) : policy.name => policy if lookup(local.modules, "aci_dns_policy", true) }
  name          = "${each.value.name}${local.defaults.apic.fabric_policies.dns_policies.name_suffix}"
  mgmt_epg_type = lookup(each.value, "mgmt_epg", local.defaults.apic.fabric_policies.dns_policies.mgmt_epg)
  mgmt_epg_name = lookup(each.value, "mgmt_epg", local.defaults.apic.fabric_policies.dns_policies.mgmt_epg) == "oob" ? lookup(local.node_policies, "oob_endpoint_group", local.defaults.apic.node_policies.oob_endpoint_group) : lookup(local.node_policies, "inb_endpoint_group", local.defaults.apic.node_policies.inb_endpoint_group)
  providers_ = [for prov in lookup(each.value, "providers", []) : {
    ip        = prov.ip
    preferred = lookup(prov, "preferred", local.defaults.apic.fabric_policies.dns_policies.providers.preferred)
  }]
  domains = [for dom in lookup(each.value, "domains", []) : {
    name    = dom.name
    default = lookup(dom, "default", local.defaults.apic.fabric_policies.dns_policies.domains.default)
  }]
}

module "aci_error_disabled_recovery" {
  source  = "netascode/error-disabled-recovery/aci"
  version = "0.1.0"

  count      = lookup(local.modules, "aci_error_disabled_recovery", true) == false ? 0 : 1
  interval   = lookup(lookup(local.fabric_policies, "err_disabled_recovery", {}), "interval", local.defaults.apic.fabric_policies.err_disabled_recovery.interval)
  mcp_loop   = lookup(lookup(local.fabric_policies, "err_disabled_recovery", {}), "mcp_loop", local.defaults.apic.fabric_policies.err_disabled_recovery.mcp_loop)
  ep_move    = lookup(lookup(local.fabric_policies, "err_disabled_recovery", {}), "ep_move", local.defaults.apic.fabric_policies.err_disabled_recovery.ep_move)
  bpdu_guard = lookup(lookup(local.fabric_policies, "err_disabled_recovery", {}), "bpdu_guard", local.defaults.apic.fabric_policies.err_disabled_recovery.bpdu_guard)
}

module "aci_date_time_policy" {
  source  = "netascode/date-time-policy/aci"
  version = "0.2.0"

  for_each                       = { for policy in lookup(lookup(local.fabric_policies, "pod_policies", {}), "date_time_policies", []) : policy.name => policy if lookup(local.modules, "aci_date_time_policy", true) }
  name                           = "${each.value.name}${local.defaults.apic.fabric_policies.pod_policies.date_time_policies.name_suffix}"
  apic_ntp_server_master_stratum = lookup(each.value, "apic_ntp_server_master_stratum", local.defaults.apic.fabric_policies.pod_policies.date_time_policies.apic_ntp_server_master_stratum)
  ntp_admin_state                = lookup(each.value, "ntp_admin_state", local.defaults.apic.fabric_policies.pod_policies.date_time_policies.ntp_admin_state)
  ntp_auth_state                 = lookup(each.value, "ntp_auth_state", local.defaults.apic.fabric_policies.pod_policies.date_time_policies.ntp_auth_state)
  apic_ntp_server_master_mode    = lookup(each.value, "apic_ntp_server_master_mode", local.defaults.apic.fabric_policies.pod_policies.date_time_policies.apic_ntp_server_master_mode)
  apic_ntp_server_state          = lookup(each.value, "apic_ntp_server_state", local.defaults.apic.fabric_policies.pod_policies.date_time_policies.apic_ntp_server_state)
  ntp_servers = [for server in lookup(each.value, "ntp_servers", []) : {
    hostname_ip   = server.hostname_ip
    preferred     = lookup(server, "preferred", local.defaults.apic.fabric_policies.pod_policies.date_time_policies.ntp_servers.preferred)
    mgmt_epg_type = lookup(server, "mgmt_epg", local.defaults.apic.fabric_policies.pod_policies.date_time_policies.ntp_servers.mgmt_epg)
    mgmt_epg_name = lookup(server, "mgmt_epg", local.defaults.apic.fabric_policies.pod_policies.date_time_policies.ntp_servers.mgmt_epg) == "oob" ? lookup(local.node_policies, "oob_endpoint_group", local.defaults.apic.node_policies.oob_endpoint_group) : lookup(local.node_policies, "inb_endpoint_group", local.defaults.apic.node_policies.inb_endpoint_group)
    auth_key_id   = lookup(server, "auth_key_id", null)
  }]
  ntp_keys = [for key in lookup(each.value, "ntp_keys", []) : {
    id        = key.id
    key       = key.key
    auth_type = key.auth_type
    trusted   = key.trusted
  }]
}

module "aci_snmp_policy" {
  source  = "netascode/snmp-policy/aci"
  version = "0.2.1"

  for_each    = { for policy in lookup(lookup(local.fabric_policies, "pod_policies", {}), "snmp_policies", []) : policy.name => policy if lookup(local.modules, "aci_snmp_policy", true) }
  name        = "${each.value.name}${local.defaults.apic.fabric_policies.pod_policies.snmp_policies.name_suffix}"
  admin_state = lookup(each.value, "admin_state", local.defaults.apic.fabric_policies.pod_policies.snmp_policies.admin_state)
  location    = lookup(each.value, "location", local.defaults.apic.fabric_policies.pod_policies.snmp_policies.location)
  contact     = lookup(each.value, "contact", local.defaults.apic.fabric_policies.pod_policies.snmp_policies.contact)
  communities = lookup(each.value, "communities", [])
  users = [for user in lookup(each.value, "users", []) : {
    name               = user.name
    privacy_type       = lookup(user, "privacy_type", local.defaults.apic.fabric_policies.pod_policies.snmp_policies.users.privacy_type)
    privacy_key        = lookup(user, "privacy_key", "")
    authorization_type = lookup(user, "authorization_type", local.defaults.apic.fabric_policies.pod_policies.snmp_policies.users.authorization_type)
    authorization_key  = lookup(user, "authorization_key", "")
  }]
  trap_forwarders = [for trap in lookup(each.value, "trap_forwarders", []) : {
    ip   = trap.ip
    port = lookup(trap, "port", local.defaults.apic.fabric_policies.pod_policies.snmp_policies.trap_forwarders.port)
  }]
  clients = [for client in lookup(each.value, "clients", []) : {
    name          = "${client.name}${local.defaults.apic.fabric_policies.pod_policies.snmp_policies.clients.name_suffix}"
    mgmt_epg_type = client.mgmt_epg
    mgmt_epg_name = client.mgmt_epg == "oob" ? lookup(local.node_policies, "oob_endpoint_group", local.defaults.apic.node_policies.oob_endpoint_group) : lookup(local.node_policies, "inb_endpoint_group", local.defaults.apic.node_policies.inb_endpoint_group)
    entries = [for entry in lookup(client, "entries", []) : {
      ip   = entry.ip
      name = entry.name
    }]
  }]
}

module "aci_fabric_pod_policy_group" {
  source  = "netascode/fabric-pod-policy-group/aci"
  version = "0.1.1"

  for_each                 = { for pg in lookup(local.fabric_policies, "pod_policy_groups", []) : pg.name => pg if lookup(local.modules, "aci_fabric_pod_policy_group", true) }
  name                     = "${each.value.name}${local.defaults.apic.fabric_policies.pod_policy_groups.name_suffix}"
  snmp_policy              = lookup(each.value, "snmp_policy", null) != null ? "${each.value.snmp_policy}${local.defaults.apic.fabric_policies.pod_policies.snmp_policies.name_suffix}" : ""
  date_time_policy         = lookup(each.value, "date_time_policy", null) != null ? "${each.value.date_time_policy}${local.defaults.apic.fabric_policies.pod_policies.date_time_policies.name_suffix}" : ""
  management_access_policy = lookup(each.value, "management_access_policy", null) != null ? "${each.value.management_access_policy}${local.defaults.apic.fabric_policies.pod_policies.management_access_policies.name_suffix}" : ""

  depends_on = [
    module.aci_snmp_policy,
    module.aci_date_time_policy,
    module.aci_management_access_policy,
  ]
}

module "aci_fabric_pod_profile_auto" {
  source  = "netascode/fabric-pod-profile/aci"
  version = "0.2.1"

  for_each = { for pod in lookup(local.pod_policies, "pods", []) : pod.id => pod if(lookup(local.apic, "auto_generate_switch_pod_profiles", local.defaults.apic.auto_generate_switch_pod_profiles) || lookup(local.apic, "auto_generate_pod_profiles", local.defaults.apic.auto_generate_pod_profiles)) && lookup(local.modules, "aci_fabric_pod_profile", true) }
  name     = replace(each.value.id, "/^(?P<id>.+)$/", replace(lookup(local.fabric_policies, "pod_profile_name", local.defaults.apic.fabric_policies.pod_profile_name), "\\g<id>", "$id"))
  selectors = [{
    name         = replace(each.value.id, "/^(?P<id>.+)$/", replace(lookup(local.fabric_policies, "pod_profile_pod_selector_name", local.defaults.apic.fabric_policies.pod_profile_pod_selector_name), "\\g<id>", "$id"))
    policy_group = lookup(each.value, "policy", null) != null ? "${each.value.policy}${local.defaults.apic.fabric_policies.pod_policy_groups.name_suffix}" : null
    pod_blocks = [{
      name = each.value.id
      from = each.value.id
      to   = each.value.id
    }]
  }]

  depends_on = [
    module.aci_fabric_pod_policy_group,
  ]
}

module "aci_fabric_pod_profile_manual" {
  source  = "netascode/fabric-pod-profile/aci"
  version = "0.2.1"

  for_each = { for prof in lookup(local.fabric_policies, "pod_profiles", []) : prof.name => prof if lookup(local.modules, "aci_fabric_pod_profile", true) }
  name     = "${each.value.name}${local.defaults.apic.fabric_policies.pod_profiles.name_suffix}"
  selectors = [for selector in lookup(each.value, "selectors", []) : {
    name         = "${selector.name}${local.defaults.apic.fabric_policies.pod_profiles.selectors.name_suffix}"
    policy_group = lookup(selector, "policy", null) != null ? "${selector.policy}${local.defaults.apic.fabric_policies.pod_policy_groups.name_suffix}" : null
    type         = lookup(selector, "type", local.defaults.apic.fabric_policies.pod_profiles.selectors.type)
    pod_blocks = [for block in lookup(selector, "pod_blocks", []) : {
      name = "${block.name}${local.defaults.apic.fabric_policies.pod_profiles.selectors.pod_blocks.name_suffix}"
      from = block.from
      to   = lookup(block, "to", block.from)
    }]
  }]

  depends_on = [
    module.aci_fabric_pod_policy_group,
  ]
}

module "aci_psu_policy" {
  source  = "netascode/psu-policy/aci"
  version = "0.1.0"

  for_each    = { for pol in lookup(lookup(local.fabric_policies, "switch_policies", {}), "psu_policies", []) : pol.name => pol if lookup(local.modules, "aci_psu_policy", true) }
  name        = "${each.value.name}${local.defaults.apic.fabric_policies.switch_policies.psu_policies.name_suffix}"
  admin_state = each.value.admin_state
}

module "aci_node_control_policy" {
  source  = "netascode/node-control-policy/aci"
  version = "0.1.0"

  for_each  = { for pol in lookup(lookup(local.fabric_policies, "switch_policies", {}), "node_control_policies", []) : pol.name => pol if lookup(local.modules, "aci_node_control_policy", true) }
  name      = "${each.value.name}${local.defaults.apic.fabric_policies.switch_policies.node_control_policies.name_suffix}"
  dom       = lookup(each.value, "dom", local.defaults.apic.fabric_policies.switch_policies.node_control_policies.dom)
  telemetry = lookup(each.value, "telemetry", local.defaults.apic.fabric_policies.switch_policies.node_control_policies.telemetry)
}

module "aci_fabric_leaf_switch_policy_group" {
  source  = "netascode/fabric-leaf-switch-policy-group/aci"
  version = "0.1.0"

  for_each            = { for pg in lookup(local.fabric_policies, "leaf_switch_policy_groups", []) : pg.name => pg if lookup(local.modules, "aci_fabric_leaf_switch_policy_group", true) }
  name                = "${each.value.name}${local.defaults.apic.fabric_policies.leaf_switch_policy_groups.name_suffix}"
  psu_policy          = lookup(each.value, "psu_policy", null) != null ? "${each.value.psu_policy}${local.defaults.apic.fabric_policies.switch_policies.psu_policies.name_suffix}" : ""
  node_control_policy = lookup(each.value, "node_control_policy", null) != null ? "${each.value.node_control_policy}${local.defaults.apic.fabric_policies.switch_policies.node_control_policies.name_suffix}" : ""

  depends_on = [
    module.aci_psu_policy,
    module.aci_node_control_policy,
  ]
}

module "aci_fabric_spine_switch_policy_group" {
  source  = "netascode/fabric-spine-switch-policy-group/aci"
  version = "0.1.0"

  for_each            = { for pg in lookup(local.fabric_policies, "spine_switch_policy_groups", []) : pg.name => pg if lookup(local.modules, "aci_fabric_spine_switch_policy_group", true) }
  name                = "${each.value.name}${local.defaults.apic.fabric_policies.spine_switch_policy_groups.name_suffix}"
  psu_policy          = lookup(each.value, "psu_policy", null) != null ? "${each.value.psu_policy}${local.defaults.apic.fabric_policies.switch_policies.psu_policies.name_suffix}" : ""
  node_control_policy = lookup(each.value, "node_control_policy", null) != null ? "${each.value.node_control_policy}${local.defaults.apic.fabric_policies.switch_policies.node_control_policies.name_suffix}" : ""

  depends_on = [
    module.aci_psu_policy,
    module.aci_node_control_policy,
  ]
}

module "aci_fabric_leaf_switch_profile_auto" {
  source  = "netascode/fabric-leaf-switch-profile/aci"
  version = "0.2.0"

  for_each           = { for node in lookup(local.node_policies, "nodes", []) : node.id => node if node.role == "leaf" && (lookup(local.apic, "auto_generate_switch_pod_profiles", local.defaults.apic.auto_generate_switch_pod_profiles) || lookup(local.apic, "auto_generate_fabric_leaf_switch_interface_profiles", local.defaults.apic.auto_generate_fabric_leaf_switch_interface_profiles)) && lookup(local.modules, "aci_fabric_leaf_switch_profile", true) }
  name               = replace("${each.value.id}:${each.value.name}", "/^(?P<id>.+):(?P<name>.+)$/", replace(replace(lookup(local.fabric_policies, "leaf_switch_profile_name", local.defaults.apic.fabric_policies.leaf_switch_profile_name), "\\g<id>", "$id"), "\\g<name>", "$name"))
  interface_profiles = [replace("${each.value.id}:${each.value.name}", "/^(?P<id>.+):(?P<name>.+)$/", replace(replace(lookup(local.fabric_policies, "leaf_interface_profile_name", local.defaults.apic.fabric_policies.leaf_interface_profile_name), "\\g<id>", "$id"), "\\g<name>", "$name"))]
  selectors = [{
    name         = replace("${each.value.id}:${each.value.name}", "/^(?P<id>.+):(?P<name>.+)$/", replace(replace(lookup(local.fabric_policies, "leaf_switch_selector_name", local.defaults.apic.fabric_policies.leaf_switch_selector_name), "\\g<id>", "$id"), "\\g<name>", "$name"))
    policy_group = lookup(each.value, "fabric_policy_group", null) != null ? "${each.value.fabric_policy_group}${local.defaults.apic.fabric_policies.leaf_switch_policy_groups.name_suffix}" : null
    node_blocks = [{
      name = each.value.id
      from = each.value.id
      to   = each.value.id
    }]
  }]

  depends_on = [
    module.aci_fabric_leaf_interface_profile_manual,
    module.aci_fabric_leaf_interface_profile_auto,
    module.aci_fabric_leaf_switch_policy_group,
  ]
}

module "aci_fabric_leaf_switch_profile_manual" {
  source  = "netascode/fabric-leaf-switch-profile/aci"
  version = "0.2.0"

  for_each = { for prof in lookup(local.fabric_policies, "leaf_switch_profiles", []) : prof.name => prof if lookup(local.modules, "aci_fabric_leaf_switch_profile", true) }
  name     = each.value.name
  selectors = [for selector in lookup(each.value, "selectors", []) : {
    name         = "${selector.name}${local.defaults.apic.fabric_policies.leaf_switch_profiles.selectors.name_suffix}"
    policy_group = lookup(selector, "policy", null) != null ? "${selector.policy}${local.defaults.apic.fabric_policies.leaf_switch_policy_groups.name_suffix}" : null
    node_blocks = [for block in lookup(selector, "node_blocks", []) : {
      name = "${block.name}${local.defaults.apic.fabric_policies.leaf_switch_profiles.selectors.node_blocks.name_suffix}"
      from = block.from
      to   = lookup(block, "to", block.from)
    }]
  }]
  interface_profiles = [for profile in lookup(each.value, "interface_profiles", []) : "${profile}${local.defaults.apic.fabric_policies.leaf_interface_profiles.name_suffix}"]

  depends_on = [
    module.aci_fabric_leaf_interface_profile_manual,
    module.aci_fabric_leaf_interface_profile_auto,
    module.aci_fabric_leaf_switch_policy_group,
  ]
}

module "aci_fabric_spine_switch_profile_auto" {
  source  = "netascode/fabric-spine-switch-profile/aci"
  version = "0.2.0"

  for_each           = { for node in lookup(local.node_policies, "nodes", []) : node.id => node if node.role == "spine" && (lookup(local.apic, "auto_generate_switch_pod_profiles", local.defaults.apic.auto_generate_switch_pod_profiles) || lookup(local.apic, "auto_generate_fabric_spine_switch_interface_profiles", local.defaults.apic.auto_generate_fabric_spine_switch_interface_profiles)) && lookup(local.modules, "aci_fabric_spine_switch_profile", true) }
  name               = replace("${each.value.id}:${each.value.name}", "/^(?P<id>.+):(?P<name>.+)$/", replace(replace(lookup(local.fabric_policies, "spine_switch_profile_name", local.defaults.apic.fabric_policies.spine_switch_profile_name), "\\g<id>", "$id"), "\\g<name>", "$name"))
  interface_profiles = [replace("${each.value.id}:${each.value.name}", "/^(?P<id>.+):(?P<name>.+)$/", replace(replace(lookup(local.fabric_policies, "spine_interface_profile_name", local.defaults.apic.fabric_policies.spine_interface_profile_name), "\\g<id>", "$id"), "\\g<name>", "$name"))]
  selectors = [{
    name         = replace("${each.value.id}:${each.value.name}", "/^(?P<id>.+):(?P<name>.+)$/", replace(replace(lookup(local.fabric_policies, "spine_switch_selector_name", local.defaults.apic.fabric_policies.spine_switch_selector_name), "\\g<id>", "$id"), "\\g<name>", "$name"))
    policy_group = lookup(each.value, "fabric_policy_group", null) != null ? "${each.value.fabric_policy_group}${local.defaults.apic.fabric_policies.spine_switch_policy_groups.name_suffix}" : null
    node_blocks = [{
      name = each.value.id
      from = each.value.id
      to   = each.value.id
    }]
  }]

  depends_on = [
    module.aci_fabric_spine_interface_profile_manual,
    module.aci_fabric_spine_interface_profile_auto,
    module.aci_fabric_spine_switch_policy_group,
  ]
}

module "aci_fabric_spine_switch_profile_manual" {
  source  = "netascode/fabric-spine-switch-profile/aci"
  version = "0.2.0"

  for_each = { for prof in lookup(local.fabric_policies, "spine_switch_profiles", []) : prof.name => prof if lookup(local.modules, "aci_fabric_spine_switch_profile", true) }
  name     = each.value.name
  selectors = [for selector in lookup(each.value, "selectors", []) : {
    name         = "${selector.name}${local.defaults.apic.fabric_policies.spine_switch_profiles.selectors.name_suffix}"
    policy_group = lookup(selector, "policy", null) != null ? "${selector.policy}${local.defaults.apic.fabric_policies.spine_switch_policy_groups.name_suffix}" : null
    node_blocks = [for block in lookup(selector, "node_blocks", []) : {
      name = "${block.name}${local.defaults.apic.fabric_policies.spine_switch_profiles.selectors.node_blocks.name_suffix}"
      from = block.from
      to   = lookup(block, "to", block.from)
    }]
  }]
  interface_profiles = [for profile in lookup(each.value, "interface_profiles", []) : "${profile}${local.defaults.apic.fabric_policies.spine_interface_profiles.name_suffix}"]

  depends_on = [
    module.aci_fabric_spine_interface_profile_manual,
    module.aci_fabric_spine_interface_profile_auto,
    module.aci_fabric_spine_switch_policy_group,
  ]
}

module "aci_fabric_leaf_interface_profile_auto" {
  source  = "netascode/fabric-leaf-interface-profile/aci"
  version = "0.1.0"

  for_each = { for node in lookup(local.node_policies, "nodes", []) : node.id => node if node.role == "leaf" && (lookup(local.apic, "auto_generate_switch_pod_profiles", local.defaults.apic.auto_generate_switch_pod_profiles) || lookup(local.apic, "auto_generate_fabric_leaf_switch_interface_profiles", local.defaults.apic.auto_generate_fabric_leaf_switch_interface_profiles)) && lookup(local.modules, "aci_fabric_leaf_interface_profile", true) }
  name     = replace("${each.value.id}:${each.value.name}", "/^(?P<id>.+):(?P<name>.+)$/", replace(replace(lookup(local.fabric_policies, "leaf_interface_profile_name", local.defaults.apic.fabric_policies.leaf_interface_profile_name), "\\g<id>", "$id"), "\\g<name>", "$name"))
}

module "aci_fabric_leaf_interface_profile_manual" {
  source  = "netascode/fabric-leaf-interface-profile/aci"
  version = "0.1.0"

  for_each = { for prof in lookup(local.fabric_policies, "leaf_interface_profiles", []) : prof.name => prof if lookup(local.modules, "aci_fabric_leaf_interface_profile", true) }
  name     = "${each.value.name}${local.defaults.apic.fabric_policies.leaf_interface_profiles.name_suffix}"
}

module "aci_fabric_spine_interface_profile_auto" {
  source  = "netascode/fabric-spine-interface-profile/aci"
  version = "0.1.0"

  for_each = { for node in lookup(local.node_policies, "nodes", []) : node.id => node if node.role == "spine" && (lookup(local.apic, "auto_generate_switch_pod_profiles", local.defaults.apic.auto_generate_switch_pod_profiles) || lookup(local.apic, "auto_generate_fabric_spine_switch_interface_profiles", local.defaults.apic.auto_generate_fabric_spine_switch_interface_profiles)) && lookup(local.modules, "aci_fabric_spine_interface_profile", true) }
  name     = replace("${each.value.id}:${each.value.name}", "/^(?P<id>.+):(?P<name>.+)$/", replace(replace(lookup(local.fabric_policies, "spine_interface_profile_name", local.defaults.apic.fabric_policies.spine_interface_profile_name), "\\g<id>", "$id"), "\\g<name>", "$name"))
}

module "aci_fabric_spine_interface_profile_manual" {
  source  = "netascode/fabric-spine-interface-profile/aci"
  version = "0.1.0"

  for_each = { for prof in lookup(local.fabric_policies, "spine_interface_profiles", []) : prof.name => prof if lookup(local.modules, "aci_fabric_spine_interface_profile", true) }
  name     = "${each.value.name}${local.defaults.apic.fabric_policies.spine_interface_profiles.name_suffix}"
}

module "aci_external_connectivity_policy" {
  source  = "netascode/external-connectivity-policy/aci"
  version = "0.2.0"

  count        = lookup(lookup(local.fabric_policies, "external_connectivity_policy", {}), "name", null) != null && lookup(local.modules, "aci_external_connectivity_policy", true) ? 1 : 0
  name         = "${local.fabric_policies.external_connectivity_policy.name}${local.defaults.apic.fabric_policies.external_connectivity_policy.name_suffix}"
  route_target = lookup(lookup(local.fabric_policies, "external_connectivity_policy", {}), "route_target", local.defaults.apic.fabric_policies.external_connectivity_policy.route_target)
  fabric_id    = lookup(lookup(local.fabric_policies, "external_connectivity_policy", {}), "fabric_id", local.defaults.apic.fabric_policies.external_connectivity_policy.fabric_id)
  site_id      = lookup(lookup(local.fabric_policies, "external_connectivity_policy", {}), "site_id", local.defaults.apic.fabric_policies.external_connectivity_policy.site_id)
  bgp_password = lookup(lookup(local.fabric_policies, "external_connectivity_policy", {}), "bgp_password", null)
  routing_profiles = [for rp in lookup(lookup(local.fabric_policies, "external_connectivity_policy", {}), "routing_profiles", []) : {
    name        = rp.name
    description = lookup(rp, "description", "")
    subnets     = lookup(rp, "subnets", [])
  }]
  data_plane_teps = [for pod in lookup(local.pod_policies, "pods", []) : {
    pod_id = pod.id
    ip     = lookup(pod, "data_plane_tep", null)
  } if lookup(pod, "data_plane_tep", null) != null]
}

module "aci_infra_dscp_translation_policy" {
  source  = "netascode/infra-dscp-translation-policy/aci"
  version = "0.1.0"

  count         = lookup(local.modules, "aci_infra_dscp_translation_policy", true) == false ? 0 : 1
  admin_state   = lookup(lookup(local.fabric_policies, "infra_dscp_translation_policy", {}), "admin_state", local.defaults.apic.fabric_policies.infra_dscp_translation_policy.admin_state)
  control_plane = lookup(lookup(local.fabric_policies, "infra_dscp_translation_policy", {}), "control_plane", local.defaults.apic.fabric_policies.infra_dscp_translation_policy.control_plane)
  level_1       = lookup(lookup(local.fabric_policies, "infra_dscp_translation_policy", {}), "level_1", local.defaults.apic.fabric_policies.infra_dscp_translation_policy.level_1)
  level_2       = lookup(lookup(local.fabric_policies, "infra_dscp_translation_policy", {}), "level_2", local.defaults.apic.fabric_policies.infra_dscp_translation_policy.level_2)
  level_3       = lookup(lookup(local.fabric_policies, "infra_dscp_translation_policy", {}), "level_3", local.defaults.apic.fabric_policies.infra_dscp_translation_policy.level_3)
  level_4       = lookup(lookup(local.fabric_policies, "infra_dscp_translation_policy", {}), "level_4", local.defaults.apic.fabric_policies.infra_dscp_translation_policy.level_4)
  level_5       = lookup(lookup(local.fabric_policies, "infra_dscp_translation_policy", {}), "level_5", local.defaults.apic.fabric_policies.infra_dscp_translation_policy.level_5)
  level_6       = lookup(lookup(local.fabric_policies, "infra_dscp_translation_policy", {}), "level_6", local.defaults.apic.fabric_policies.infra_dscp_translation_policy.level_6)
  policy_plane  = lookup(lookup(local.fabric_policies, "infra_dscp_translation_policy", {}), "policy_plane", local.defaults.apic.fabric_policies.infra_dscp_translation_policy.policy_plane)
  span          = lookup(lookup(local.fabric_policies, "infra_dscp_translation_policy", {}), "span", local.defaults.apic.fabric_policies.infra_dscp_translation_policy.span)
  traceroute    = lookup(lookup(local.fabric_policies, "infra_dscp_translation_policy", {}), "traceroute", local.defaults.apic.fabric_policies.infra_dscp_translation_policy.traceroute)
}

module "aci_vmware_vmm_domain" {
  source  = "netascode/vmware-vmm-domain/aci"
  version = "0.2.1"

  for_each                    = { for vmm in lookup(local.fabric_policies, "vmware_vmm_domains", []) : vmm.name => vmm if lookup(local.modules, "aci_vmware_vmm_domain", true) }
  name                        = "${each.value.name}${local.defaults.apic.fabric_policies.vmware_vmm_domains.name_suffix}"
  access_mode                 = lookup(each.value, "access_mode", local.defaults.apic.fabric_policies.vmware_vmm_domains.access_mode)
  delimiter                   = lookup(each.value, "delimiter", local.defaults.apic.fabric_policies.vmware_vmm_domains.delimiter)
  tag_collection              = lookup(each.value, "tag_collection", local.defaults.apic.fabric_policies.vmware_vmm_domains.tag_collection)
  vlan_pool                   = "${each.value.vlan_pool}${local.defaults.apic.access_policies.vlan_pools.name_suffix}"
  vswitch_cdp_policy          = lookup(lookup(each.value, "vswitch", {}), "cdp_policy", "")
  vswitch_lldp_policy         = lookup(lookup(each.value, "vswitch", {}), "lldp_policy", "")
  vswitch_port_channel_policy = lookup(lookup(each.value, "vswitch", {}), "port_channel_policy", "")
  credential_policies = [for cp in lookup(each.value, "credential_policies", []) : {
    name     = "${cp.name}${local.defaults.apic.fabric_policies.vmware_vmm_domains.credential_policies.name_suffix}"
    username = cp.username
    password = cp.password
  }]
  vcenters = [for vc in lookup(each.value, "vcenters", []) : {
    name              = "${vc.name}${local.defaults.apic.fabric_policies.vmware_vmm_domains.vcenters.name_suffix}"
    hostname_ip       = vc.hostname_ip
    datacenter        = vc.datacenter
    credential_policy = lookup(vc, "credential_policy", null) != null ? "${vc.credential_policy}${local.defaults.apic.fabric_policies.vmware_vmm_domains.credential_policies.name_suffix}" : null
    dvs_version       = lookup(vc, "dvs_version", local.defaults.apic.fabric_policies.vmware_vmm_domains.vcenters.dvs_version)
    statistics        = lookup(vc, "statistics", local.defaults.apic.fabric_policies.vmware_vmm_domains.vcenters.statistics)
    mgmt_epg_type     = lookup(vc, "mgmt_epg", local.defaults.apic.fabric_policies.vmware_vmm_domains.vcenters.mgmt_epg)
    mgmt_epg_name     = lookup(vc, "mgmt_epg", local.defaults.apic.fabric_policies.vmware_vmm_domains.vcenters.mgmt_epg) == "oob" ? lookup(local.node_policies, "oob_endpoint_group", local.defaults.apic.node_policies.oob_endpoint_group) : lookup(local.node_policies, "inb_endpoint_group", local.defaults.apic.node_policies.inb_endpoint_group)
  }]
}

module "aci_aaa" {
  source  = "netascode/aaa/aci"
  version = "0.1.0"

  count                    = lookup(local.modules, "aci_aaa", true) == false ? 0 : 1
  remote_user_login_policy = lookup(lookup(local.fabric_policies, "aaa", {}), "remote_user_login_policy", local.defaults.apic.fabric_policies.aaa.remote_user_login_policy)
  default_fallback_check   = lookup(lookup(local.fabric_policies, "aaa", {}), "default_fallback_check", local.defaults.apic.fabric_policies.aaa.default_fallback_check)
  default_realm            = lookup(lookup(local.fabric_policies, "aaa", {}), "default_realm", local.defaults.apic.fabric_policies.aaa.default_realm)
  default_login_domain     = lookup(lookup(local.fabric_policies, "aaa", {}), "default_login_domain", "")
  console_realm            = lookup(lookup(local.fabric_policies, "aaa", {}), "console_realm", local.defaults.apic.fabric_policies.aaa.console_realm)
  console_login_domain     = lookup(lookup(local.fabric_policies, "aaa", {}), "console_login_domain", "")
}

module "aci_tacacs" {
  source  = "netascode/tacacs/aci"
  version = "0.1.0"

  for_each            = { for tacacs in lookup(lookup(local.fabric_policies, "aaa", {}), "tacacs_providers", []) : tacacs.hostname_ip => tacacs if lookup(local.modules, "aci_tacacs", true) }
  hostname_ip         = each.value.hostname_ip
  description         = lookup(each.value, "description", "")
  protocol            = lookup(each.value, "protocol", local.defaults.apic.fabric_policies.aaa.tacacs_providers.protocol)
  monitoring          = lookup(each.value, "monitoring", local.defaults.apic.fabric_policies.aaa.tacacs_providers.monitoring)
  monitoring_username = lookup(each.value, "monitoring_username", "")
  monitoring_password = lookup(each.value, "monitoring_password", "")
  key                 = lookup(each.value, "key", "")
  port                = lookup(each.value, "port", local.defaults.apic.fabric_policies.aaa.tacacs_providers.port)
  retries             = lookup(each.value, "retries", local.defaults.apic.fabric_policies.aaa.tacacs_providers.retries)
  timeout             = lookup(each.value, "timeout", local.defaults.apic.fabric_policies.aaa.tacacs_providers.timeout)
  mgmt_epg_type       = lookup(each.value, "mgmt_epg", local.defaults.apic.fabric_policies.aaa.tacacs_providers.mgmt_epg)
  mgmt_epg_name       = lookup(each.value, "mgmt_epg", local.defaults.apic.fabric_policies.aaa.tacacs_providers.mgmt_epg) == "oob" ? lookup(local.node_policies, "oob_endpoint_group", local.defaults.apic.node_policies.oob_endpoint_group) : lookup(local.node_policies, "inb_endpoint_group", local.defaults.apic.node_policies.inb_endpoint_group)
}

module "aci_user" {
  source  = "netascode/user/aci"
  version = "0.2.0"

  for_each         = { for user in lookup(lookup(local.fabric_policies, "aaa", {}), "users", []) : user.username => user if lookup(local.modules, "aci_user", true) }
  username         = each.value.username
  password         = each.value.password
  status           = lookup(each.value, "status", local.defaults.apic.fabric_policies.aaa.users.status)
  certificate_name = lookup(each.value, "certificate_name", "")
  description      = lookup(each.value, "description", "")
  email            = lookup(each.value, "email", "")
  expires          = lookup(each.value, "expires", local.defaults.apic.fabric_policies.aaa.users.expires)
  expire_date      = lookup(each.value, "expire_date", null)
  first_name       = lookup(each.value, "first_name", "")
  last_name        = lookup(each.value, "last_name", "")
  phone            = lookup(each.value, "phone", "")
  domains = [for domain in lookup(each.value, "domains", []) : {
    name = domain.name
    roles = !contains(keys(domain), "roles") ? null : [for role in domain.roles : {
      name           = role.name
      privilege_type = lookup(role, "privilege_type", local.defaults.apic.fabric_policies.aaa.users.domains.roles.privilege_type)
    }]
  }]
  certificates = lookup(each.value, "certificates", [])
  ssh_keys     = lookup(each.value, "ssh_keys", [])
}

module "aci_login_domain" {
  source  = "netascode/login-domain/aci"
  version = "0.2.0"

  for_each    = { for dom in lookup(lookup(local.fabric_policies, "aaa", {}), "login_domains", []) : dom.name => dom if lookup(local.modules, "aci_login_domain", true) }
  name        = each.value.name
  description = lookup(each.value, "description", "")
  realm       = lookup(each.value, "realm", "")
  tacacs_providers = [for prov in lookup(each.value, "tacacs_providers", []) : {
    hostname_ip = prov.hostname_ip
    priority    = lookup(prov, "priority", local.defaults.apic.fabric_policies.aaa.login_domains.tacacs_providers.priority)
  }]

  depends_on = [
    module.aci_tacacs,
  ]
}

module "aci_ca_certificate" {
  source  = "netascode/ca-certificate/aci"
  version = "0.1.0"

  for_each          = { for cert in lookup(lookup(local.fabric_policies, "aaa", {}), "ca_certificates", []) : cert.name => cert if lookup(local.modules, "aci_ca_certificate", true) }
  name              = "${each.value.name}${local.defaults.apic.fabric_policies.aaa.ca_certificates.name_suffix}"
  description       = lookup(each.value, "description", "")
  certificate_chain = each.value.certificate_chain
}

module "aci_keyring" {
  source  = "netascode/keyring/aci"
  version = "0.1.0"

  for_each       = { for kr in lookup(lookup(local.fabric_policies, "aaa", {}), "key_rings", []) : kr.name => kr if lookup(local.modules, "aci_keyring", true) }
  name           = "${each.value.name}${local.defaults.apic.fabric_policies.aaa.key_rings.name_suffix}"
  description    = lookup(each.value, "description", "")
  ca_certificate = lookup(each.value, "ca_certificate", "")
  certificate    = lookup(each.value, "certificate", "")
  private_key    = lookup(each.value, "private_key", "")
}

module "aci_geolocation" {
  source  = "netascode/geolocation/aci"
  version = "0.2.0"

  for_each    = { for site in lookup(lookup(local.fabric_policies, "geolocation", {}), "sites", []) : site.name => site if lookup(local.modules, "aci_geolocation", true) }
  name        = "${each.value.name}${local.defaults.apic.fabric_policies.geolocation.sites.name_suffix}"
  description = lookup(each.value, "description", "")
  buildings = [for building in lookup(each.value, "buildings", []) : {
    name        = "${building.name}${local.defaults.apic.fabric_policies.geolocation.sites.buildings.name_suffix}"
    description = lookup(building, "description", null)
    floors = !contains(keys(building), "floors") ? null : [for floor in building.floors : {
      name        = "${floor.name}${local.defaults.apic.fabric_policies.geolocation.sites.buildings.floors.name_suffix}"
      description = lookup(floor, "description", null)
      rooms = !contains(keys(floor), "rooms") ? null : [for room in floor.rooms : {
        name        = "${room.name}${local.defaults.apic.fabric_policies.geolocation.sites.buildings.floors.rooms.name_suffix}"
        description = lookup(room, "description", null)
        rows = !contains(keys(room), "rows") ? null : [for row in room.rows : {
          name        = "${row.name}${local.defaults.apic.fabric_policies.geolocation.sites.buildings.floors.rooms.rows.name_suffix}"
          description = lookup(row, "description", null)
          racks = !contains(keys(row), "racks") ? null : [for rack in row.racks : {
            name        = "${rack.name}${local.defaults.apic.fabric_policies.geolocation.sites.buildings.floors.rooms.rows.racks.name_suffix}"
            description = lookup(rack, "description", null)
            nodes = !contains(keys(rack), "nodes") ? null : [for node_ in rack.nodes : {
              node_id = node_
              pod_id  = try([for node in lookup(local.node_policies, "nodes", []) : lookup(node, "pod", 1) if node.id == node_][0], local.defaults.apic.node_policies.nodes.pod)
            }]
          }]
        }]
      }]
    }]
  }]
}

module "aci_remote_location" {
  source  = "netascode/remote-location/aci"
  version = "0.1.0"

  for_each        = { for rl in lookup(local.fabric_policies, "remote_locations", []) : rl.name => rl if lookup(local.modules, "aci_remote_location", true) }
  name            = "${each.value.name}${local.defaults.apic.fabric_policies.remote_locations.name_suffix}"
  hostname_ip     = each.value.hostname_ip
  description     = lookup(each.value, "description", "")
  auth_type       = lookup(each.value, "auth_type", local.defaults.apic.fabric_policies.remote_locations.auth_type)
  protocol        = each.value.protocol
  path            = lookup(each.value, "path", local.defaults.apic.fabric_policies.remote_locations.path)
  port            = lookup(each.value, "port", 0)
  username        = lookup(each.value, "username", "")
  password        = lookup(each.value, "password", "")
  ssh_private_key = lookup(each.value, "ssh_private_key", "")
  ssh_public_key  = lookup(each.value, "ssh_public_key", "")
  ssh_passphrase  = lookup(each.value, "ssh_passphrase", "")
  mgmt_epg_type   = lookup(each.value, "mgmt_epg", local.defaults.apic.fabric_policies.remote_locations.mgmt_epg)
  mgmt_epg_name   = lookup(each.value, "mgmt_epg", local.defaults.apic.fabric_policies.remote_locations.mgmt_epg) == "oob" ? lookup(local.node_policies, "oob_endpoint_group", local.defaults.apic.node_policies.oob_endpoint_group) : lookup(local.node_policies, "inb_endpoint_group", local.defaults.apic.node_policies.inb_endpoint_group)
}

module "aci_fabric_scheduler" {
  source  = "netascode/fabric-scheduler/aci"
  version = "0.2.0"

  for_each    = { for scheduler in lookup(local.fabric_policies, "schedulers", []) : scheduler.name => scheduler if lookup(local.modules, "aci_fabric_scheduler", true) }
  name        = "${each.value.name}${local.defaults.apic.fabric_policies.schedulers.name_suffix}"
  description = lookup(each.value, "description", "")
  recurring_windows = [for win in lookup(each.value, "recurring_windows", []) : {
    name   = win.name
    day    = lookup(win, "day", local.defaults.apic.fabric_policies.schedulers.recurring_windows.day)
    hour   = lookup(win, "hour", local.defaults.apic.fabric_policies.schedulers.recurring_windows.hour)
    minute = lookup(win, "minute", local.defaults.apic.fabric_policies.schedulers.recurring_windows.minute)
  }]
}

module "aci_config_export" {
  source  = "netascode/config-export/aci"
  version = "0.1.0"

  for_each        = { for ce in lookup(local.fabric_policies, "config_exports", []) : ce.name => ce if lookup(local.modules, "aci_config_export", true) }
  name            = "${each.value.name}${local.defaults.apic.fabric_policies.config_exports.name_suffix}"
  description     = lookup(each.value, "description", "")
  format          = lookup(each.value, "format", local.defaults.apic.fabric_policies.config_exports.format)
  remote_location = lookup(each.value, "remote_location", "")
  scheduler       = lookup(each.value, "scheduler", "")

  depends_on = [
    module.aci_remote_location,
    module.aci_fabric_scheduler,
  ]
}

module "aci_snmp_trap_policy" {
  source  = "netascode/snmp-trap-policy/aci"
  version = "0.2.0"

  for_each    = { for trap in lookup(lookup(local.fabric_policies, "monitoring", {}), "snmp_traps", []) : trap.name => trap if lookup(local.modules, "aci_snmp_trap_policy", true) }
  name        = "${each.value.name}${local.defaults.apic.fabric_policies.monitoring.snmp_traps.name_suffix}"
  description = lookup(each.value, "description", "")
  destinations = [for dest in lookup(each.value, "destinations", []) : {
    hostname_ip   = dest.hostname_ip
    port          = lookup(dest, "port", local.defaults.apic.fabric_policies.monitoring.snmp_traps.destinations.port)
    community     = dest.community
    security      = lookup(dest, "security", local.defaults.apic.fabric_policies.monitoring.snmp_traps.destinations.security)
    version       = lookup(dest, "version", local.defaults.apic.fabric_policies.monitoring.snmp_traps.destinations.version)
    mgmt_epg_type = lookup(dest, "mgmt_epg", local.defaults.apic.fabric_policies.monitoring.snmp_traps.destinations.mgmt_epg)
    mgmt_epg_name = lookup(dest, "mgmt_epg", local.defaults.apic.fabric_policies.monitoring.snmp_traps.destinations.mgmt_epg) == "oob" ? lookup(local.node_policies, "oob_endpoint_group", local.defaults.apic.node_policies.oob_endpoint_group) : lookup(local.node_policies, "inb_endpoint_group", local.defaults.apic.node_policies.inb_endpoint_group)
  }]
}

module "aci_syslog_policy" {
  source  = "netascode/syslog-policy/aci"
  version = "0.2.1"

  for_each            = { for syslog in lookup(lookup(local.fabric_policies, "monitoring", {}), "syslogs", []) : syslog.name => syslog if lookup(local.modules, "aci_syslog_policy", true) }
  name                = "${each.value.name}${local.defaults.apic.fabric_policies.monitoring.syslogs.name_suffix}"
  description         = lookup(each.value, "description", "")
  format              = lookup(each.value, "format", local.defaults.apic.fabric_policies.monitoring.syslogs.format)
  show_millisecond    = lookup(each.value, "show_millisecond", local.defaults.apic.fabric_policies.monitoring.syslogs.show_millisecond)
  admin_state         = lookup(each.value, "admin_state", local.defaults.apic.fabric_policies.monitoring.syslogs.admin_state)
  local_admin_state   = lookup(each.value, "local_admin_state", local.defaults.apic.fabric_policies.monitoring.syslogs.local_admin_state)
  local_severity      = lookup(each.value, "local_severity", local.defaults.apic.fabric_policies.monitoring.syslogs.local_severity)
  console_admin_state = lookup(each.value, "console_admin_state", local.defaults.apic.fabric_policies.monitoring.syslogs.console_admin_state)
  console_severity    = lookup(each.value, "console_severity", local.defaults.apic.fabric_policies.monitoring.syslogs.console_severity)
  destinations = [for dest in lookup(each.value, "destinations", []) : {
    name          = lookup(dest, "name", "")
    hostname_ip   = dest.hostname_ip
    protocol      = lookup(dest, "protocol", null)
    port          = lookup(dest, "port", local.defaults.apic.fabric_policies.monitoring.syslogs.destinations.port)
    admin_state   = lookup(dest, "admin_state", local.defaults.apic.fabric_policies.monitoring.syslogs.destinations.admin_state)
    format        = lookup(each.value, "format", local.defaults.apic.fabric_policies.monitoring.syslogs.format)
    facility      = lookup(dest, "facility", local.defaults.apic.fabric_policies.monitoring.syslogs.destinations.facility)
    severity      = lookup(dest, "severity", local.defaults.apic.fabric_policies.monitoring.syslogs.destinations.severity)
    mgmt_epg_type = lookup(dest, "mgmt_epg", local.defaults.apic.fabric_policies.monitoring.syslogs.destinations.mgmt_epg)
    mgmt_epg_name = lookup(dest, "mgmt_epg", local.defaults.apic.fabric_policies.monitoring.syslogs.destinations.mgmt_epg) == "oob" ? lookup(local.node_policies, "oob_endpoint_group", local.defaults.apic.node_policies.oob_endpoint_group) : lookup(local.node_policies, "inb_endpoint_group", local.defaults.apic.node_policies.inb_endpoint_group)
  }]
}

module "aci_monitoring_policy" {
  source  = "netascode/monitoring-policy/aci"
  version = "0.2.0"

  count              = lookup(local.modules, "aci_monitoring_policy", true) == false ? 0 : 1
  snmp_trap_policies = [for policy in lookup(lookup(local.fabric_policies, "monitoring", {}), "snmp_traps", []) : "${policy.name}${local.defaults.apic.fabric_policies.monitoring.snmp_traps.name_suffix}"]
  syslog_policies = [for policy in lookup(lookup(local.fabric_policies, "monitoring", {}), "syslogs", []) : {
    name             = "${policy.name}${local.defaults.apic.fabric_policies.monitoring.syslogs.name_suffix}"
    audit            = lookup(policy, "audit", local.defaults.apic.fabric_policies.monitoring.syslogs.audit)
    events           = lookup(policy, "events", local.defaults.apic.fabric_policies.monitoring.syslogs.events)
    faults           = lookup(policy, "faults", local.defaults.apic.fabric_policies.monitoring.syslogs.faults)
    session          = lookup(policy, "session", local.defaults.apic.fabric_policies.monitoring.syslogs.session)
    minimum_severity = lookup(policy, "minimum_severity", local.defaults.apic.fabric_policies.monitoring.syslogs.minimum_severity)
  }]

  depends_on = [
    module.aci_snmp_trap_policy,
    module.aci_syslog_policy,
  ]
}

module "aci_management_access_policy" {
  source  = "netascode/management-access-policy/aci"
  version = "0.1.0"

  for_each                     = { for policy in lookup(lookup(local.fabric_policies, "pod_policies", {}), "management_access_policies", []) : policy.name => policy if lookup(local.modules, "aci_management_access_policy", true) }
  name                         = "${each.value.name}${local.defaults.apic.fabric_policies.pod_policies.management_access_policies.name_suffix}"
  description                  = lookup(each.value, "description", "")
  telnet_admin_state           = lookup(lookup(each.value, "telnet", {}), "admin_state", local.defaults.apic.fabric_policies.pod_policies.management_access_policies.telnet.admin_state)
  telnet_port                  = lookup(lookup(each.value, "telnet", {}), "port", local.defaults.apic.fabric_policies.pod_policies.management_access_policies.telnet.port)
  ssh_admin_state              = lookup(lookup(each.value, "ssh", {}), "admin_state", local.defaults.apic.fabric_policies.pod_policies.management_access_policies.ssh.admin_state)
  ssh_password_auth            = lookup(lookup(each.value, "ssh", {}), "password_auth", local.defaults.apic.fabric_policies.pod_policies.management_access_policies.ssh.password_auth)
  ssh_port                     = lookup(lookup(each.value, "ssh", {}), "port", local.defaults.apic.fabric_policies.pod_policies.management_access_policies.ssh.port)
  ssh_aes128_ctr               = lookup(lookup(each.value, "ssh", {}), "aes128_ctr", local.defaults.apic.fabric_policies.pod_policies.management_access_policies.ssh.aes128_ctr)
  ssh_aes128_gcm               = lookup(lookup(each.value, "ssh", {}), "aes128_gcm", local.defaults.apic.fabric_policies.pod_policies.management_access_policies.ssh.aes128_gcm)
  ssh_aes192_ctr               = lookup(lookup(each.value, "ssh", {}), "aes192_ctr", local.defaults.apic.fabric_policies.pod_policies.management_access_policies.ssh.aes192_ctr)
  ssh_aes256_ctr               = lookup(lookup(each.value, "ssh", {}), "aes256_ctr", local.defaults.apic.fabric_policies.pod_policies.management_access_policies.ssh.aes256_ctr)
  ssh_chacha                   = lookup(lookup(each.value, "ssh", {}), "chacha", local.defaults.apic.fabric_policies.pod_policies.management_access_policies.ssh.chacha)
  ssh_hmac_sha1                = lookup(lookup(each.value, "ssh", {}), "hmac_sha1", local.defaults.apic.fabric_policies.pod_policies.management_access_policies.ssh.hmac_sha1)
  ssh_hmac_sha2_256            = lookup(lookup(each.value, "ssh", {}), "hmac_sha2_256", local.defaults.apic.fabric_policies.pod_policies.management_access_policies.ssh.hmac_sha2_256)
  ssh_hmac_sha2_512            = lookup(lookup(each.value, "ssh", {}), "hmac_sha2_512", local.defaults.apic.fabric_policies.pod_policies.management_access_policies.ssh.hmac_sha2_512)
  https_admin_state            = lookup(lookup(each.value, "https", {}), "admin_state", local.defaults.apic.fabric_policies.pod_policies.management_access_policies.https.admin_state)
  https_client_cert_auth_state = lookup(lookup(each.value, "https", {}), "client_cert_auth_state", local.defaults.apic.fabric_policies.pod_policies.management_access_policies.https.client_cert_auth_state)
  https_port                   = lookup(lookup(each.value, "https", {}), "port", local.defaults.apic.fabric_policies.pod_policies.management_access_policies.https.port)
  https_dh                     = lookup(lookup(each.value, "https", {}), "dh", local.defaults.apic.fabric_policies.pod_policies.management_access_policies.https.dh)
  https_tlsv1                  = lookup(lookup(each.value, "https", {}), "tlsv1", local.defaults.apic.fabric_policies.pod_policies.management_access_policies.https.tlsv1)
  https_tlsv1_1                = lookup(lookup(each.value, "https", {}), "tlsv1_1", local.defaults.apic.fabric_policies.pod_policies.management_access_policies.https.tlsv1_1)
  https_tlsv1_2                = lookup(lookup(each.value, "https", {}), "tlsv1_2", local.defaults.apic.fabric_policies.pod_policies.management_access_policies.https.tlsv1_2)
  https_keyring                = lookup(lookup(each.value, "https", {}), "key_ring", local.defaults.apic.fabric_policies.pod_policies.management_access_policies.https.key_ring)
  http_admin_state             = lookup(lookup(each.value, "http", {}), "admin_state", local.defaults.apic.fabric_policies.pod_policies.management_access_policies.http.admin_state)
  http_port                    = lookup(lookup(each.value, "http", {}), "port", local.defaults.apic.fabric_policies.pod_policies.management_access_policies.http.port)
}

module "aci_interface_type" {
  source  = "netascode/interface-type/aci"
  version = "0.1.0"

  for_each = { for type in local.interface_types : type.key => type if lookup(local.modules, "aci_interface_type", true) }
  pod_id   = each.value.pod_id
  node_id  = each.value.node_id
  module   = each.value.module
  port     = each.value.port
  type     = each.value.type
}

module "aci_smart_licensing" {
  source  = "netascode/smart-licensing/aci"
  version = "0.1.0"

  count              = lookup(local.modules, "aci_smart_licensing", true) == true && try(local.fabric_policies.smart_licensing.registration_token, "") != "" ? 1 : 0
  mode               = try(local.fabric_policies.smart_licensing.mode, local.defaults.apic.fabric_policies.smart_licensing.mode)
  registration_token = try(local.fabric_policies.smart_licensing.registration_token, "")
  url                = try(local.fabric_policies.smart_licensing.url, local.defaults.apic.fabric_policies.smart_licensing.url)
  proxy_hostname_ip  = try(local.fabric_policies.smart_licensing.proxy.hostname_ip, "")
  proxy_port         = try(local.fabric_policies.smart_licensing.proxy.port, local.defaults.apic.fabric_policies.smart_licensing.proxy.port)
}

module "aci_health_score_evaluation_policy" {
  source  = "netascode/health-score-evaluation-policy/aci"
  version = "0.1.0"

  count               = try(local.modules.aci_health_score_evaluation_policy, true) ? 1 : 0
  ignore_acked_faults = try(local.fabric_policies.ignore_acked_faults, local.defaults.apic.fabric_policies.ignore_acked_faults)
}
