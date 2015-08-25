From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next,v2 01/13] ipvs: replace ip_vs_fill_ip4hdr with
 ip_vs_fill_iph_skb_off
Date: Tue, 25 Aug 2015 13:27:41 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1508251322520.4656@ja.home.ssi.bg>
References: <1440459885-1103938-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1440459885-1103938-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Gartrell <agartrell@fb.com>
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, alexgartrell@gmail.com, kernel-team@fb.com


	Hello,

	Comments about v2:

Patch 1:
	This line should not be removed:
-	writable = ciph.len;

	it should be 'offset = ciph.len;'

Patch 2: OK
Patch 3: OK
Patch 4: OK

Patch 5:

	We provide correct ports to ip_vs_sched_persist() but I guess
	it needs to be updated for the address usage just like
	ip_vs_schedule.

Patch 6: OK
Patch 7: OK

Patch 8:
CHECK: Comparison to NULL could be written "!ports"
#45: FILE: net/netfilter/ipvs/ip_vs_sh.c:296:
+               if (unlikely(ports == NULL))

	In the debug message in ip_vs_sh_schedule we can use
	hash_addr instead of &iph->saddr

Patch 9:

	- ip_vs_in_icmp and ip_vs_in_icmp_v6:
		- Now this check is not needed anymore:

		if (unlikely(!cp))
			return NF_ACCEPT;

Patch 10: OK
Patch 11: OK
Patch 12: OK
Patch 13: OK

	Looking at tcp_conn_schedule I see that ip_vs_leave() can be
called. We should add checks in ip_vs_leave(), for example:

	'!ip_vs_iph_icmp(iph)' in:

	if (ipvs->sysctl_cache_bypass && svc->fwmark && unicast) {

	i.e. we should not use the bypass feature for ICMP, there are
	calls to ip_vs_set_state() and cp->packet_xmit() that are
	not allowed for ICMP packets without adding more checks.

	Then the 'if ((svc->port == FTPPORT) && (pptr[1] != FTPPORT))'
	block should be extended to use pptr[0] for ICMP packet.

	Then such check should follow to avoid sending ICMP to ICMP:

	if (ip_vs_iph_icmp(iph))
		return NF_DROP;

	Also, I guess the connections created by ICMP packets use
the cp->state = 0 and cp->timeout = 3*HZ defaults from ip_vs_conn_new,
this should be fine, right?

Regards

--
Julian Anastasov <ja@ssi.bg>
