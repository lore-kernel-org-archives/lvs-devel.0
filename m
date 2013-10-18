From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC net-next] ipv6: Use destination address determined by IPVS
Date: Fri, 18 Oct 2013 04:10:08 +0200
Message-ID: <20131018021008.GH18135@order.stressinduktion.org>
References: <1381881751-6719-1-git-send-email-horms@verge.net.au> <alpine.LFD.2.03.1310180153250.4554@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.03.1310180153250.4554@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?= <yoshfuji@linux-ipv6.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Mark Brooks <mark@loadbalancer.org>, Phil Oester <kernel@linuxace.com>

On Fri, Oct 18, 2013 at 02:03:27AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> 	Here is a solution that should work not only for IPVS.
> If the change looks correct I'll send it in a separate message.
> 
> [PATCH net] ipv6: always prefer rt6i_gateway if present
> 
> From: Julian Anastasov <ja@ssi.bg>
> 
> In v3.9 6fd6ce2056de2709 ("ipv6: Do not depend on rt->n in
> ip6_finish_output2()." changed the behaviour of ip6_finish_output2()
> such that the recently introduced rt6_nexthop() is used
> instead of an assigned neighbor.
> 
> As rt6_nexthop() prefers rt6i_gateway only for gatewayed
> routes this causes a problem for users like IPVS, xt_TEE and
> RAW(hdrincl) if they want to use different address for routing
> compared to the destination address.
> 
> Fix it by considering the rt6i_gateway address in all
> cases, so that traffic routed to address on local subnet is
> not wrongly diverted to the destination address.
> 
> Thanks to Simon Horman and Phil Oester for spotting the
> problematic commit.

I played around with your patch and tested xt_TEE. I added a TEE rule to
mangle/OUTPUT and pinged. This happend, I have not yet analyzed it:

[  101.126649] ------------[ cut here ]------------
[  101.128436] BUG: unable to handle kernel paging request at fffffffb8a2fda88
[  101.129421] IP: [<ffffffff810c9737>] cpuacct_charge+0x97/0x200
[  101.129421] PGD 1c0f067 PUD 0
[  101.129421] Thread overran stack, or stack corrupted
[  101.129421] Oops: 0000 [#1] SMP
[  101.129421] Modules linked in: xt_TEE nf_conntrack_netbios_ns nf_conntrack_broadcast ipt_MASQUERADE ip6table_nat nf_nat_ipv6 ip6table_mangle ip6table_security ip6table_raw ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 iptable_nat nf_nat_ipv4 nf_nat iptable_mangle iptable_security iptable_raw nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_filter ebtables ip6table_filter ip6_tables joydev serio_raw virtio_balloon i2c_piix4 i2c_core nfsd auth_rpcgss nfs_acl lockd sunrpc virtio_blk virtio_net ata_generic pata_acpi
[  101.129421] CPU: 1 PID: 1190 Comm: ping6 Not tainted 3.12.0-rc3+ #2
[  101.129421] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[  101.129421] task: ffff8800c30a4590 ti: ffff8801193ce000 task.ti: ffff8801193ce000
[  101.129421] RIP: 0010:[<ffffffff810c9737>]  [<ffffffff810c9737>] cpuacct_charge+0x97/0x200
[  101.129421] RSP: 0018:ffff88011b403d60  EFLAGS: 00010002
[  101.129421] RAX: 000000000000e5d8 RBX: 0000000000244314 RCX: ffffffff810b87bd
[  101.129421] RDX: ffffffff81c4dce0 RSI: ffffffff81c47e00 RDI: 0000000000000046
[  101.129421] RBP: ffff88011b403d88 R08: ffff8800c30a5308 R09: 0000000000000001
[  101.129421] R10: 0000000000000001 R11: 0000000000000001 R12: ffff8800c30a4590
[  101.129421] R13: 00000000810b87bd R14: ffff880117d5b450 R15: 0000000000000000
[  101.129421] FS:  00007f79260bc740(0000) GS:ffff88011b400000(0000) knlGS:0000000000000000
[  101.129421] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  101.129421] CR2: fffffffb8a2fda88 CR3: 0000000117e40000 CR4: 00000000000006e0
[  101.129421] Stack:
[  101.129421]  ffffffff810c96a5 ffff8800c30a45f8 ffff8800c8d1da40 ffff8800c30a4590
[  101.129421]  0000000000244314 ffff88011b403dc8 ffffffff810bce9c 000000003264e993
[  101.129421]  ffff8800c30a45f8 0000000000000001 ffff8800c8d1da40 ffff88011b5d5240
[  101.129421] Call Trace:
[  101.129421]  <IRQ>
[  101.129421]  [<ffffffff810c96a5>] ? cpuacct_charge+0x5/0x200
[  101.129421]  [<ffffffff810bce9c>] update_curr+0xcc/0x210
[  101.129421]  [<ffffffff810beb19>] task_tick_fair+0x2b9/0x680
[  101.129421]  [<ffffffff810b8948>] ? sched_clock_cpu+0xa8/0x100
[  101.129421]  [<ffffffff810b3564>] scheduler_tick+0x64/0xe0
[  101.129421]  [<ffffffff810866a6>] update_process_times+0x66/0x80
[  101.129421]  [<ffffffff810e7a15>] tick_sched_handle.isra.15+0x25/0x60
[  101.129421]  [<ffffffff810e7a91>] tick_sched_timer+0x41/0x60
[  101.129421]  [<ffffffff810a5146>] __run_hrtimer+0x86/0x490
[  101.129421]  [<ffffffff810e7a50>] ? tick_sched_handle.isra.15+0x60/0x60
[  101.129421]  [<ffffffff810a5fc7>] hrtimer_interrupt+0xf7/0x240
[  101.129421]  [<ffffffff8104a877>] local_apic_timer_interrupt+0x37/0x60
[  101.129421]  [<ffffffff8173dcbf>] smp_apic_timer_interrupt+0x3f/0x60
[  101.129421]  [<ffffffff8173c6b2>] apic_timer_interrupt+0x72/0x80
[  101.129421]  <EOI>
[  101.129421]  [<ffffffff810d5bdd>] ? vprintk_emit+0x1dd/0x5e0
[  101.129421]  [<ffffffff8107afe4>] ? __local_bh_disable+0x94/0xa0
[  101.129421]  [<ffffffff81723dbf>] printk+0x67/0x69
[  101.129421]  [<ffffffff810ed07c>] ? trace_hardirqs_on_caller+0xac/0x1c0
[  101.129421]  [<ffffffff8107afe4>] ? __local_bh_disable+0x94/0xa0
[  101.129421]  [<ffffffff81075394>] warn_slowpath_common+0x34/0xa0
[  101.129421]  [<ffffffff81600309>] ? dst_alloc+0x139/0x170
[  101.129421]  [<ffffffff810754ba>] warn_slowpath_null+0x1a/0x20
[  101.129421]  [<ffffffff8107afe4>] __local_bh_disable+0x94/0xa0
[  101.129421]  [<ffffffff8107b007>] local_bh_disable+0x17/0x20
[  101.129421]  [<ffffffff81600309>] dst_alloc+0x139/0x170
[  101.129421]  [<ffffffff816d4e47>] icmp6_dst_alloc+0xf7/0x430
[  101.129421]  [<ffffffff816d4d55>] ? icmp6_dst_alloc+0x5/0x430
[  101.129421]  [<ffffffff816dde26>] ndisc_send_skb+0x3e6/0x540
[  101.129421]  [<ffffffff816df81c>] ndisc_send_ns+0xdc/0x140
[  101.129421]  [<ffffffff816d394b>] rt6_probe+0x31b/0x380
[  101.129421]  [<ffffffff816d3690>] ? rt6_probe+0x60/0x380
[  101.129421]  [<ffffffff816d1b93>] ? rt6_score_route+0xa3/0x380
[  101.129421]  [<ffffffff816d471c>] ip6_pol_route.isra.47+0x2fc/0x4f0
[  101.129421]  [<ffffffff816d4940>] ? ip6_pol_route_input+0x30/0x30
[  101.129421]  [<ffffffff816d496a>] ip6_pol_route_output+0x2a/0x30
[  101.129421]  [<ffffffff8170516e>] fib6_rule_action+0xbe/0x200
[  101.129421]  [<ffffffff810ea057>] ? __lock_is_held+0x57/0x80
[  101.129421]  [<ffffffff816142e5>] fib_rules_lookup+0x145/0x390
[  101.129421]  [<ffffffff816141a5>] ? fib_rules_lookup+0x5/0x390
[  101.129421]  [<ffffffff81705464>] fib6_rule_lookup+0x44/0x80
[  101.129421]  [<ffffffff816d4940>] ? ip6_pol_route_input+0x30/0x30
[  101.129421]  [<ffffffff816d1263>] ip6_route_output+0x73/0xb0
[  101.129421]  [<ffffffffa01df54f>] tee_tg6+0x15f/0x228 [xt_TEE]
[  101.129421]  [<ffffffffa012413f>] ip6t_do_table+0x26f/0x435 [ip6_tables]
[  101.129421]  [<ffffffff8107b09a>] ? local_bh_enable+0x8a/0xf0
[  101.129421]  [<ffffffff816dd6e0>] ? ndisc_alloc_skb+0x110/0x110
[  101.129421]  [<ffffffffa01c10e8>] ip6table_mangle_hook+0xe8/0x170 [ip6table_mangle]
[  101.129421]  [<ffffffff810ea057>] ? __lock_is_held+0x57/0x80
[  101.129421]  [<ffffffff816dd6e0>] ? ndisc_alloc_skb+0x110/0x110
[  101.129421]  [<ffffffff8162ab5a>] nf_iterate+0xca/0x180
[  101.129421]  [<ffffffff816dd6e0>] ? ndisc_alloc_skb+0x110/0x110
[  101.129421]  [<ffffffff8162acf4>] nf_hook_slow+0xe4/0x290
[  101.129421]  [<ffffffff816dd6e0>] ? ndisc_alloc_skb+0x110/0x110
[  101.129421]  [<ffffffff816dddb2>] ndisc_send_skb+0x372/0x540
[  101.129421]  [<ffffffff816df81c>] ndisc_send_ns+0xdc/0x140
[  101.129421]  [<ffffffff816d394b>] rt6_probe+0x31b/0x380
[  101.129421]  [<ffffffff816d3690>] ? rt6_probe+0x60/0x380
[  101.129421]  [<ffffffff816d1b93>] ? rt6_score_route+0xa3/0x380
[  101.129421]  [<ffffffff816d471c>] ip6_pol_route.isra.47+0x2fc/0x4f0
[  101.129421]  [<ffffffff816d4940>] ? ip6_pol_route_input+0x30/0x30
[  101.129421]  [<ffffffff816d496a>] ip6_pol_route_output+0x2a/0x30
[  101.129421]  [<ffffffff8170516e>] fib6_rule_action+0xbe/0x200
[  101.129421]  [<ffffffff810ea057>] ? __lock_is_held+0x57/0x80
[  101.129421]  [<ffffffff816142e5>] fib_rules_lookup+0x145/0x390
[  101.129421]  [<ffffffff816141a5>] ? fib_rules_lookup+0x5/0x390
[  101.129421]  [<ffffffff81705464>] fib6_rule_lookup+0x44/0x80
[  101.129421]  [<ffffffff816d4940>] ? ip6_pol_route_input+0x30/0x30
[  101.129421]  [<ffffffff816d1263>] ip6_route_output+0x73/0xb0
[  101.129421]  [<ffffffffa01df54f>] tee_tg6+0x15f/0x228 [xt_TEE]
[  101.129421]  [<ffffffffa012413f>] ip6t_do_table+0x26f/0x435 [ip6_tables]
[  101.129421]  [<ffffffff8107b09a>] ? local_bh_enable+0x8a/0xf0
[  101.129421]  [<ffffffff816dd6e0>] ? ndisc_alloc_skb+0x110/0x110
[  101.129421]  [<ffffffffa01c10e8>] ip6table_mangle_hook+0xe8/0x170 [ip6table_mangle]
[  101.129421]  [<ffffffff810ea057>] ? __lock_is_held+0x57/0x80
[  101.129421]  [<ffffffff816dd6e0>] ? ndisc_alloc_skb+0x110/0x110
[  101.129421]  [<ffffffff8162ab5a>] nf_iterate+0xca/0x180
[  101.129421]  [<ffffffff816dd6e0>] ? ndisc_alloc_skb+0x110/0x110
[  101.129421]  [<ffffffff8162acf4>] nf_hook_slow+0xe4/0x290
[  101.129421]  [<ffffffff816dd6e0>] ? ndisc_alloc_skb+0x110/0x110
[  101.129421]  [<ffffffff816dddb2>] ndisc_send_skb+0x372/0x540
[  101.129421]  [<ffffffff816df81c>] ndisc_send_ns+0xdc/0x140
[  101.129421]  [<ffffffff816d394b>] rt6_probe+0x31b/0x380
[  101.129421]  [<ffffffff816d3690>] ? rt6_probe+0x60/0x380
[  101.129421]  [<ffffffff816d1b93>] ? rt6_score_route+0xa3/0x380
[  101.129421]  [<ffffffff816d471c>] ip6_pol_route.isra.47+0x2fc/0x4f0
[  101.129421]  [<ffffffff816d4940>] ? ip6_pol_route_input+0x30/0x30
[  101.129421]  [<ffffffff816d496a>] ip6_pol_route_output+0x2a/0x30
[  101.129421]  [<ffffffff8170516e>] fib6_rule_action+0xbe/0x200
[  101.129421]  [<ffffffff810ea057>] ? __lock_is_held+0x57/0x80
[  101.129421]  [<ffffffff816142e5>] fib_rules_lookup+0x145/0x390
[  101.129421]  [<ffffffff816141a5>] ? fib_rules_lookup+0x5/0x390
[  101.129421]  [<ffffffff81705464>] fib6_rule_lookup+0x44/0x80
[  101.129421]  [<ffffffff816d4940>] ? ip6_pol_route_input+0x30/0x30
[  101.129421]  [<ffffffff816d1263>] ip6_route_output+0x73/0xb0
[  101.129421]  [<ffffffffa01df54f>] tee_tg6+0x15f/0x228 [xt_TEE]
[  101.129421]  [<ffffffffa012413f>] ip6t_do_table+0x26f/0x435 [ip6_tables]
[  101.129421]  [<ffffffff8107b09a>] ? local_bh_enable+0x8a/0xf0
[  101.129421]  [<ffffffff816dd6e0>] ? ndisc_alloc_skb+0x110/0x110
[  101.129421]  [<ffffffffa01c10e8>] ip6table_mangle_hook+0xe8/0x170 [ip6table_mangle]
[  101.129421]  [<ffffffff810ea057>] ? __lock_is_held+0x57/0x80
[  101.129421]  [<ffffffff816dd6e0>] ? ndisc_alloc_skb+0x110/0x110
[  101.129421]  [<ffffffff8162ab5a>] nf_iterate+0xca/0x180
[  101.129421]  [<ffffffff816dd6e0>] ? ndisc_alloc_skb+0x110/0x110
[  101.129421]  [<ffffffff8162acf4>] nf_hook_slow+0xe4/0x290
[  101.129421]  [<ffffffff816dd6e0>] ? ndisc_alloc_skb+0x110/0x110
[  101.129421]  [<ffffffff816dddb2>] ndisc_send_skb+0x372/0x540
[  101.129421]  [<ffffffff816df81c>] ndisc_send_ns+0xdc/0x140
[  101.129421]  [<ffffffff816d394b>] rt6_probe+0x31b/0x380
[  101.129421]  [<ffffffff816d3690>] ? rt6_probe+0x60/0x380
[  101.129421]  [<ffffffff816d1b93>] ? rt6_score_route+0xa3/0x380
[  101.129421]  [<ffffffff816d471c>] ip6_pol_route.isra.47+0x2fc/0x4f0
[  101.129421]  [<ffffffff816d4940>] ? ip6_pol_route_input+0x30/0x30
[  101.129421]  [<ffffffff816d496a>] ip6_pol_route_output+0x2a/0x30
[  101.129421]  [<ffffffff8170516e>] fib6_rule_action+0xbe/0x200
[  101.129421]  [<ffffffff810ea057>] ? __lock_is_held+0x57/0x80
[  101.129421]  [<ffffffff816142e5>] fib_rules_lookup+0x145/0x390
[  101.129421]  [<ffffffff816141a5>] ? fib_rules_lookup+0x5/0x390
[  101.129421]  [<ffffffff81705464>] fib6_rule_lookup+0x44/0x80
[  101.129421]  [<ffffffff816d4940>] ? ip6_pol_route_input+0x30/0x30
[  101.129421]  [<ffffffff816d1263>] ip6_route_output+0x73/0xb0
[  101.129421]  [<ffffffffa01df54f>] tee_tg6+0x15f/0x228 [xt_TEE]
[  101.129421]  [<ffffffffa012413f>] ip6t_do_table+0x26f/0x435 [ip6_tables]
[  101.129421]  [<ffffffff8107b09a>] ? local_bh_enable+0x8a/0xf0
[  101.129421]  [<ffffffff816dd6e0>] ? ndisc_alloc_skb+0x110/0x110
[  101.129421]  [<ffffffffa01c10e8>] ip6table_mangle_hook+0xe8/0x170 [ip6table_mangle]
[  101.129421]  [<ffffffff810ea057>] ? __lock_is_held+0x57/0x80
[  101.129421]  [<ffffffff816dd6e0>] ? ndisc_alloc_skb+0x110/0x110
[  101.129421]  [<ffffffff8162ab5a>] nf_iterate+0xca/0x180
[  101.129421]  [<ffffffff816dd6e0>] ? ndisc_alloc_skb+0x110/0x110
[  101.129421]  [<ffffffff8162acf4>] nf_hook_slow+0xe4/0x290
[  101.129421]  [<ffffffff816dd6e0>] ? ndisc_alloc_skb+0x110/0x110
[  101.129421]  [<ffffffff816dddb2>] ndisc_send_skb+0x372/0x540
[  101.129421]  [<ffffffff816df81c>] ndisc_send_ns+0xdc/0x140
[  101.129421]  [<ffffffff816d394b>] rt6_probe+0x31b/0x380
[  101.129421]  [<ffffffff816d3690>] ? rt6_probe+0x60/0x380
[  101.129421]  [<ffffffff816d1b93>] ? rt6_score_route+0xa3/0x380
[  101.129421]  [<ffffffff816d471c>] ip6_pol_route.isra.47+0x2fc/0x4f0
[  101.129421]  [<ffffffff816d4940>] ? ip6_pol_route_input+0x30/0x30
[  101.129421]  [<ffffffff816d496a>] ip6_pol_route_output+0x2a/0x30
[  101.129421]  [<ffffffff8170516e>] fib6_rule_action+0xbe/0x200
[  101.129421]  [<ffffffff810ea057>] ? __lock_is_held+0x57/0x80
[  101.129421]  [<ffffffff816142e5>] fib_rules_lookup+0x145/0x390
[  101.129421]  [<ffffffff816141a5>] ? fib_rules_lookup+0x5/0x390
[  101.129421]  [<ffffffff81705464>] fib6_rule_lookup+0x44/0x80
[  101.129421]  [<ffffffff816d4940>] ? ip6_pol_route_input+0x30/0x30
[  101.129421]  [<ffffffff816d1263>] ip6_route_output+0x73/0xb0
[  101.129421]  [<ffffffff816bfd13>] ip6_dst_lookup_tail+0x373/0x4a0
[  101.129421]  [<ffffffff8105768f>] ? kvm_clock_read+0x2f/0x50
[  101.129421]  [<ffffffff81021b89>] ? sched_clock+0x9/0x10
[  101.129421]  [<ffffffff810b87bd>] ? sched_clock_local+0x1d/0x80
[  101.129421]  [<ffffffff816bfe93>] ip6_dst_lookup_flow+0x33/0x90
[  101.129421]  [<ffffffff816f94bd>] ip6_datagram_connect+0x16d/0x510
[  101.129421]  [<ffffffff810ed0cd>] ? trace_hardirqs_on_caller+0xfd/0x1c0
[  101.129421]  [<ffffffff810ed19d>] ? trace_hardirqs_on+0xd/0x10
[  101.129421]  [<ffffffff81678dde>] inet_dgram_connect+0x2e/0x80
[  101.129421]  [<ffffffff815da25a>] SYSC_connect+0xea/0x130
[  101.129421]  [<ffffffff81732818>] ? retint_swapgs+0x13/0x1b
[  101.129421]  [<ffffffff810ed0cd>] ? trace_hardirqs_on_caller+0xfd/0x1c0
[  101.129421]  [<ffffffff8137b67e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  101.129421]  [<ffffffff815db75e>] SyS_connect+0xe/0x10
[  101.129421]  [<ffffffff8173ba29>] system_call_fastpath+0x16/0x1b
[  101.129421] Code: 00 00 4d 8b b4 24 e0 13 00 00 e8 e5 3d fd ff 85 c0 74 09 80 3d d0 4a c5 00 00 74 78 49 8b 56 48 49 63 cd 90 48 8b 82 b8 00 00 00 <48> 03 04 cd a0 9c d3 81 48 01 18 48 8b 52 40 48 85 d2 75 e5 e8
[  101.129421] RIP  [<ffffffff810c9737>] cpuacct_charge+0x97/0x200
[  101.129421]  RSP <ffff88011b403d60>
[  101.129421] CR2: fffffffb8a2fda88
[  101.129421] ---[ end trace 68ce790414632b74 ]---
[  101.129421] Kernel panic - not syncing: Fatal exception in interrupt



