From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 19/26] net/ipv6: switch ipv6_flowlabel_opt to sockptr_t
Date: Mon, 27 Jul 2020 13:24:45 +0000
Message-ID: <8c747034a5b641d18734de5f4d3a7507@AcuMS.aculab.com>
References: <20200723060908.50081-1-hch@lst.de>
 <20200723060908.50081-20-hch@lst.de> <20200727121505.GA1804864@shredder>
Mime-Version: 1.0
Content-Transfer-Encoding: 8BIT
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20200727121505.GA1804864@shredder>
Content-Language: en-US
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: 'Ido Schimmel' <idosch@idosch.org>, Christoph Hellwig <hch@lst.de>
Cc: "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Eric Dumazet <edumazet@google.com>, "linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "bpf@vger.kernel.org" <bpf@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, "coreteam@netfilter.org" <coreteam@netfilter.org>, "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>, "linux-hams@vger.kernel.org" <linux-hams@vger.kernel.org>, "linux-bluetooth@vger.kernel.org" <linux-b>

From: Ido Schimmel
> Sent: 27 July 2020 13:15
> On Thu, Jul 23, 2020 at 08:09:01AM +0200, Christoph Hellwig wrote:
> > Pass a sockptr_t to prepare for set_fs-less handling of the kernel
> > pointer from bpf-cgroup.
> >
> > Note that the get case is pretty weird in that it actually copies data
> > back to userspace from setsockopt.
> >
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > ---
> >  include/net/ipv6.h       |  2 +-
> >  net/ipv6/ip6_flowlabel.c | 16 +++++++++-------
> >  net/ipv6/ipv6_sockglue.c |  2 +-
> >  3 files changed, 11 insertions(+), 9 deletions(-)
> >
> > diff --git a/include/net/ipv6.h b/include/net/ipv6.h
> > index 262fc88dbd7e2f..4c9d89b5d73268 100644
> > --- a/include/net/ipv6.h
> > +++ b/include/net/ipv6.h
> > @@ -406,7 +406,7 @@ struct ipv6_txoptions *fl6_merge_options(struct ipv6_txoptions *opt_space,
> >  					 struct ip6_flowlabel *fl,
> >  					 struct ipv6_txoptions *fopt);
> >  void fl6_free_socklist(struct sock *sk);
> > -int ipv6_flowlabel_opt(struct sock *sk, char __user *optval, int optlen);
> > +int ipv6_flowlabel_opt(struct sock *sk, sockptr_t optval, int optlen);
> >  int ipv6_flowlabel_opt_get(struct sock *sk, struct in6_flowlabel_req *freq,
> >  			   int flags);
> >  int ip6_flowlabel_init(void);
> > diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
> > index 27ee6de9beffc4..6b3c315f3d461a 100644
> > --- a/net/ipv6/ip6_flowlabel.c
> > +++ b/net/ipv6/ip6_flowlabel.c
> > @@ -371,7 +371,7 @@ static int fl6_renew(struct ip6_flowlabel *fl, unsigned long linger, unsigned lo
> >
> >  static struct ip6_flowlabel *
> >  fl_create(struct net *net, struct sock *sk, struct in6_flowlabel_req *freq,
> > -	  char __user *optval, int optlen, int *err_p)
> > +	  sockptr_t optval, int optlen, int *err_p)
> >  {
> >  	struct ip6_flowlabel *fl = NULL;
> >  	int olen;
> > @@ -401,7 +401,8 @@ fl_create(struct net *net, struct sock *sk, struct in6_flowlabel_req *freq,
> >  		memset(fl->opt, 0, sizeof(*fl->opt));
> >  		fl->opt->tot_len = sizeof(*fl->opt) + olen;
> >  		err = -EFAULT;
> > -		if (copy_from_user(fl->opt+1, optval+CMSG_ALIGN(sizeof(*freq)), olen))
> > +		sockptr_advance(optval, CMSG_ALIGN(sizeof(*freq)));
> > +		if (copy_from_sockptr(fl->opt + 1, optval, olen))
> >  			goto done;
> >
> >  		msg.msg_controllen = olen;
> > @@ -604,7 +605,7 @@ static int ipv6_flowlabel_renew(struct sock *sk, struct in6_flowlabel_req *freq)
> >  }
> >
> >  static int ipv6_flowlabel_get(struct sock *sk, struct in6_flowlabel_req *freq,
> > -		void __user *optval, int optlen)
> > +		sockptr_t optval, int optlen)
> >  {
> >  	struct ipv6_fl_socklist *sfl, *sfl1 = NULL;
> >  	struct ip6_flowlabel *fl, *fl1 = NULL;
> > @@ -702,8 +703,9 @@ static int ipv6_flowlabel_get(struct sock *sk, struct in6_flowlabel_req *freq,
> >  		goto recheck;
> >
> >  	if (!freq->flr_label) {
> > -		if (copy_to_user(&((struct in6_flowlabel_req __user *) optval)->flr_label,
> > -				 &fl->label, sizeof(fl->label))) {
> > +		sockptr_advance(optval,
> > +				offsetof(struct in6_flowlabel_req, flr_label));
> 
> Christoph,
> 
> I see a regression with IPv6 flowlabel that I bisected to this patch.
> When passing '-F 0' to 'ping' the flow label should be random, yet it's
> the same every time after this patch.
> 
> It seems that the pointer is never advanced after the call to
> sockptr_advance() because it is passed by value and not by reference.
> Even if you were to pass it by reference I think you would later need to
> call sockptr_decrease() or something similar. Otherwise it is very
> error-prone.

Depending on the other checks you may also be able to cross from
user addresses to kernel ones.
At the minimum sockptr_advance() has to fail if the boundary
would be crossed.

> Maybe adding an offset to copy_to_sockptr() and copy_from_sockptr() is
> better?

The 'is this a kernel or user copy' needs to use the base
address from the system call.
So you do need the offset passed in to copy_to/from_sockptr().

Clearly churn can be reduced by using a #define or static inline
for the common case.

The alternative is to pass a 'fat pointer' through than can
contain an offset as well as the user/kernel bases and
expected length.

	David

-
Registered Address Lakeside, Bramley Road, Mount Farm, Milton Keynes, MK1 1PT, UK
Registration No: 1397386 (Wales)

