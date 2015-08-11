From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC PATCH net-next] ipvs: enable the scheduling of icmp
 packets
Date: Tue, 11 Aug 2015 11:25:41 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1508111123400.1680@ja.home.ssi.bg>
References: <1439171610-226215-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1439171610-226215-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Gartrell <agartrell@fb.com>
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, kernel-team@fb.com


	Hello,

	More notes for today:

- ip_vs_in_icmp: lets add a bool flag (local var) if cp was
created from the ip_vs_try_to_schedule call, I prefer if cp
was present to call __ip_vs_conn_put:

	bool old = true;

	...
		if (!ip_vs_try_to_schedule(AF_INET, skb, pd, &v, &cp,
					   &ciph, !ipip))
			return v;
		old = false;
	}

	if (old)
		__ip_vs_conn_put(cp);
	else
		ip_vs_conn_put(cp);

- same for ip_vs_in_icmp_v6, we can use single place where to
call [__]ip_vs_conn_put, now they are 2 places

- ensure_mtu_is_adequate:
	- ipvsh->fragoffs can be for embedded header

- ip_vs_bypass_xmit_v6: uses ipvsh->daddr.in6 but it should use
	struct ipv6hdr *iph = ipv6_hdr(skb);

- we need a new flag in struct ip_vs_iphdr:
	- embedded:
		- we are working with embedded header
		- this is needed by:
			- ensure_mtu_is_adequate to avoid sending
			ICMP error as response to ICMP error
		- schedule path: to avoid many checks for inverse flag

- ip_vs_in_icmp* can call ip_vs_fill_* with new arg 'inverse', so
that the scheduling path see in ipvsh->saddr always the client address.
The SH scheduler can know that addresses and ports are reversed by
checking the embedded flag which implies 'inverse' mode. Then only
ip_vs_sh_get_port should check this flag. Such flag allows schedulers
to refuse to work for embedded packets, for example, if they
schedule by payload.

Regards

--
Julian Anastasov <ja@ssi.bg>
