From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH RFC 00/24] IPVS: Add first IPv6 support to IPVS
Date: Wed, 27 Aug 2008 17:17:15 +1000
Message-ID: <20080827071714.GA30536@verge.net.au>
References: <1219248931-15064-1-git-send-email-juliusv@google.com> <20080821011715.GG19235@verge.net.au> <f4845fc0808210259n2b4bbd41tb0a93c49592a2029@mail.gmail.com> <20080821212948.GB4407@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080821212948.GB4407@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com, Sven Wegener <sven.wegener@stealer.net>

Here is a second round of thoughts after having gone through the whole series.


[PATCH RFC 06/24] IPVS: Add debug macros for v4 and v6 address output

* The #defines in ip_vs_dbg_addr seem a bit aquard.
  Could it be rearanged liks this?

static inline const char *ip_vs_dbg_addr(int af, char *buf, size_t buf_len,
					const union nf_inet_addr *addr,
					int *idx)
{
       int len;
#ifdef CONFIG_IP_VS_IPV6
       if (af == AF_INET6)
	       len = snprintf(&buf[*idx], buf_len - *idx, "[" NIP6_FMT "]",
			      NIP6(addr->in6)) + 1;
       else
#endif
	       len = snprintf(&buf[*idx], buf_len - *idx, NIPQUAD_FMT,
			      NIPQUAD(addr->ip)) + 1;

       *idx += len;
       return &buf[*idx - len];
}

* The comment "/* Only use from within IP_VS_DBG_BUF() macro */"
  should also mention usage inside IP_VS_ERR_BUF()

* If IP_VS_DBG_ADDR() is used more than once inside a single
  IP_VS_DBG_BUF() or IP_VS_ERR_BUF() call, won't ip_vs_dbg_buf
  be set to the value one of the  calls to IP_VS_DBG_ADDR,
  thus overwriting other calls and producing incorrect debugging
  output?

[PATCH RFC 15/24] IPVS: Add support for IPv6 entry output in procfs files

* The netlink-aware ipvsadm code also seems to allow for dotted-quad
  representation of ipv4 addresses in proc. Is that representation used
  or planned to be used?

[PATCH RFC 17/24] IPVS: Make proc/net files output IPv6 entries

* It might be cleaner to do:

#ifdef CONFIG_IP_VS_IPV6
	if (cp->af == AF_INET6)
		seq_printf ...
	else
#endif
		seq_printf ...


General

* You need to reorder and or merge patches such that after each
  patch is applied the code will build and run. It is ok for
  a patch to add code which isn't used until a later patch is applied.

* Where possible please make lines <= 80 columns wide

