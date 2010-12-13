From: Tinggong Wang <wangtinggong@gmail.com>
Subject: Re: [PATCH 2/3] ipvs: check data validation before local_bh_disable
Date: Mon, 13 Dec 2010 11:44:38 +0800
Message-ID: <20101213034438.GA3814@wangtg>
References: <adb973b711975ac5a24c69818fd0439d88f4c68c.1292153764.git.wangtinggong@gmail.com>
 <3236859ec32d32324ce6e1f8a4456d2d1a84ed7b.1292153764.git.wangtinggong@gmail.com>
 <20101212214806.GF7914@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:received:received:date:from:to:cc:subject
         :message-id:references:mime-version:content-type:content-disposition
         :in-reply-to;
        bh=LlZPXhwEjdIGLH2JM6cCugf4D8K0xc7Cs76d0MLUlYo=;
        b=wNr/xV+/2rPgnxxJJ2V7MHZuJwNlimlLgDWSSpAIrNnretiIZfrNRabj1qC8blUXY1
         oHwC3uE3AaLRuyTyo80LCOncv7Wcwu2+hl/8wVC5qp8oWIe5gd0sSNLNv3khphGHKnJR
         QTnQkqLOyXkOWdIlRE3+E8PI03jXi8MDUYA50=
Content-Disposition: inline
In-Reply-To: <20101212214806.GF7914@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Wensong Zhang <wensong@linux-vs.org>, lvs-devel@vger.kernel.org, Hans Schillstrom <hans@schillstrom.com>, Julian Anastasov <ja@ssi.bg>

on Mon, 13 Dec 2010 06:48:06AM +0900 Simon Horman (horms@verge.net.au) wrote:
> [ CCed Hans Schillstrom and Julian Anastasov ]
> 
> On Sun, Dec 12, 2010 at 07:42:29PM +0800, Tinggong Wang wrote:
> > Signed-off-by: Tinggong Wang <wangtinggong@gmail.com>
> > ---
> >  net/netfilter/ipvs/ip_vs_sync.c |   13 ++++++++-----
> >  1 files changed, 8 insertions(+), 5 deletions(-)
> > 
> > diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> > index 7632a17..2b6b0cb 100644
> > --- a/net/netfilter/ipvs/ip_vs_sync.c
> > +++ b/net/netfilter/ipvs/ip_vs_sync.c
> > @@ -315,11 +315,6 @@ static void ip_vs_process_message(const char *buffer, const size_t buflen)
> >  	char *p;
> >  	int i;
> >  
> > -	if (buflen < SYNC_MESG_HEADER_LEN) {
> > -		IP_VS_ERR_RL("sync message header too short\n");
> > -		return;
> > -	}
> > -
> >  	/* Convert size back to host byte order */
> >  	m->size = ntohs(m->size);
> >  
> > @@ -823,6 +818,14 @@ static int sync_thread_backup(void *data)
> >  				break;
> >  			}
> >  
> > +			/* throw invalid data before local_bh_disable,
> > +			 * so performance won't be downgraded by it
> > +			 */
> > +			if (len < SYNC_MESG_HEADER_LEN) {
> > +				IP_VS_ERR_RL("sync message header too short\n");
> > +				continue;
> > +			}
> > +
> >  			/* disable bottom half, because it accesses the data
> >  			   shared by softirq while getting/creating conns */
> >  			local_bh_disable();
> > -- 
> > 1.7.2.3
> > 
> 
> Could you explain the motivation for this change?

in my opinion, before local_bh_disable, should ensure packets are look
like more resonable.

local_bh_disable will disable all bottom-half processing on local cpu,
if the multicast group flood of packets containing bad sync message,
local cpu will be busy doing local_bh_disable and local_bh_enable. 

if the backup pc has only one cpu, all other tasks will be pending until
the flood finished.

