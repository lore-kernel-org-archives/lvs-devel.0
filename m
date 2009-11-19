From: "Aleksey Chudov" <aleksey.chudov@hq.one.lv>
Subject: LVS and Broadcom Kernel Bug
Date: Fri, 20 Nov 2009 00:10:49 +0200
Message-ID: <9E798AFF8DBFE14F9AE1150D6FC465110105095A@exch1.interakta.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org

Hello!

I have HP ProLiant BL460c G6 servers with Broadcom Corporation NetXtreme
II BCM57711E 10-Gigabit PCIe controller. After enabling Virtual Server
in kernel and placing server to the test environment with just 10Mbit/s
traffic I see a lot of error messages in logs.

I try different kernel versions 2.6.27.39, 2.6.31.2, 2.6.31.6 but every
time I see the same error:

With 2.6.31.x kernel:

Nov 19 23:35:30 bsrvm8-1 kernel: ------------[ cut here ]------------
Nov 19 23:35:30 bsrvm8-1 kernel: WARNING: at net/core/dev.c:1563
skb_gso_segment+0x10f/0x260()
Nov 19 23:35:30 bsrvm8-1 kernel: Hardware name: ProLiant BL460c G6
Nov 19 23:35:30 bsrvm8-1 kernel: bnx2x: caps=(0x198829, 0x0) len=719
data_len=119 ip_summed=1Pid: 0, comm: swapper Tainted: G        W
2.6.31.2-lvs #1
Nov 19 23:35:30 bsrvm8-1 kernel: Call Trace:
Nov 19 23:35:30 bsrvm8-1 kernel:  <IRQ>  [<ffffffff812c1b09>] ?
skb_gso_segment+0x10f/0x260
Nov 19 23:35:30 bsrvm8-1 kernel:  [<ffffffff810352e1>]
warn_slowpath_common+0x72/0x8a
Nov 19 23:35:30 bsrvm8-1 kernel:  [<ffffffff8103536e>]
warn_slowpath_fmt+0x64/0x66
Nov 19 23:35:30 bsrvm8-1 kernel:  [<ffffffff81255c2e>] ?
bnx2x_release_phy_lock+0x28/0x2d
Nov 19 23:35:30 bsrvm8-1 kernel:  [<ffffffff81261e51>] ?
bnx2x_get_drvinfo+0xea/0x121
Nov 19 23:35:30 bsrvm8-1 kernel:  [<ffffffff812c1b09>]
skb_gso_segment+0x10f/0x260
Nov 19 23:35:30 bsrvm8-1 kernel:  [<ffffffff812c1e04>]
dev_hard_start_xmit+0x1aa/0x2bc
Nov 19 23:35:30 bsrvm8-1 kernel:  [<ffffffff812d0126>]
__qdisc_run+0xeb/0x1ef
Nov 19 23:35:30 bsrvm8-1 kernel:  [<ffffffff812c4a08>]
dev_queue_xmit+0x1cd/0x2d9
Nov 19 23:35:30 bsrvm8-1 kernel:  [<ffffffff812e8549>] ?
ip_finish_output+0x0/0x264
Nov 19 23:35:30 bsrvm8-1 kernel:  [<ffffffff812e876d>]
ip_finish_output+0x224/0x264
Nov 19 23:35:30 bsrvm8-1 kernel:  [<ffffffff812e8adb>]
ip_output+0xa9/0xad
Nov 19 23:35:30 bsrvm8-1 kernel:  [<ffffffff812dc676>]
ip_vs_dr_xmit+0x137/0x16f
Nov 19 23:35:30 bsrvm8-1 kernel:  [<ffffffff812d762f>]
ip_vs_in+0x241/0x305
Nov 19 23:35:30 bsrvm8-1 kernel:  [<ffffffff812e2b63>] ?
ip_route_input+0xc84/0xdf3
Nov 19 23:35:30 bsrvm8-1 kernel:  [<ffffffff812d41f3>]
nf_iterate+0x43/0x80
Nov 19 23:35:30 bsrvm8-1 kernel:  [<ffffffff812e4a26>] ?
ip_local_deliver_finish+0x0/0x176
Nov 19 23:35:30 bsrvm8-1 kernel:  [<ffffffff812d4291>]
nf_hook_slow+0x61/0xc3
Nov 19 23:35:30 bsrvm8-1 kernel:  [<ffffffff812e4a26>] ?
ip_local_deliver_finish+0x0/0x176
Nov 19 23:35:30 bsrvm8-1 kernel:  [<ffffffff812e4fe5>]
ip_local_deliver+0x63/0x7e
Nov 19 23:35:30 bsrvm8-1 kernel:  [<ffffffff812e4a0c>]
ip_rcv_finish+0x308/0x322
Nov 19 23:35:30 bsrvm8-1 kernel:  [<ffffffff812e4f4d>]
ip_rcv+0x2bd/0x2f2
Nov 19 23:35:30 bsrvm8-1 kernel:  [<ffffffff812c128e>]
netif_receive_skb+0x253/0x273
Nov 19 23:35:30 bsrvm8-1 kernel:  [<ffffffff81257a5b>]
bnx2x_rx_int+0xbbc/0x1504
Nov 19 23:35:30 bsrvm8-1 kernel:  [<ffffffff8102d223>] ?
enqueue_task_fair+0xcb/0xd8
Nov 19 23:35:30 bsrvm8-1 kernel:  [<ffffffff8117fdc2>] ?
cpumask_next_and+0x2b/0x3d
Nov 19 23:35:30 bsrvm8-1 kernel:  [<ffffffff8102e884>] ?
find_busiest_group+0x22d/0x799
Nov 19 23:35:30 bsrvm8-1 kernel:  [<ffffffff81265d17>]
bnx2x_poll+0xd3/0x1bf
Nov 19 23:35:30 bsrvm8-1 kernel:  [<ffffffff81030ac1>] ?
run_rebalance_domains+0x183/0x481
Nov 19 23:35:30 bsrvm8-1 kernel:  [<ffffffff812c3f10>]
net_rx_action+0x8b/0x146
Nov 19 23:35:30 bsrvm8-1 kernel:  [<ffffffff81266d56>] ?
bnx2x_msix_fp_int+0x139/0x14b
Nov 19 23:35:30 bsrvm8-1 kernel:  [<ffffffff81039abf>]
__do_softirq+0xa2/0x13d
Nov 19 23:35:30 bsrvm8-1 kernel:  [<ffffffff8100bfec>]
call_softirq+0x1c/0x28
Nov 19 23:35:30 bsrvm8-1 kernel:  [<ffffffff8100dba8>]
do_softirq+0x42/0x88
Nov 19 23:35:30 bsrvm8-1 kernel:  [<ffffffff81039a1b>]
irq_exit+0x3f/0x41
Nov 19 23:35:30 bsrvm8-1 kernel:  [<ffffffff8100d227>] do_IRQ+0xa3/0xba
Nov 19 23:35:30 bsrvm8-1 kernel:  [<ffffffff8100b813>]
ret_from_intr+0x0/0x11
Nov 19 23:35:30 bsrvm8-1 kernel:  <EOI>  [<ffffffff810122aa>] ?
mwait_idle+0x67/0x72
Nov 19 23:35:30 bsrvm8-1 kernel:  [<ffffffff81009bde>] ?
enter_idle+0x20/0x22
Nov 19 23:35:30 bsrvm8-1 kernel:  [<ffffffff81009f6d>] ?
cpu_idle+0x4e/0x6c
Nov 19 23:35:30 bsrvm8-1 kernel:  [<ffffffff81338fb1>] ?
start_secondary+0x1a8/0x1ac
Nov 19 23:35:30 bsrvm8-1 kernel: ---[ end trace 5563ae7e045b479e ]---

