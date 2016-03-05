From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH nf 2/3] netfilter: ipvs: allow rescheduling after RST
Date: Sat, 5 Mar 2016 15:01:13 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1603051500180.1715@ja.home.ssi.bg>
References: <1455756061-21834-1-git-send-email-horms@verge.net.au> <1455756061-21834-3-git-send-email-horms@verge.net.au> <56C5C45D.9050807@cogentembedded.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <56C5C45D.9050807@cogentembedded.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>


	Hello,

On Thu, 18 Feb 2016, Sergei Shtylyov wrote:

> On 2/18/2016 3:41 AM, Simon Horman wrote:
> 
> > From: Julian Anastasov <ja@ssi.bg>
> >
> > "RFC 5961, 4.2. Mitigation" describes a mechanism to request
> > client to confirm with RST the restart of TCP connection
> > before resending its SYN. As result, IPVS can see SYNs for
> > existing connection in CLOSE state. Add check to allow
> > rescheduling in this state.
> >
> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> > Signed-off-by: Simon Horman <horms@verge.net.au>
> > ---
> >   net/netfilter/ipvs/ip_vs_core.c | 1 +
> >   1 file changed, 1 insertion(+)
> >
> > diff --git a/net/netfilter/ipvs/ip_vs_core.c
> > b/net/netfilter/ipvs/ip_vs_core.c
> > index 4da560005b0e..0c1d3fef9a7c 100644
> > --- a/net/netfilter/ipvs/ip_vs_core.c
> > +++ b/net/netfilter/ipvs/ip_vs_core.c
> > @@ -1089,6 +1089,7 @@ static inline bool is_new_conn_expected(const struct
> > ip_vs_conn *cp,
> >    switch (cp->protocol) {
> >    case IPPROTO_TCP:
> >   		return (cp->state == IP_VS_TCP_S_TIME_WAIT) ||
> > +			cp->state == IP_VS_TCP_S_CLOSE ||
> 
>    I would have been consistent and enclosed this expression into parens as
> well. BTW, the indentation is not correct anyway.

	Thanks! I'll send new version...

> 
> >      ((conn_reuse_mode & 2) &&
> >       (cp->state == IP_VS_TCP_S_FIN_WAIT) &&
> >       (cp->flags & IP_VS_CONN_F_NOOUTPUT));
> 
> MBR, Sergei

Regards

--
Julian Anastasov <ja@ssi.bg>
