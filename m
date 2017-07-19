From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH V3] netfilter: Remove duplicated rcu_read_lock.
Date: Wed, 19 Jul 2017 10:16:29 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1707191013380.2130@ja.home.ssi.bg>
References: <20170719052733.32310-1-ap420073@gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20170719052733.32310-1-ap420073@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Taehee Yoo <ap420073@gmail.com>
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org


	Hello,

On Wed, 19 Jul 2017, Taehee Yoo wrote:

> This patch removes duplicate rcu_read_lock().
> 
> 1. IPVS part
> According to Julian Anastasov's mention, contexts of ipvs are below. [1]
>  - packet RX/TX: does not need locks because packets come from hooks
>  - sync msg RX: backup server uses RCU locks while registering new conns
>  - ip_vs_ctl.c: configuration get/set, RCU locks needed
>  - xt_ipvs.c: It is a NF match
> 
> As result, rcu_read_lock and rcu_read_unlock can be removed from:
>  - ip_vs_core.c: all
>  - ip_vs_ctl.c:
>    - only from ip_vs_has_real_service
>  - ip_vs_ftp.c: all
>  - ip_vs_proto_sctp.c: all
>  - ip_vs_proto_tcp.c: all
>  - ip_vs_proto_udp.c: all
>  - ip_vs_xmit.c: all (contains only packet processing)
> 
> 2. NF part
> There are three types of functions that are guaranteed the rcu_read_lock().
> First, as result, functions are only called by nf_hook().
>  - nf_conntrack_broadcast_help(), pptp_expectfn(), set_expected_rtp_rtcp().
>  - tcpmss_reverse_mtu(), tproxy_laddr4(), tproxy_laddr6().
>  - match_lookup_rt6(), check_hlist(), hashlimit_mt_common().
>  - xt_osf_match_packet().
> Second, functions that caller already held the rcu_read_lock().
>  - destroy_conntrack(), ctnetlink_conntrack_event().
>  - ctnl_timeout_find_get(), nfqnl_nf_hook_drop().
> Third, functions that are mixed with type1 and type2.
> These functions are called by nf_hook() also these are called by
> ordinary functions that already held the rcu_read_lock().
>  - __ctnetlink_glue_build(), ctnetlink_expect_event().
>  - ctnetlink_proto_size().
> 
> Applied files are below.
>  - nf_conntrack_broadcast.c, nf_conntrack_core.c, nf_conntrack_netlink.c.
>  - nf_conntrack_pptp.c, nf_conntrack_sip.c, nfnetlink_cttimeout.c.
>  - nfnetlink_queue.c, xt_TCPMSS.c, xt_TPROXY.c, xt_addrtype.c.
>  - xt_connlimit.c, xt_hashlimit.c, xt_osf.c
> 
> Detailed calltrace can be found here
> http://marc.info/?l=netfilter-devel&m=149667610710350&w=2
> 
> [1] http://marc.info/?l=netfilter-devel&m=149562884514072&w=2
> 
> Signed-off-by: Taehee Yoo <ap420073@gmail.com>

	For IPVS part:

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
> V3:
>  - Change commit message.

Regards

--
Julian Anastasov <ja@ssi.bg>
