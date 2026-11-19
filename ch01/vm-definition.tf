# 第1章のコード例: 仮想マシンをコードで定義する
#
# 本書第1章に掲載した抜粋の完全な形。
# アドレスや名前は台帳 (NetBox) の記録と対応し、環境はこの定義から作られる。
# IPアドレスは本書用に 10.10.x へ置き換えた例示値である。
# 書き方の詳細は本書第5章を参照。

terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.75"
    }
  }
}

# 公開の面 (dmz) に置く配布用ホスト img01 の定義
resource "proxmox_virtual_environment_vm" "img01" {
  name      = "img01"
  node_name = "pve01"

  clone {
    vm_id = 9000 # cloud image から作ったテンプレート
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 4096
  }

  disk {
    datastore_id = "local-lvm"
    size         = 64
  }

  initialization {
    ip_config {
      ipv4 {
        address = "10.10.58.11/24"
        gateway = "10.10.58.1"
      }
    }
  }

  agent {
    enabled = true
  }
}

# 配布する cloud image の取得元 (自前の配布サイト)
resource "proxmox_virtual_environment_download_file" "ubuntu_2604" {
  content_type = "iso"
  datastore_id = "cephfs"
  node_name    = "pve01"
  url          = "https://cloud-images.witenp.com/resolute/current/ubuntu-26.04-server-cloudimg-amd64-fixed.img.qcow2"
}
