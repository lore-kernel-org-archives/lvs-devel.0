From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 2/3] ipvs: add missing lock in ip_vs_ftp_init_conn()
Date: Tue, 17 Jul 2012 11:46:40 +0200
Message-ID: <20120717094640.GA1466@1984>
References: <1341965963-7275-1-git-send-email-horms@verge.net.au>
 <1341965963-7275-3-git-send-email-horms@verge.net.au>
 <20120716210757.GA18026@1984>
 <CAJn8CcEChmrFvASChJfj7qK8F-my79fn+-G8ttst02Sts15y6Q@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAJn8CcEChmrFvASChJfj7qK8F-my79fn+-G8ttst02Sts15y6Q@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Xiaotian Feng <xtfeng@gmail.com>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Xiaotian Feng <dannyfeng@tencent.com>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>

Hi,

On Tue, Jul 17, 2012 at 09:44:01AM +0800, Xiaotian Feng wrote:
> On Tue, Jul 17, 2012 at 5:07 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> > Hi Simon,
> >
> > On Wed, Jul 11, 2012 at 09:19:22AM +0900, Simon Horman wrote:
> >> From: Xiaotian Feng <xtfeng@gmail.com>
> >>
> >> We met a kernel panic in 2.6.32.43 kernel:
> > [...]
> >>  net/netfilter/ipvs/ip_vs_ftp.c | 2 ++
> >>  1 file changed, 2 insertions(+)
> >>
> >> diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
> >> index b20b29c..c2bc264 100644
> >> --- a/net/netfilter/ipvs/ip_vs_ftp.c
> >> +++ b/net/netfilter/ipvs/ip_vs_ftp.c
> >> @@ -65,8 +65,10 @@ static int ip_vs_ftp_pasv;
> >>  static int
> >>  ip_vs_ftp_init_conn(struct ip_vs_app *app, struct ip_vs_conn *cp)
> >>  {
> >> +     spin_lock(&cp->lock);
> >>       /* We use connection tracking for the command connection */
> >>       cp->flags |= IP_VS_CONN_F_NFCT;
> >> +     spin_unlock(&cp->lock);
> >>       return 0;
> >
> > The conntrack support for FTP IPVS helper seems to be there since
> > 2.6.37.
> >
> > However, the patch description mentions 2.6.32.43.
> >
> > Something doesn't match here, could you clarify this?
> >
> 
> Sorry for the misleading description in the patch. We found the panic
> in 2.6.32.43 is caused by changing cp->flags without protection. In
> 2.6.32.43, ip_vs_process_message changes cp->flags without protection
> while update active/inactive flags for the connection.
> 
> After code inspiration, we found in 3.x kernel, it is accidentally
> fixed by commit  f73181c. But with ip_vs_app changes,
> ip_vs_ftp_init_conn() will have chance to change cp->flags without
> protection. So it is a potential bug in 3.x kernel.

Please, then fix the patch description and resend the patch to me.

I have to justify why this is pushed forward to David, and using
misleading description for the patch is not the way to go.

Regarding this bitset operation, I think it's way better if you use
bitwise operations for those cp->flags. Getting the spin_lock just to
set the flag is way too much.
