From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net-next 00/21] treewide: Use consistent api style
	for address testing
Date: Thu, 18 Oct 2012 20:55:31 -0700
Message-ID: <cover.1350618006.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: <lvs-devel.vger.kernel.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
To: davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, e1000-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, cbe-oss-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, wimax-BPSAo7wm5JOHVYUYWc+uSQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org, b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-parisc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devel-s9riP+hp16TNLxjTenLetw@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org, bridge-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, lvs-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Cc: devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, user-mode-linux-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, user-mode-linux-user-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org

ethernet, ipv4, and ipv6 address testing uses 3 different api naming styles.

ethernet uses:	is_<foo>_ether_addr
ipv4 uses:	ipv4_is_<foo>
ipv6 uses:	ipv6_addr_<foo>

Standardize on the ipv6 style of <prefix>_addr_<type> to reduce
the number of styles to remember.

The new consistent styles are:

eth_addr_<foo>(const u8 *)
ipv4_addr_<foo>(__be32)
ipv6_addr_<foo>(const struct in6_addr *)

Add temporary backward compatibility #defines for the old names too.

Joe Perches (21):
  etherdevice: Rename is_<foo>_ether_addr tests to eth_addr_<foo>
  net: Convert is_<foo>_ether_addr uses to eth_addr_<foo>
  arch: Convert is_<foo>_ether_addr uses to eth_addr_<foo>
  wireless: Convert is_<foo>_ether_addr uses to eth_addr_<foo>
  drivers: net: Convert is_<foo>_ether_addr uses to eth_addr_<foo>
  staging: Convert is_<foo>_ether_addr uses to eth_addr_<foo>
  infiniband: Convert is_<foo>_ether_addr uses to eth_addr_<foo>
  scsi: Convert is_<foo>_ether_addr uses to eth_addr_<foo>
  of: Convert is_<foo>_ether_addr uses to eth_addr_<foo>
  s390: Convert is_<foo>_ether_addr uses to eth_addr_<foo>
  usb: Convert is_<foo>_ether_addr uses to eth_addr_<foo>
  uwb: Convert is_<foo>_ether_addr uses to eth_addr_<foo>
  Documentation: networking: Convert is_<foo>_ether_addr uses to eth_addr_<foo>
  llc_if.h: Convert is_<foo>_ether_addr uses to eth_addr_<foo>
  in.h: Rename ipv4_is_<foo> functions to ipv4_addr_<foo>
  net: Convert ipv4_is_<foo> uses to ipv4_addr_<foo>
  infiniband: Convert ipv4_is_<foo> uses to ipv4_addr_<foo>
  ath6kl: Convert ipv4_is_<foo> uses to ipv4_addr_<foo>
  parisc: Convert ipv4_is_<foo> uses to ipv4_addr_<foo>
  lockd: Convert ipv4_is_<foo> uses to ipv4_addr_<foo>
  sctp: Convert ipv4_is_<foo> uses to ipv4_addr_<foo>

 Documentation/networking/driver.txt                |    2 +-
 arch/arm/mach-davinci/board-mityomapl138.c         |    2 +-
 arch/arm/mach-pxa/colibri-pxa3xx.c                 |    2 +-
 arch/avr32/boards/atngw100/setup.c                 |    2 +-
 arch/avr32/boards/atstk1000/atstk1002.c            |    2 +-
 arch/avr32/boards/favr-32/setup.c                  |    2 +-
 arch/avr32/boards/hammerhead/setup.c               |    2 +-
 arch/avr32/boards/merisc/setup.c                   |    2 +-
 arch/avr32/boards/mimc200/setup.c                  |    2 +-
 arch/mips/alchemy/common/platform.c                |    4 +-
 arch/um/drivers/net_kern.c                         |    6 +-
 drivers/infiniband/core/cma.c                      |    4 +-
 drivers/infiniband/hw/amso1100/c2.c                |    2 +-
 drivers/infiniband/hw/nes/nes_nic.c                |    2 +-
 drivers/net/bonding/bond_3ad.c                     |    2 +-
 drivers/net/bonding/bond_alb.c                     |    2 +-
 drivers/net/bonding/bond_main.c                    |    6 +-
 drivers/net/dummy.c                                |    2 +-
 drivers/net/ethernet/3com/3c59x.c                  |    2 +-
 drivers/net/ethernet/3com/typhoon.c                |    2 +-
 drivers/net/ethernet/8390/etherh.c                 |    2 +-
 drivers/net/ethernet/adi/bfin_mac.c                |    6 +-
 drivers/net/ethernet/aeroflex/greth.c              |    4 +-
 drivers/net/ethernet/amd/au1000_eth.c              |    2 +-
 drivers/net/ethernet/amd/depca.c                   |    4 +-
 drivers/net/ethernet/amd/pcnet32.c                 |    8 ++--
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.c      |    2 +-
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c    |    2 +-
 drivers/net/ethernet/atheros/atl1e/atl1e_hw.c      |    4 +-
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c    |    2 +-
 drivers/net/ethernet/atheros/atlx/atl1.c           |   10 ++--
 drivers/net/ethernet/atheros/atlx/atl2.c           |   14 +++---
 drivers/net/ethernet/atheros/atlx/atlx.c           |    2 +-
 drivers/net/ethernet/broadcom/b44.c                |    4 +-
 drivers/net/ethernet/broadcom/bnx2.c               |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |    6 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |    4 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |    6 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c     |    2 +-
 drivers/net/ethernet/broadcom/cnic.c               |    2 +-
 drivers/net/ethernet/broadcom/tg3.c                |    6 +-
 drivers/net/ethernet/brocade/bna/bnad.c            |    6 +-
 drivers/net/ethernet/cadence/at91_ether.c          |    6 +-
 drivers/net/ethernet/cadence/macb.c                |    4 +-
 drivers/net/ethernet/calxeda/xgmac.c               |    6 +-
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c    |    2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |    2 +-
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |    2 +-
 drivers/net/ethernet/cirrus/ep93xx_eth.c           |    2 +-
 drivers/net/ethernet/cirrus/mac89x0.c              |    2 +-
 drivers/net/ethernet/cisco/enic/enic_dev.c         |    4 +-
 drivers/net/ethernet/cisco/enic/enic_main.c        |   10 ++--
 drivers/net/ethernet/cisco/enic/enic_pp.c          |   10 ++--
 drivers/net/ethernet/davicom/dm9000.c              |    6 +-
 drivers/net/ethernet/dec/ewrk3.c                   |    4 +-
 drivers/net/ethernet/dec/tulip/de4x5.c             |    4 +-
 drivers/net/ethernet/dlink/sundance.c              |    2 +-
 drivers/net/ethernet/dnet.c                        |    6 +-
 drivers/net/ethernet/emulex/benet/be_main.c        |    8 ++--
 drivers/net/ethernet/ethoc.c                       |    6 +-
 drivers/net/ethernet/faraday/ftgmac100.c           |    2 +-
 drivers/net/ethernet/faraday/ftmac100.c            |    2 +-
 drivers/net/ethernet/freescale/fec.c               |    8 ++--
 drivers/net/ethernet/freescale/fec_mpc52xx.c       |    2 +-
 drivers/net/ethernet/freescale/gianfar_ethtool.c   |   12 ++--
 drivers/net/ethernet/freescale/ucc_geth.c          |    2 +-
 drivers/net/ethernet/i825xx/ether1.c               |    2 +-
 drivers/net/ethernet/ibm/ehea/ehea_main.c          |    4 +-
 drivers/net/ethernet/intel/e100.c                  |    4 +-
 drivers/net/ethernet/intel/e1000/e1000_main.c      |    4 +-
 drivers/net/ethernet/intel/e1000e/mac.c            |    2 +-
 drivers/net/ethernet/intel/e1000e/netdev.c         |    4 +-
 drivers/net/ethernet/intel/igb/e1000_mac.c         |    2 +-
 drivers/net/ethernet/intel/igb/igb_main.c          |    8 ++--
 drivers/net/ethernet/intel/igbvf/netdev.c          |    6 +-
 drivers/net/ethernet/intel/ixgb/ixgb_hw.c          |    6 +-
 drivers/net/ethernet/intel/ixgb/ixgb_main.c        |    6 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c      |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |   14 +++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c     |    6 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  |    8 ++--
 drivers/net/ethernet/lantiq_etop.c                 |    2 +-
 drivers/net/ethernet/marvell/mv643xx_eth.c         |    4 +-
 drivers/net/ethernet/marvell/pxa168_eth.c          |    2 +-
 drivers/net/ethernet/marvell/skge.c                |    6 +-
 drivers/net/ethernet/marvell/sky2.c                |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |    2 +-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    4 +-
 drivers/net/ethernet/micrel/ks8695net.c            |    6 +-
 drivers/net/ethernet/micrel/ks8842.c               |    4 +-
 drivers/net/ethernet/micrel/ks8851.c               |    4 +-
 drivers/net/ethernet/micrel/ks8851_mll.c           |    2 +-
 drivers/net/ethernet/microchip/enc28j60.c          |    4 +-
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c   |    2 +-
 drivers/net/ethernet/neterion/s2io.c               |    2 +-
 drivers/net/ethernet/neterion/vxge/vxge-config.c   |    2 +-
 drivers/net/ethernet/neterion/vxge/vxge-main.c     |   12 ++--
 drivers/net/ethernet/netx-eth.c                    |    2 +-
 drivers/net/ethernet/nuvoton/w90p910_ether.c       |    4 +-
 drivers/net/ethernet/nvidia/forcedeth.c            |    4 +-
 drivers/net/ethernet/nxp/lpc_eth.c                 |    8 ++--
 drivers/net/ethernet/octeon/octeon_mgmt.c          |    2 +-
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |    6 +-
 drivers/net/ethernet/pasemi/pasemi_mac.c           |    4 +-
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |    4 +-
 drivers/net/ethernet/qlogic/qla3xxx.c              |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |    4 +-
 drivers/net/ethernet/qlogic/qlge/qlge_main.c       |    6 +-
 drivers/net/ethernet/realtek/8139cp.c              |    2 +-
 drivers/net/ethernet/realtek/8139too.c             |    2 +-
 drivers/net/ethernet/realtek/r8169.c               |    2 +-
 drivers/net/ethernet/renesas/sh_eth.c              |    4 +-
 drivers/net/ethernet/seeq/ether3.c                 |    2 +-
 drivers/net/ethernet/sfc/efx.c                     |    2 +-
 drivers/net/ethernet/sfc/ethtool.c                 |    6 +-
 drivers/net/ethernet/sfc/siena_sriov.c             |    6 +-
 drivers/net/ethernet/sis/sis900.c                  |    2 +-
 drivers/net/ethernet/smsc/smc911x.c                |    4 +-
 drivers/net/ethernet/smsc/smc91x.c                 |    4 +-
 drivers/net/ethernet/smsc/smsc911x.c               |   10 ++--
 drivers/net/ethernet/smsc/smsc9420.c               |    6 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |    4 +-
 drivers/net/ethernet/sun/niu.c                     |    8 ++--
 drivers/net/ethernet/sun/sungem.c                  |    2 +-
 drivers/net/ethernet/ti/cpsw.c                     |    2 +-
 drivers/net/ethernet/ti/davinci_emac.c             |    6 +-
 drivers/net/ethernet/tile/tilegx.c                 |    4 +-
 drivers/net/ethernet/tile/tilepro.c                |    4 +-
 drivers/net/ethernet/toshiba/ps3_gelic_net.c       |    2 +-
 drivers/net/ethernet/toshiba/ps3_gelic_wireless.c  |    2 +-
 drivers/net/ethernet/toshiba/spider_net.c          |    4 +-
 drivers/net/ethernet/toshiba/tc35815.c             |    4 +-
 drivers/net/ethernet/tundra/tsi108_eth.c           |    8 ++--
 drivers/net/ethernet/via/via-rhine.c               |    2 +-
 drivers/net/ethernet/wiznet/w5100.c                |    6 +-
 drivers/net/ethernet/wiznet/w5300.c                |    6 +-
 drivers/net/ethernet/xilinx/ll_temac_main.c        |    2 +-
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c  |    2 +-
 drivers/net/hamradio/bpqether.c                    |    2 +-
 drivers/net/ifb.c                                  |    2 +-
 drivers/net/macvlan.c                              |   16 +++---
 drivers/net/phy/at803x.c                           |    2 +-
 drivers/net/rionet.c                               |    4 +-
 drivers/net/team/team.c                            |    4 +-
 drivers/net/tun.c                                  |    4 +-
 drivers/net/usb/asix_common.c                      |    2 +-
 drivers/net/usb/dm9601.c                           |    4 +-
 drivers/net/usb/mcs7830.c                          |    2 +-
 drivers/net/usb/smsc75xx.c                         |    2 +-
 drivers/net/usb/smsc95xx.c                         |    2 +-
 drivers/net/veth.c                                 |    2 +-
 drivers/net/vxlan.c                                |    4 +-
 drivers/net/wimax/i2400m/driver.c                  |    2 +-
 drivers/net/wireless/adm8211.c                     |    2 +-
 drivers/net/wireless/airo.c                        |    4 +-
 drivers/net/wireless/at76c50x-usb.c                |    8 ++--
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |    8 ++--
 drivers/net/wireless/ath/ath6kl/main.c             |    8 ++--
 drivers/net/wireless/ath/ath6kl/txrx.c             |   10 ++--
 drivers/net/wireless/ath/ath6kl/wmi.c              |    4 +-
 drivers/net/wireless/ath/ath9k/recv.c              |    8 ++--
 drivers/net/wireless/b43/main.c                    |    2 +-
 drivers/net/wireless/b43legacy/main.c              |    2 +-
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |    4 +-
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |    2 +-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |    2 +-
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |   16 +++---
 drivers/net/wireless/hostap/hostap_info.c          |    2 +-
 drivers/net/wireless/hostap/hostap_ioctl.c         |    8 ++--
 drivers/net/wireless/hostap/hostap_main.c          |    2 +-
 drivers/net/wireless/ipw2x00/ipw2100.c             |    6 +-
 drivers/net/wireless/ipw2x00/ipw2200.c             |   18 +++---
 drivers/net/wireless/ipw2x00/libipw_rx.c           |   12 ++--
 drivers/net/wireless/ipw2x00/libipw_tx.c           |    4 +-
 drivers/net/wireless/iwlegacy/3945-mac.c           |    2 +-
 drivers/net/wireless/iwlegacy/4965-mac.c           |    2 +-
 drivers/net/wireless/iwlegacy/common.c             |    2 +-
 drivers/net/wireless/iwlwifi/dvm/sta.c             |    2 +-
 drivers/net/wireless/libertas_tf/main.c            |    2 +-
 drivers/net/wireless/mwifiex/join.c                |    2 +-
 drivers/net/wireless/mwifiex/scan.c                |    2 +-
 drivers/net/wireless/mwifiex/sta_cmd.c             |    2 +-
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |    2 +-
 drivers/net/wireless/mwifiex/uap_txrx.c            |    2 +-
 drivers/net/wireless/mwl8k.c                       |    2 +-
 drivers/net/wireless/orinoco/wext.c                |    4 +-
 drivers/net/wireless/p54/eeprom.c                  |    2 +-
 drivers/net/wireless/rndis_wlan.c                  |   18 +++---
 drivers/net/wireless/rt2x00/rt2400pci.c            |    2 +-
 drivers/net/wireless/rt2x00/rt2500pci.c            |    2 +-
 drivers/net/wireless/rt2x00/rt2500usb.c            |    2 +-
 drivers/net/wireless/rt2x00/rt2800lib.c            |    8 ++--
 drivers/net/wireless/rt2x00/rt61pci.c              |    2 +-
 drivers/net/wireless/rt2x00/rt73usb.c              |    2 +-
 drivers/net/wireless/rtl818x/rtl8180/dev.c         |    4 +-
 drivers/net/wireless/rtl818x/rtl8187/dev.c         |    4 +-
 drivers/net/wireless/rtlwifi/base.c                |    6 +-
 drivers/net/wireless/rtlwifi/cam.c                 |    2 +-
 drivers/net/wireless/rtlwifi/pci.c                 |    8 ++--
 drivers/net/wireless/rtlwifi/rc.c                  |    4 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c       |    4 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c       |    4 +-
 drivers/net/wireless/rtlwifi/usb.c                 |   12 ++--
 drivers/net/wireless/ti/wl1251/main.c              |   12 ++--
 drivers/net/wireless/ti/wlcore/cmd.c               |    2 +-
 drivers/net/wireless/ti/wlcore/main.c              |    6 +-
 drivers/net/wireless/ti/wlcore/tx.c                |    2 +-
 drivers/net/wireless/wl3501_cs.c                   |    2 +-
 drivers/net/wireless/zd1211rw/zd_mac.c             |    2 +-
 drivers/of/of_net.c                                |    6 +-
 drivers/parisc/led.c                               |    2 +-
 drivers/s390/net/qeth_l2_main.c                    |    4 +-
 drivers/scsi/bnx2fc/bnx2fc_els.c                   |    4 +-
 drivers/scsi/bnx2fc/bnx2fc_fcoe.c                  |    2 +-
 drivers/scsi/fcoe/fcoe.c                           |   12 ++--
 drivers/scsi/fcoe/fcoe_ctlr.c                      |    8 ++--
 drivers/scsi/fnic/fnic_fcs.c                       |    6 +-
 drivers/staging/ccg/u_ether.c                      |    6 +-
 drivers/staging/csr/sme_wext.c                     |    2 +-
 drivers/staging/et131x/et131x.c                    |    4 +-
 drivers/staging/gdm72xx/gdm_wimax.c                |    2 +-
 drivers/staging/octeon/ethernet.c                  |    2 +-
 drivers/staging/ozwpan/ozcdev.c                    |    2 +-
 .../rtl8187se/ieee80211/ieee80211_softmac.c        |    2 +-
 .../rtl8187se/ieee80211/ieee80211_softmac_wx.c     |    2 +-
 drivers/staging/rtl8187se/ieee80211/ieee80211_tx.c |    2 +-
 drivers/staging/rtl8187se/r8180_core.c             |    2 +-
 drivers/staging/rtl8192e/rtl8192e/rtl_core.c       |    6 +-
 drivers/staging/rtl8192e/rtl819x_TSProc.c          |    2 +-
 drivers/staging/rtl8192e/rtllib_rx.c               |    8 ++--
 drivers/staging/rtl8192e/rtllib_softmac.c          |    4 +-
 drivers/staging/rtl8192e/rtllib_softmac_wx.c       |    4 +-
 drivers/staging/rtl8192e/rtllib_tx.c               |   12 ++--
 drivers/staging/rtl8192u/ieee80211/ieee80211_rx.c  |    4 +-
 .../staging/rtl8192u/ieee80211/ieee80211_softmac.c |    2 +-
 .../rtl8192u/ieee80211/ieee80211_softmac_wx.c      |    2 +-
 drivers/staging/rtl8192u/ieee80211/ieee80211_tx.c  |   12 ++--
 .../staging/rtl8192u/ieee80211/rtl819x_TSProc.c    |    2 +-
 drivers/staging/rtl8192u/r8192U_core.c             |    8 ++--
 drivers/staging/rtl8712/rtl871x_ioctl_linux.c      |    2 +-
 drivers/staging/rtl8712/rtl871x_ioctl_set.c        |    2 +-
 drivers/staging/rtl8712/rtl871x_mlme.c             |    2 +-
 drivers/staging/rtl8712/rtl871x_recv.c             |    8 ++--
 drivers/staging/slicoss/slicoss.c                  |    2 +-
 drivers/staging/vt6655/bssdb.c                     |    2 +-
 drivers/staging/vt6655/card.c                      |    2 +-
 drivers/staging/vt6655/device_main.c               |    2 +-
 drivers/staging/vt6655/dpc.c                       |    4 +-
 drivers/staging/vt6655/hostap.c                    |    4 +-
 drivers/staging/vt6655/iwctl.c                     |    2 +-
 drivers/staging/vt6655/key.c                       |    2 +-
 drivers/staging/vt6655/mib.c                       |    8 ++--
 drivers/staging/vt6655/rxtx.c                      |   10 ++--
 drivers/staging/vt6655/wpactl.c                    |    4 +-
 drivers/staging/vt6656/bssdb.c                     |    2 +-
 drivers/staging/vt6656/dpc.c                       |    4 +-
 drivers/staging/vt6656/hostap.c                    |    4 +-
 drivers/staging/vt6656/iwctl.c                     |    2 +-
 drivers/staging/vt6656/key.c                       |    2 +-
 drivers/staging/vt6656/rxtx.c                      |   14 +++---
 drivers/staging/vt6656/wpactl.c                    |    2 +-
 drivers/staging/wlags49_h2/wl_wext.c               |    2 +-
 drivers/usb/gadget/u_ether.c                       |    6 +-
 drivers/uwb/address.c                              |    2 +-
 include/linux/etherdevice.h                        |   36 ++++++++-----
 include/linux/in.h                                 |   40 ++++++++++----
 include/linux/lockd/lockd.h                        |    4 +-
 include/net/llc_if.h                               |    4 +-
 include/net/sctp/constants.h                       |   12 ++--
 net/802/stp.c                                      |    4 +-
 net/8021q/vlan_dev.c                               |    6 +-
 net/8021q/vlan_netlink.c                           |    2 +-
 net/batman-adv/bat_iv_ogm.c                        |    2 +-
 net/batman-adv/bridge_loop_avoidance.c             |    8 ++--
 net/batman-adv/routing.c                           |   20 ++++----
 net/batman-adv/soft-interface.c                    |    4 +-
 net/batman-adv/unicast.c                           |    2 +-
 net/batman-adv/vis.c                               |    4 +-
 net/bridge/br_device.c                             |    6 +-
 net/bridge/br_fdb.c                                |    2 +-
 net/bridge/br_if.c                                 |    2 +-
 net/bridge/br_input.c                              |    8 ++--
 net/bridge/br_multicast.c                          |    4 +-
 net/bridge/br_netlink.c                            |    2 +-
 net/core/netpoll.c                                 |    2 +-
 net/core/pktgen.c                                  |   14 +++---
 net/core/rtnetlink.c                               |    2 +-
 net/dsa/slave.c                                    |    2 +-
 net/ethernet/eth.c                                 |    6 +-
 net/ipv4/arp.c                                     |    4 +-
 net/ipv4/datagram.c                                |    2 +-
 net/ipv4/devinet.c                                 |    4 +-
 net/ipv4/fib_frontend.c                            |   12 ++--
 net/ipv4/igmp.c                                    |   12 ++--
 net/ipv4/ip_gre.c                                  |   22 ++++----
 net/ipv4/ipmr.c                                    |    4 +-
 net/ipv4/netfilter/ipt_rpfilter.c                  |   10 ++--
 net/ipv4/ping.c                                    |    2 +-
 net/ipv4/raw.c                                     |    2 +-
 net/ipv4/route.c                                   |   58 ++++++++++----------
 net/ipv4/udp.c                                     |    2 +-
 net/ipv6/addrconf.c                                |   12 ++--
 net/ipv6/ip6_gre.c                                 |    2 +-
 net/l2tp/l2tp_ip.c                                 |    2 +-
 net/l2tp/l2tp_ip6.c                                |    2 +-
 net/mac80211/cfg.c                                 |    2 +-
 net/mac80211/ibss.c                                |    8 ++--
 net/mac80211/ieee80211_i.h                         |    2 +-
 net/mac80211/iface.c                               |   12 ++--
 net/mac80211/mesh.c                                |    2 +-
 net/mac80211/mesh_hwmp.c                           |    4 +-
 net/mac80211/mesh_pathtbl.c                        |    4 +-
 net/mac80211/mesh_plink.c                          |    2 +-
 net/mac80211/mlme.c                                |    4 +-
 net/mac80211/rx.c                                  |   50 +++++++++---------
 net/mac80211/sta_info.c                            |    2 +-
 net/mac80211/status.c                              |    6 +-
 net/mac80211/tx.c                                  |   22 ++++----
 net/mac80211/wme.c                                 |    4 +-
 net/netfilter/ipvs/ip_vs_xmit.c                    |    6 +-
 net/netfilter/xt_cluster.c                         |    2 +-
 net/netfilter/xt_pkttype.c                         |    2 +-
 net/openvswitch/flow.c                             |    4 +-
 net/openvswitch/vport-internal_dev.c               |    2 +-
 net/sctp/protocol.c                                |   10 ++--
 net/wireless/core.c                                |    2 +-
 net/wireless/ibss.c                                |    2 +-
 net/wireless/nl80211.c                             |    4 +-
 net/wireless/util.c                                |    4 +-
 net/wireless/wext-compat.c                         |    2 +-
 net/wireless/wext-sme.c                            |    2 +-
 331 files changed, 833 insertions(+), 809 deletions(-)

-- 
1.7.8.111.gad25c.dirty
