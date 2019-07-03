From: Julian Anastasov <ja@ssi.bg>
Subject: Re: linux-next: Tree for Jul 3 (netfilter/ipvs/)
Date: Wed, 3 Jul 2019 21:29:26 +0300 (EEST)
Message-ID: <alpine.LFD.2.21.1907032126220.3226@ja.home.ssi.bg>
References: <20190703214900.45e94ae4@canb.auug.org.au> <406d9741-68ad-f465-1248-64eef05b1350@infradead.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="-1463811672-1070578143-1562178566=:3226"
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <406d9741-68ad-f465-1248-64eef05b1350@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, Linux Next Mailing List <linux-next@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-1070578143-1562178566=:3226
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit


	Hello,

On Wed, 3 Jul 2019, Randy Dunlap wrote:

> On 7/3/19 4:49 AM, Stephen Rothwell wrote:
> > Hi all,
> > 
> > Changes since 20190702:
> > 
> 
> on i386:

	Oh, well. net/gre.h was included by CONFIG_NF_CONNTRACK, so
it is failing when CONFIG_NF_CONNTRACK is not used.

	Pablo, should I post v2 or just a fix?

> 
>   CC      net/netfilter/ipvs/ip_vs_core.o
> ../net/netfilter/ipvs/ip_vs_core.c: In function ‘ipvs_gre_decap’:
> ../net/netfilter/ipvs/ip_vs_core.c:1618:22: error: storage size of ‘_greh’ isn’t known
>   struct gre_base_hdr _greh, *greh;
>                       ^

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-1070578143-1562178566=:3226--
