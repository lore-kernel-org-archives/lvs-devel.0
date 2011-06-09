From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: ipvs netns exit causes crash in conntrack.
Date: Thu, 9 Jun 2011 21:46:34 +0200
Message-ID: <201106092146.35494.hans@schillstrom.com>
References: <201106091457.29205.hans@schillstrom.com> <4DF0C67B.8040300@trash.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <4DF0C67B.8040300@trash.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: Patrick McHardy <kaber@trash.net>
Cc: Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>

On Thursday, June 09, 2011 15:11:23 Patrick McHardy wrote:
> On 09.06.2011 14:57, Hans Schillstrom wrote:
> > Hello 
> > I have a problem with ip_vs_conn_flush() and expiring timers ...
> > After a couple of hours checking locks,  I'm still not closer to a solution
> > Conntrack differs a bit between 2.6.32 vs .2.6.39 but I don't think that's the reason in this case.
> > 
> > I think the netns cleanup cased this, but I'm not a conntrack expert :)
> > 
> > The dump below is from a back-ported ipvs to 2.6.32.27 
> > The extra patches that renamed the cleanup patches is there that I sent to Simon i.e
> > __ip_vs_conn_cleanup renamed to ip_vs_conn_net_cleanup  etc.
> > 
> > 
> > [  532.287410] CPU 3 
> > [  532.287410] Modules linked in: xt_mark xt_conntrack ip_vs_wrr(N) ip_vs_lc(N) xt_tcpudp ip_vs_rr(N) nf_conntrack_ipv6 xt_MARK xt_state xt_CONNMARK xt_connmark xt_multiport nf_conntrack_netlink nfnetlink xt_hmark(N) ip6table_mangle iptable_mangle ip6table_filter iptable_filter ip6_tables ip_tables x_tables nf_conntrack_ipv4 nf_defrag_ipv4 ip_vs(N) nf_conntrack ip6_tunnel tunnel6 tipc(N) nfs fscache af_packet nfsd lockd nfs_acl auth_rpcgss sunrpc exportfs drbd softdog bonding macvlan ipv6 ext3 jbd mbcache loop dm_mod usbhid hid ide_pci_generic piix ide_core ata_generic ata_piix ahci libata hpsa uhci_hcd hpilo xen_platform_pci cdrom pcspkr ehci_hcd cciss tpm_tis tpm tpm_bios bnx2 serio_raw ipmi_si ipmi_msghandler i5k_amb i5000_edac rtc_cmos rtc_core rtc_lib usbcore container e1000e edac
 _core shpchp pci_hotplug scsi_mod button thermal processor thermal_sys hwmon
