From: Randy Dunlap <rdunlap@xenotime.net>
Subject: ipvs oops in 3.0-rc7
Date: Wed, 20 Jul 2011 20:50:19 -0700
Message-ID: <20110720205019.9dfa30c3.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: netdev <netdev@vger.kernel.org>, lvs-devel@vger.kernel.org
Cc: Simon Horman <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

I'm seeing the following Oops in 3.0-rc7 on x86_64, just loading and unloading
modules.  Any chance this is already fixed?  I can test current git, but I
wanted to ask first.

Looks like it is on the second module load of ip_vs (i.e.,
modprobe ip_vs; rmmod ip_vs; modprobe ip_vs).


Jul 20 17:15:05 chimera kernel: [ 3323.505527] IPVS: ipvs unloaded.
Jul 20 17:15:06 chimera kernel: [ 3324.554297] BUG: unable to handle kernel paging request at ffffffffa1543820
Jul 20 17:15:06 chimera kernel: [ 3324.554382] IP: [<ffffffff810a8d4f>] raw_notifier_chain_register+0x1f/0x4a
Jul 20 17:15:06 chimera kernel: [ 3324.554445] PGD 1872067 PUD 1876063 PMD b653f067 PTE 0
Jul 20 17:15:06 chimera kernel: [ 3324.554505] Oops: 0000 [#1] SMP 
Jul 20 17:15:06 chimera kernel: [ 3324.554551] CPU 1 
Jul 20 17:15:06 chimera kernel: [ 3324.554574] Modules linked in: ip_vs(+) nf_conntrack_sip nf_tproxy_core xt_RATEEST nf_conntrack_proto_gre nfnetlink_log nfnetlink nf_conntrack_broadcast l2tp_core can rdma_cm ib_cm iw_cm ib_sa ib_mad ib_core ib_addr atm kernelcapi fcrypt pcbc af_rxrpc xp gru macvtap tun isdnhdlc mISDNipac mISDN_core chipreg map_funcs macvlan ptp pps_core mdio_bitbang hdlcdrv ax25 mdio pppox gre inet_lro cycx_drv wanrouter hdlc lapb uio ppp_generic xenbus_probe_frontend configfs ecb rtl8192c_common ath9k_common ath9k_hw ath libertas atmel rt2x00pci rt2x00usb rt2x00lib rng_core orinoco wl12xx crc7 p54common arc4 hostap rndis_host eeprom_93cx6 libipw lib80211 mac80211 cfg80211 fddi crc32c libcrc32c dca com20020 arcnet psnap cdc_ether phonet usbnet sja1000 can_dev sir_dev ird
 a crc_ccitt mtd zlib_deflate slhc virtio_ring virtio tr i2400m wimax mii usbserial leds_net5501 fuse af_packet ipt_MASQUERADE iptable_nat nf_nat nfsd lockd nfs_acl auth_rpcgss stp llc bnep bluetooth rfkill crc16 sunrpc ipt_REJEC
Jul 20 17:15:06 chimera kernel: T nf_conntrack_ipv4 nf_defrag_ipv4 iptable_filter ip_tables ip6t_REJECT xt_tcpudp nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables x_tables ipv6 cpufreq_ondemand acpi_cpufreq freq_table mperf binfmt_misc dm_mirror dm_region_hash dm_log dm_multipath scsi_dh dm_mod kvm_intel kvm uinput mousedev sr_mod cdrom ppdev snd_hda_codec_idt snd_hda_intel snd_hda_codec snd_hwdep snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device ide_pci_generic snd_pcm_oss usbmouse ide_core snd_mixer_oss firewire_ohci usbhid snd_pcm firewire_core usb_storage hid usblp ata_generic i2c_i801 sg pcspkr snd_timer pata_acpi usb_libusual iTCO_wdt iTCO_vendor_support uas snd crc_itu_t soundcore pata_marvell snd_page_alloc parport_pc evdev process
 or parport mac_hid rtc_cmos unix sd_mod crc_t10dif ext3 jbd mbcache uhci_hcd ohci_hcd ssb mmc_core pcmcia pcmcia_core firmware_class ehci_hcd usbcore i915 drm_kms_helper intel_agp button intel_gtt video thermal_sys hwmon [last unlo
Jul 20 17:15:06 chimera kernel: aded: ip_vs]
Jul 20 17:15:06 chimera kernel: [ 3324.556037] 
Jul 20 17:15:06 chimera kernel: [ 3324.556037] Pid: 20884, comm: modprobe Not tainted 3.0.0-rc7 #6 Gateway GT5636E/DG965OT
Jul 20 17:15:06 chimera kernel: [ 3324.556037] RIP: 0010:[<ffffffff810a8d4f>]  [<ffffffff810a8d4f>] raw_notifier_chain_register+0x1f/0x4a
Jul 20 17:15:06 chimera kernel: [ 3324.556037] RSP: 0018:ffff8800b5169e88  EFLAGS: 00010202
Jul 20 17:15:06 chimera kernel: [ 3324.556037] RAX: ffffffffa1543810 RBX: ffffffffa18f3810 RCX: 0000000000000000
Jul 20 17:15:06 chimera kernel: [ 3324.556037] RDX: 0000000000000000 RSI: ffffffffa18f3810 RDI: ffffffffa125f9b8
Jul 20 17:15:06 chimera kernel: [ 3324.556037] RBP: ffff8800b5169e88 R08: ffffffff810aa3ee R09: 0000000000000000
Jul 20 17:15:06 chimera kernel: [ 3324.556037] R10: 0000000000000088 R11: ffffffff81b24258 R12: ffffffffa1908155
Jul 20 17:15:06 chimera kernel: [ 3324.556037] R13: 0000000000000000 R14: 000003060ede68d6 R15: 0000000000000000
Jul 20 17:15:06 chimera kernel: [ 3324.556037] FS:  00007f6e2d1856f0(0000) GS:ffff88011b400000(0000) knlGS:0000000000000000
Jul 20 17:15:06 chimera kernel: [ 3324.556037] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Jul 20 17:15:06 chimera kernel: [ 3324.556037] CR2: ffffffffa1543820 CR3: 00000000b5241000 CR4: 00000000000006e0
Jul 20 17:15:06 chimera kernel: [ 3324.556037] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Jul 20 17:15:06 chimera kernel: [ 3324.556037] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Jul 20 17:15:06 chimera kernel: [ 3324.556037] Process modprobe (pid: 20884, threadinfo ffff8800b5168000, task ffff8800b818b000)
Jul 20 17:15:06 chimera kernel: [ 3324.556037] Stack:
Jul 20 17:15:06 chimera kernel: [ 3324.556037]  ffff8800b5169ed8 ffffffff814932e7 ffff8800b5169ed8 ffffffff814c5248
Jul 20 17:15:06 chimera kernel: [ 3324.556037]  ffff8800b5169eb8 0000000000000000 ffffffffa1908155 0000000000000000
Jul 20 17:15:06 chimera kernel: [ 3324.556037]  000003060ede68d6 0000000000000000 ffff8800b5169ef8 ffffffffa190843f
Jul 20 17:15:06 chimera kernel: [ 3324.556037] Call Trace:
Jul 20 17:15:06 chimera kernel: [ 3324.556037]  [<ffffffff814932e7>] register_netdevice_notifier+0x3b/0x24b
Jul 20 17:15:06 chimera kernel: [ 3324.556037]  [<ffffffff814c5248>] ? genl_register_family_with_ops+0x50/0x9e
Jul 20 17:15:06 chimera kernel: [ 3324.556037]  [<ffffffffa1908155>] ? ip_vs_conn_init+0x155/0x155 [ip_vs]
Jul 20 17:15:06 chimera kernel: [ 3324.556037]  [<ffffffffa190843f>] ip_vs_control_init+0xeb/0x132 [ip_vs]
Jul 20 17:15:06 chimera kernel: [ 3324.556037]  [<ffffffffa1908155>] ? ip_vs_conn_init+0x155/0x155 [ip_vs]
Jul 20 17:15:06 chimera kernel: [ 3324.556037]  [<ffffffffa1908176>] ip_vs_init+0x21/0x1ff [ip_vs]
Jul 20 17:15:06 chimera kernel: [ 3324.556037]  [<ffffffffa1908155>] ? ip_vs_conn_init+0x155/0x155 [ip_vs]
Jul 20 17:15:06 chimera kernel: [ 3324.556037]  [<ffffffff81002094>] do_one_initcall+0x6c/0x1c5
Jul 20 17:15:06 chimera kernel: [ 3324.556037]  [<ffffffff810cd572>] sys_init_module+0xe1/0x2b0
Jul 20 17:15:06 chimera kernel: [ 3324.556037]  [<ffffffff8157da02>] system_call_fastpath+0x16/0x1b
Jul 20 17:15:06 chimera kernel: [ 3324.556037] Code: 89 e5 e8 85 e3 04 00 c9 c3 90 90 90 55 48 89 e5 66 66 66 66 90 48 ff 05 f8 5b 00 01 48 8b 07 eb 1e 48 ff 05 fc 5b 00 01 8b 56 10 <3b> 50 10 7f 14 48 ff 05 e5 5b 00 01 48 8d 78 08 48 8b 40 08 48 
Jul 20 17:15:06 chimera kernel: [ 3324.556037] RIP  [<ffffffff810a8d4f>] raw_notifier_chain_register+0x1f/0x4a
Jul 20 17:15:06 chimera kernel: [ 3324.556037]  RSP <ffff8800b5169e88>
Jul 20 17:15:06 chimera kernel: [ 3324.556037] CR2: ffffffffa1543820
Jul 20 17:15:06 chimera kernel: [ 3324.583800] ---[ end trace 1df4eeece34268d5 ]---



---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
