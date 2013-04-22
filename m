From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [patch] ipvs: off by one in set_sctp_state()
Date: Mon, 22 Apr 2013 09:03:28 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1304220843560.1626@ja.ssi.bg>
References: <20130420112455.GA30198@elgon.mountain> <alpine.LFD.2.00.1304201504510.1593@ja.ssi.bg> <20130422041151.GM15680@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130422041151.GM15680@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Dan Carpenter <dan.carpenter@oracle.com>, Wensong Zhang <wensong@linux-vs.org>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, coreteam@netfilter.org


	Hello,

On Mon, 22 Apr 2013, Simon Horman wrote:

> > 	There are more confusing (still, non-fatal)
> > problems in this IPVS-SCTP support, eg.
> > 
> >         if (direction == IP_VS_DIR_OUTPUT)
> > -               event++;
> > +               event *= 2;
> > 
> > 	I guess we are running with wrong timeouts.
> 
> IMHO there seem to be many problems with SCTP, but it is good to
> fix the ones we find as we find them.

	At the time I found it (during IPVS optimizations
development), it didn't looked fatal, I preferred to
allocate more time for SCTP for debugging.

> Would you like to make a patch for the above change or should I?

	May be the code is correct, my mistake. I was
confused from the order in sctp_events[] but ipvs_sctp_event_t
allocates values for _SER states.

> > 	Also, I'm not sure we support properly the
> > one-way states as done for TCP (IP_VS_DIR_INPUT_ONLY).
> > May be this code deserves more serious review, for example,
> > net/netfilter/nf_conntrack_proto_sctp.c looks as good
> > source for comparison.
> 
> I believe it does need a more serious review.

Regards

--
Julian Anastasov <ja@ssi.bg>
