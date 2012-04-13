From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] netfilter: ipvs: Verify that IP_VS protocol has been
 registered
Date: Sat, 14 Apr 2012 00:13:22 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1204132335190.12601@ja.ssi.bg>
References: <1333668273-8873-1-git-send-email-levinsasha928@gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1333668273-8873-1-git-send-email-levinsasha928@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sasha Levin <levinsasha928@gmail.com>
Cc: wensong@linux-vs.org, horms@verge.net.au, kaber@trash.net, davem@davemloft.net, davej@redhat.com, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org


	Hello,

On Thu, 5 Apr 2012, Sasha Levin wrote:

> The registration of a protocol might fail, there were no checks
> and all registrations were assumed to be correct. This lead to
> NULL ptr dereferences when apps tried registering.
> 
> For example:
> 
> [ 1293.226051] BUG: unable to handle kernel NULL pointer dereference at 0000000000000018
> [ 1293.227038] IP: [<ffffffff822aacb0>] tcp_register_app+0x60/0xb0
> [ 1293.227038] PGD 391de067 PUD 6c20b067 PMD 0
> [ 1293.227038] Oops: 0000 [#1] PREEMPT SMP
> [ 1293.227038] CPU 1
> [ 1293.227038] Pid: 19609, comm: trinity Tainted: G        W    3.4.0-rc1-next-20120405-sasha-dirty #57
> [ 1293.227038] RIP: 0010:[<ffffffff822aacb0>]  [<ffffffff822aacb0>] tcp_register_app+0x60/0xb0
> [ 1293.227038] RSP: 0018:ffff880038c1dd18  EFLAGS: 00010286
> [ 1293.227038] RAX: ffffffffffffffc0 RBX: 0000000000001500 RCX: 0000000000010000
> [ 1293.227038] RDX: 0000000000000000 RSI: ffff88003a2d5888 RDI: 0000000000000282
> [ 1293.227038] RBP: ffff880038c1dd48 R08: 0000000000000000 R09: 0000000000000000
> [ 1293.227038] R10: 0000000000000000 R11: 0000000000000000 R12: ffff88003a2d5668
> [ 1293.227038] R13: ffff88003a2d5988 R14: ffff8800696a8ff8 R15: 0000000000000000
> [ 1293.227038] FS:  00007f01930d9700(0000) GS:ffff88007ce00000(0000) knlGS:0000000000000000
> [ 1293.227038] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [ 1293.227038] CR2: 0000000000000018 CR3: 0000000065dfc000 CR4: 00000000000406e0
> [ 1293.227038] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [ 1293.227038] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [ 1293.227038] Process trinity (pid: 19609, threadinfo ffff880038c1c000, task ffff88002dc73000)
> [ 1293.227038] Stack:
> [ 1293.227038]  ffff880038c1dd48 00000000fffffff4 ffff8800696aada0 ffff8800694f5580
> [ 1293.227038]  ffffffff8369f1e0 0000000000001500 ffff880038c1dd98 ffffffff822a716b
> [ 1293.227038]  0000000000000000 ffff8800696a8ff8 0000000000000015 ffff8800694f5580
> [ 1293.227038] Call Trace:
> [ 1293.227038]  [<ffffffff822a716b>] ip_vs_app_inc_new+0xdb/0x180
> [ 1293.227038]  [<ffffffff822a7258>] register_ip_vs_app_inc+0x48/0x70
> [ 1293.227038]  [<ffffffff822b2fea>] __ip_vs_ftp_init+0xba/0x140
> [ 1293.227038]  [<ffffffff821c9060>] ops_init+0x80/0x90
> [ 1293.227038]  [<ffffffff821c90cb>] setup_net+0x5b/0xe0
> [ 1293.227038]  [<ffffffff821c9416>] copy_net_ns+0x76/0x100
> [ 1293.227038]  [<ffffffff810dc92b>] create_new_namespaces+0xfb/0x190
> [ 1293.227038]  [<ffffffff810dca21>] unshare_nsproxy_namespaces+0x61/0x80
> [ 1293.227038]  [<ffffffff810afd1f>] sys_unshare+0xff/0x290
> [ 1293.227038]  [<ffffffff8187622e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
> [ 1293.227038]  [<ffffffff82665539>] system_call_fastpath+0x16/0x1b
> [ 1293.227038] Code: 89 c7 e8 34 91 3b 00 89 de 66 c1 ee 04 31 de 83 e6 0f 48 83 c6 22 48 c1 e6 04 4a 8b 14 26 49 8d 34 34 48 8d 42 c0 48 39 d6 74 13 <66> 39 58 58 74 22 48 8b 48 40 48 8d 41 c0 48 39 ce 75 ed 49 8d
> [ 1293.227038] RIP  [<ffffffff822aacb0>] tcp_register_app+0x60/0xb0
> [ 1293.227038]  RSP <ffff880038c1dd18>
> [ 1293.227038] CR2: 0000000000000018
> [ 1293.379284] ---[ end trace 364ab40c7011a009 ]---
> [ 1293.381182] Kernel panic - not syncing: Fatal exception in interrupt
> 
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> ---
>  net/netfilter/ipvs/ip_vs_proto.c |   21 ++++++++++++++++-----
>  1 files changed, 16 insertions(+), 5 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
> index f843a88..43893ba 100644
> --- a/net/netfilter/ipvs/ip_vs_proto.c
> +++ b/net/netfilter/ipvs/ip_vs_proto.c
> @@ -316,20 +316,31 @@ ip_vs_tcpudp_debug_packet(int af, struct ip_vs_protocol *pp,
>   */
>  int __net_init ip_vs_protocol_net_init(struct net *net)
>  {
> +	int ret;
>  #ifdef CONFIG_IP_VS_PROTO_TCP
> -	register_ip_vs_proto_netns(net, &ip_vs_protocol_tcp);
> +	ret = register_ip_vs_proto_netns(net, &ip_vs_protocol_tcp);
> +	if (ret < 0)
> +		return ret;

	Use goto cleanup instead of return ret;

>  #endif
>  #ifdef CONFIG_IP_VS_PROTO_UDP
> -	register_ip_vs_proto_netns(net, &ip_vs_protocol_udp);
> +	ret = register_ip_vs_proto_netns(net, &ip_vs_protocol_udp);
> +	if (ret < 0)
> +		return ret;
>  #endif
>  #ifdef CONFIG_IP_VS_PROTO_SCTP
> -	register_ip_vs_proto_netns(net, &ip_vs_protocol_sctp);
> +	ret = register_ip_vs_proto_netns(net, &ip_vs_protocol_sctp);
> +	if (ret < 0)
> +		return ret;
>  #endif
>  #ifdef CONFIG_IP_VS_PROTO_AH
> -	register_ip_vs_proto_netns(net, &ip_vs_protocol_ah);
> +	ret = register_ip_vs_proto_netns(net, &ip_vs_protocol_ah);
> +	if (ret < 0)
> +		return ret;
>  #endif
>  #ifdef CONFIG_IP_VS_PROTO_ESP
> -	register_ip_vs_proto_netns(net, &ip_vs_protocol_esp);
> +	ret = register_ip_vs_proto_netns(net, &ip_vs_protocol_esp);
> +	if (ret < 0)
> +		return ret;
>  #endif
>  	return 0;

	You have to call ip_vs_protocol_net_cleanup(net) here
because if ip_vs_protocol_net_init fails it is not called.
Your change is not enough.

	To avoid compiler warnings when no protocol is
configured, may be it is better to add all protos in array:

static struct ip_vs_protocol *protos[] = {
#ifdef CONFIG_IP_VS_PROTO_TCP
	&ip_vs_protocol_tcp,
#endif
	...
};

	Then we can loop where needed:

	for (i = 0; i < ARRAY_SIZE(protos); i++) {
		ret = register_ip_vs_proto_netns(net, protos[i]);
		if (ret < 0)
			goto cleanup;
	}
	return 0;

cleanup:
	ip_vs_protocol_net_cleanup(net);
	return ret;

	I rely on you also to change the GFP_ATOMIC in
register_ip_vs_proto_netns. Let me know if you plan
to make these changes or prefer someone else to take care.

Regards

--
Julian Anastasov <ja@ssi.bg>
