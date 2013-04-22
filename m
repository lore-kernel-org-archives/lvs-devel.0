From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch] ipvs: off by one in set_sctp_state()
Date: Mon, 22 Apr 2013 13:11:52 +0900
Message-ID: <20130422041151.GM15680@verge.net.au>
References: <20130420112455.GA30198@elgon.mountain>
 <alpine.LFD.2.00.1304201504510.1593@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1304201504510.1593@ja.ssi.bg>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Dan Carpenter <dan.carpenter@oracle.com>, Wensong Zhang <wensong@linux-vs.org>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, coreteam@netfilter.org

On Sat, Apr 20, 2013 at 03:25:21PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Sat, 20 Apr 2013, Dan Carpenter wrote:
> 
> > The sctp_events[] come from sch->type in set_sctp_state().  They are
> > between 0-255 so that means we need 256 elements in the array.
> > 
> > I believe that because of how the code is aligned there is normally a
> > hole after sctp_events[] so this patch doesn't actually change anything.
> > 
> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> > ---
> > This is static checker stuff.  I'm not very familiar with this code.
> > 
> > diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
> > index 6e14a7b..8646488 100644
> > --- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
> > +++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
> > @@ -208,7 +208,7 @@ enum ipvs_sctp_event_t {
> >  	IP_VS_SCTP_EVE_LAST
> >  };
> >  
> > -static enum ipvs_sctp_event_t sctp_events[255] = {
> > +static enum ipvs_sctp_event_t sctp_events[256] = {
> >  	IP_VS_SCTP_EVE_DATA_CLI,
> >  	IP_VS_SCTP_EVE_INIT_CLI,
> >  	IP_VS_SCTP_EVE_INIT_ACK_CLI,
> 
> 	There are more confusing (still, non-fatal)
> problems in this IPVS-SCTP support, eg.
> 
>         if (direction == IP_VS_DIR_OUTPUT)
> -               event++;
> +               event *= 2;
> 
> 	I guess we are running with wrong timeouts.

IMHO there seem to be many problems with SCTP, but it is good to
fix the ones we find as we find them.

Would you like to make a patch for the above change or should I?

> 	Also, I'm not sure we support properly the
> one-way states as done for TCP (IP_VS_DIR_INPUT_ONLY).
> May be this code deserves more serious review, for example,
> net/netfilter/nf_conntrack_proto_sctp.c looks as good
> source for comparison.

I believe it does need a more serious review.

> 	Anyways, this change looks correct to me,
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>

I have queued-up this change in ipvs-next.
Thanks Dan & Julian.