With 2.6.27.39 kernel:

Nov 19 22:09:11 bsrvm7-1 kernel: ------------[ cut here ]------------
Nov 19 22:09:11 bsrvm7-1 kernel: WARNING: at net/core/dev.c:1505
skb_gso_segment+0x88/0x1ae()
Nov 19 22:09:11 bsrvm7-1 kernel: Pid: 0, comm: swapper Tainted: G
W 2.6.27.39-lvs #1
Nov 19 22:09:11 bsrvm7-1 kernel: 
Nov 19 22:09:11 bsrvm7-1 kernel: Call Trace:
Nov 19 22:09:11 bsrvm7-1 kernel:  <IRQ>  [<ffffffff8022f518>]
warn_on_slowpath+0x4c/0x72
Nov 19 22:09:11 bsrvm7-1 kernel:  [<ffffffff8022974b>]
__enqueue_rt_entity+0xe6/0x15a
Nov 19 22:09:11 bsrvm7-1 kernel:  [<ffffffff8036eb45>]
swiotlb_map_single_attrs+0x32/0xa7
Nov 19 22:09:11 bsrvm7-1 kernel:  [<ffffffff8021ef80>]
swiotlb_map_single_phys+0x0/0x14
Nov 19 22:09:11 bsrvm7-1 kernel:  [<ffffffff803551e7>]
elv_next_request+0x183/0x193
Nov 19 22:09:11 bsrvm7-1 kernel:  [<ffffffff80226c96>]
activate_task+0x28/0x30
Nov 19 22:09:11 bsrvm7-1 kernel:  [<ffffffff80227970>]
resched_task+0x2d/0x74
Nov 19 22:09:11 bsrvm7-1 kernel:  [<ffffffff803d5aa9>]
do_cciss_request+0x415/0x427
Nov 19 22:09:11 bsrvm7-1 kernel:  [<ffffffff804722cb>]
skb_gso_segment+0x88/0x1ae
Nov 19 22:09:11 bsrvm7-1 kernel:  [<ffffffff80472571>]
dev_hard_start_xmit+0x180/0x23a
Nov 19 22:09:11 bsrvm7-1 kernel:  [<ffffffff8047f733>]
__qdisc_run+0xb5/0x1c1
Nov 19 22:09:11 bsrvm7-1 kernel:  [<ffffffff80474a55>]
dev_queue_xmit+0x303/0x416
Nov 19 22:09:11 bsrvm7-1 kernel:  [<ffffffff804b8241>]
ip_vs_dr_xmit+0x118/0x14e
Nov 19 22:09:11 bsrvm7-1 kernel:  [<ffffffff804b4805>]
ip_vs_in+0x1e1/0x289
Nov 19 22:09:11 bsrvm7-1 kernel:  [<ffffffff8048386d>]
nf_iterate+0x41/0x7d
Nov 19 22:09:11 bsrvm7-1 kernel:  [<ffffffff80488aca>]
ip_local_deliver_finish+0x0/0x16a
Nov 19 22:09:11 bsrvm7-1 kernel:  [<ffffffff80483906>]
nf_hook_slow+0x5d/0xbe
Nov 19 22:09:11 bsrvm7-1 kernel:  [<ffffffff80488aca>]
ip_local_deliver_finish+0x0/0x16a
Nov 19 22:09:11 bsrvm7-1 kernel:  [<ffffffff80488ff2>]
ip_local_deliver+0x5f/0x79
Nov 19 22:09:11 bsrvm7-1 kernel:  [<ffffffff80488ab0>]
ip_rcv_finish+0x2d4/0x2ee
Nov 19 22:09:11 bsrvm7-1 kernel:  [<ffffffff8046d787>]
__alloc_skb+0x71/0x11c
Nov 19 22:09:11 bsrvm7-1 kernel:  [<ffffffff804077d3>]
bnx2x_rx_int+0xb62/0x145f
Nov 19 22:09:11 bsrvm7-1 kernel:  [<ffffffff80226df0>]
source_load+0x2a/0x4f
Nov 19 22:09:11 bsrvm7-1 kernel:  [<ffffffff8041134e>]
bnx2x_poll+0xd3/0x211
Nov 19 22:09:11 bsrvm7-1 kernel:  [<ffffffff804dcd86>]
_spin_lock_irq+0xd/0xf
Nov 19 22:09:11 bsrvm7-1 kernel:  [<ffffffff80473f27>]
net_rx_action+0x77/0x147
Nov 19 22:09:11 bsrvm7-1 kernel:  [<ffffffff8023382a>]
__do_softirq+0x65/0xdb
Nov 19 22:09:11 bsrvm7-1 kernel:  [<ffffffff8020cbcc>]
call_softirq+0x1c/0x28
Nov 19 22:09:11 bsrvm7-1 kernel:  [<ffffffff8020eb90>]
do_softirq+0x3c/0x81
Nov 19 22:09:11 bsrvm7-1 kernel:  [<ffffffff8020ecba>] do_IRQ+0xb9/0xd7
Nov 19 22:09:11 bsrvm7-1 kernel:  [<ffffffff8020b95e>]
ret_from_intr+0x0/0x29
Nov 19 22:09:11 bsrvm7-1 kernel:  <EOI>  [<ffffffff80212404>]
mwait_idle+0x41/0x4d
Nov 19 22:09:11 bsrvm7-1 kernel:  [<ffffffff8020a05e>]
cpu_idle+0x45/0x63
Nov 19 22:09:11 bsrvm7-1 kernel: 
Nov 19 22:09:11 bsrvm7-1 kernel: ---[ end trace 64c43c810c59d16c ]---

Regards, Aleksey
