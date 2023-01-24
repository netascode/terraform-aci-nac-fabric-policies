terraform {
  required_version = ">= 1.3.0"

  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }

    aci = {
      source  = "CiscoDevNet/aci"
      version = ">=2.0.0"
    }
  }
}

module "main" {
  source = "../.."

  model = {
    apic = {
      fabric_policies = {
        banners = {
          apic_cli_banner = "CLI Banner"
        }
      }
    }
  }
}

data "aci_rest_managed" "aaaPreLoginBanner" {
  dn = "uni/userext/preloginbanner"

  depends_on = [module.main]
}

resource "test_assertions" "aaaPreLoginBanner" {
  component = "aaaPreLoginBanner"

  equal "message" {
    description = "message"
    got         = data.aci_rest_managed.aaaPreLoginBanner.content.message
    want        = "CLI Banner"
  }
}
