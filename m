From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC PATCH net-next] ipvs: add missing lock in
 ip_vs_ftp_init_conn()
Date: Fri, 29 Jun 2012 12:04:55 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1206291125270.1690@ja.ssi.bg>
References: <1340890587-8169-1-git-send-email-xtfeng@gmail.com> <alpine.LFD.2.00.1206290225490.1722@ja.ssi.bg> <CAJn8CcFy=K+Aizpi0pvnpXCOYXhgyq12oBgVaPvMthW_fwn4Pg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811672-1915040808-1340960702=:1690"
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <CAJn8CcFy=K+Aizpi0pvnpXCOYXhgyq12oBgVaPvMthW_fwn4Pg@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: Xiaotian Feng <xtfeng@gmail.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org, Xiaotian Feng <dannyfeng@tencent.com>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-1915040808-1340960702=:1690
Content-Type: TEXT/PLAIN; charset="utf-8"
Content-Transfer-Encoding: 8bit


	Hello,

On Fri, 29 Jun 2012, Xiaotian Feng wrote:

> > On Thu, 28 Jun 2012, Xiaotian Feng wrote:
> >
> >> We met a kernel panic in 2.6.32.43 kernel:
> >>
> >> [2680191.848044] IPVS: ip_vs_conn_hash(): request for already hashed, called from run_timer_softirq+0x175/0x1d0
> >> <snip>
> >> [2680311.849009] general protection fault: 0000 [#1] SMP

	What we see here is 120 seconds between 2680191 and
2680311. It can mean 2 things:

- some state timeout, it depends on your forwarding method.
What is it? NAT? DR?

- 60 seconds for ip_vs_conn_expire retries

> >> After code review, the only chance that kernel change connection flag without protection is
> >> in ip_vs_ftp_init_conn().
> >
> >        Hm, ip_vs_ftp_init_conn is called before 1st hashing,
> > from ip_vs_bind_app() in ip_vs_conn_new() before
> > ip_vs_conn_hash(). It should be another problem with
> > the flags. How different is IPVS in 2.6.32.43 compared to
> > recent kernels? If commit aea9d711 is present, I'm not
> > aware of other similar problems.
> 
> ip_vs_bind_app() is also called by ip_vs_try_bind_dest(), which can be
> traced to ip_vs_proc_conn().
> I've checked the changes in upstream, but nothing helps since aea9d711
> has been taken into 2.6.32.28 kernel.

	OK, this fix should make it safe for master-backup
sync and it should be applied but I suspect you are not
using sync, right? And then this fix will not solve the oops.

	There are no many places that rehash conn:

ip_vs_conn_fill_cport
	- used for FTP

ip_vs_check_template:
	- do you have persistence configured?

	After you provide details for the used forwarding
method, persistence and sync we should think how such races
with rehashing can lead to double hlist_del. May be
you can modify the debug message in ip_vs_conn_hash, so
that we can see cp->flags and ntohs of cp->cport, cp->dport
and cp->vport when oops happens again.

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-1915040808-1340960702=:1690--