> > [  532.350212] Supported: Yes
> > [  532.350212] Pid: 17, comm: netns Tainted: G          N  2.6.32.27-0.2.2.2501.1.PTF-evip #1 ProLiant DL380 G5
> > [  532.386359] RIP: 0010:[<ffffffff8131aaf6>]  [<ffffffff8131aaf6>] netlink_has_listeners+0x36/0x40
> > [  532.386359] RSP: 0018:ffff880005ac3bf0  EFLAGS: 00010246
> > [  532.386359] RAX: 0000000000000002 RBX: ffff8800345e2ea8 RCX: ffff880005ac3c98
> > [  532.386359] RDX: ffff88012380d740 RSI: 0000000000000003 RDI: ffff88012819a400
> > [  532.386359] RBP: ffff880005ac3d28 R08: ffffffffa0641ca8 R09: 0000000000000024
> > [  532.386359] R10: 0000000000004000 R11: 0000000000000000 R12: ffff8800345e2ea8
> > [  532.386359] R13: 0000000000000002 R14: 0000000000000004 R15: ffff88012a875fd8
> > [  532.386359] FS:  0000000000000000(0000) GS:ffff880005ac0000(0000) knlGS:0000000000000000
> > [  532.386359] CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
> > [  532.386359] CR2: 00007f6a0ecba000 CR3: 0000000001804000 CR4: 00000000000406e0
> > [  532.386359] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > [  532.386359] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> > [  532.386359] Process netns (pid: 17, threadinfo ffff88012a874000, task ffff88012a872500)
> > [  532.485087] Stack:
> > [  532.485087]  ffffffffa063ff92 ffffffff811e2805 ffff880005ac3c98 00000004811e2805
> > [  532.485087] <0> ffff88011d9bd500 0000000300000000 ffff880005ac3da0 ffffffff8103e402
> > [  532.485087] <0> ffff880005ac3d40 ffff880005ac3cb0 0000000000013700 0000000000000010
> > [  532.485087] Call Trace:
> > [  532.485087]  [<ffffffffa063ff92>] ctnetlink_conntrack_event+0x92/0x730 [nf_conntrack_netlink]
> > [  532.485087]  [<ffffffffa058b274>] death_by_timeout+0xc4/0x190 [nf_conntrack]      ## ct->timeout.function(ct->timeout.data); ##
> > [  532.485087]  [<ffffffffa05c544d>] ip_vs_conn_drop_conntrack+0x13d/0x360 [ip_vs]
> > [  532.485087]  [<ffffffffa05ae30d>] ip_vs_conn_expire+0x12d/0x7d0 [ip_vs]		## expired timer ##
> > [  532.485087]  [<ffffffff81059424>] run_timer_softirq+0x174/0x240
> > [  532.549596]  [<ffffffff810544ef>] __do_softirq+0xbf/0x170
> > [  532.549596]  [<ffffffff810040bc>] call_softirq+0x1c/0x30
> > [  532.549596]  [<ffffffff81005d1d>] do_softirq+0x4d/0x80
> > [  532.549596]  [<ffffffff81054791>] local_bh_enable_ip+0xa1/0xb0			      ## ct_write_unlock_bh(idx); ##
> > [  532.549596]  [<ffffffffa05ac25b>] ip_vs_conn_net_cleanup+0xdb/0x160 [ip_vs]  ## ip_vs_flush in-lined ##
> > [  532.576259]  [<ffffffffa05afae1>] __ip_vs_cleanup+0x11/0x90 [ip_vs]
> > [  532.576259]  [<ffffffff812f840e>] cleanup_net+0x5e/0xb0
> > [  532.576259]  [<ffffffff81061468>] run_workqueue+0xb8/0x140
> > [  532.594226]  [<ffffffff8106158a>] worker_thread+0x9a/0x110
> > [  532.594226]  [<ffffffff81065696>] kthread+0x96/0xb0
> > [  532.603788]  [<ffffffff81003fba>] child_rip+0xa/0x20
> > [  532.603788] Code: 47 41 8d 4e ff 48 8d 14 80 48 8d 14 50 31 c0 48 c1 e2 03 48 03 15 7b b2 9b 00 3b 4a 3c 48 8b 7a 30 72 02 f3 c3 0f a3 0f 19 c0 c3 <0f> 0b eb fe 66 0f 1f 44 00 00 48 81 ec 98 00 00 00 41 f6 c0 01 
> > [  532.623046] RIP  [<ffffffff8131aaf6>] netlink_has_listeners+0x36/0x40
> 
> This looks like nfnetlink.c excited and destroyed the nfnl socket, but
> ip_vs was still holding a reference to a conntrack. When the conntrack
> got destroyed it created a ctnetlink event, causing an oops in
> netlink_has_listeners when trying to use the destroyed nfnetlink
> socket.
> 
> Usually this shouldn't happen since network namespace cleanup
> happens in reverse order from registration. In this case the
> reason might be that IPVS has no dependencies on conntrack
> or ctnetlink and therefore can get loaded first, meaning it
> will get cleaned up afterwards.
> 
> Does that make any sense?
> 
Yes,  
From what I can see is ip_vs have a dependency on nf_conntrack but not on nf_conntrack_netlink
i.e. nf_conntrack is loded first and then ip_vs and last nf_conntrack_netlink

It's hard to tell exactly what was going on in user-space when the lxc container get killed....
Basically there is a lot of traffic (and connections) through the container with ipvs inside,
- ipvs conntrack support is turned on
- iptables with conntrack 
- conntrackd is running 
- ~50 iptables rules
I'm not sure if it's only IPv4 traffic ...

Hmmm... I think I know,  the culprit is conntrackd !! (i.e. it causes loading of ct_netlink)
conntrackd will definitely get killed before the namespace exit starts 
I think it is like you describe, I will make some test tomorrow.
How to solve this is another question....

Thanks a lot Patrick.

Regards
Hans Schillstrom









