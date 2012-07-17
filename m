From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 2/3] ipvs: add missing lock in ip_vs_ftp_init_conn()
Date: Tue, 17 Jul 2012 14:14:57 +0900
Message-ID: <20120717051457.GH29124@verge.net.au>
References: <1341965963-7275-1-git-send-email-horms@verge.net.au>
 <1341965963-7275-3-git-send-email-horms@verge.net.au>
 <20120716210757.GA18026@1984>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120716210757.GA18026@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Xiaotian Feng <xtfeng@gmail.com>, Xiaotian Feng <dannyfeng@tencent.com>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>

On Mon, Jul 16, 2012 at 11:07:57PM +0200, Pablo Neira Ayuso wrote:
> Hi Simon,
> 
> On Wed, Jul 11, 2012 at 09:19:22AM +0900, Simon Horman wrote:
> > From: Xiaotian Feng <xtfeng@gmail.com>
> > 
> > We met a kernel panic in 2.6.32.43 kernel:
> [...]
> >  net/netfilter/ipvs/ip_vs_ftp.c | 2 ++
> >  1 file changed, 2 insertions(+)
> > 
> > diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
> > index b20b29c..c2bc264 100644
> > --- a/net/netfilter/ipvs/ip_vs_ftp.c
> > +++ b/net/netfilter/ipvs/ip_vs_ftp.c
> > @@ -65,8 +65,10 @@ static int ip_vs_ftp_pasv;
> >  static int
> >  ip_vs_ftp_init_conn(struct ip_vs_app *app, struct ip_vs_conn *cp)
> >  {
> > +	spin_lock(&cp->lock);
> >  	/* We use connection tracking for the command connection */
> >  	cp->flags |= IP_VS_CONN_F_NFCT;
> > +	spin_unlock(&cp->lock);
> >  	return 0;
> 
> The conntrack support for FTP IPVS helper seems to be there since
> 2.6.37.
> 
> However, the patch description mentions 2.6.32.43.
> 
> Something doesn't match here, could you clarify this?

My understanding is that the problem was observed with 2.6.32
but that it has been around for much longer.
