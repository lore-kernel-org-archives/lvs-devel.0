From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [PATCH 2/3] ipvs: check data validation before local_bh_disable
Date: Mon, 13 Dec 2010 09:53:01 +0100
Message-ID: <1292230381.4983.31.camel@seasc0214>
References: <adb973b711975ac5a24c69818fd0439d88f4c68c.1292153764.git.wangtinggong@gmail.com>
	 <3236859ec32d32324ce6e1f8a4456d2d1a84ed7b.1292153764.git.wangtinggong@gmail.com>
	 <20101212214806.GF7914@verge.net.au> <20101213034438.GA3814@wangtg>
	 <20101213062921.GE4748@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20101213062921.GE4748@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: Tinggong Wang <wangtinggong@gmail.com>, Wensong Zhang <wensong@linux-vs.org>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, Hans Schillstrom <hans@schillstrom.com>, Julian Anastasov <ja@ssi.bg>

On Mon, 2010-12-13 at 07:29 +0100, Simon Horman wrote:
> On Mon, Dec 13, 2010 at 11:44:38AM +0800, Tinggong Wang wrote:
> > on Mon, 13 Dec 2010 06:48:06AM +0900 Simon Horman (horms@verge.net.au) wrote:
> > > [ CCed Hans Schillstrom and Julian Anastasov ]
> > > 
> > > On Sun, Dec 12, 2010 at 07:42:29PM +0800, Tinggong Wang wrote:
> > > > Signed-off-by: Tinggong Wang <wangtinggong@gmail.com>
> > > > ---
> > > >  net/netfilter/ipvs/ip_vs_sync.c |   13 ++++++++-----
> > > >  1 files changed, 8 insertions(+), 5 deletions(-)
> > > > 
> > > > diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> > > > index 7632a17..2b6b0cb 100644
> > > > --- a/net/netfilter/ipvs/ip_vs_sync.c
> > > > +++ b/net/netfilter/ipvs/ip_vs_sync.c
> > > > @@ -315,11 +315,6 @@ static void ip_vs_process_message(const char *buffer, const size_t buflen)
> > > >  	char *p;
> > > >  	int i;
> > > >  
> > > > -	if (buflen < SYNC_MESG_HEADER_LEN) {
> > > > -		IP_VS_ERR_RL("sync message header too short\n");
> > > > -		return;
> > > > -	}
> > > > -
> > > >  	/* Convert size back to host byte order */
> > > >  	m->size = ntohs(m->size);
> > > >  
> > > > @@ -823,6 +818,14 @@ static int sync_thread_backup(void *data)
> > > >  				break;
> > > >  			}
> > > >  
> > > > +			/* throw invalid data before local_bh_disable,
> > > > +			 * so performance won't be downgraded by it
> > > > +			 */
> > > > +			if (len < SYNC_MESG_HEADER_LEN) {
> > > > +				IP_VS_ERR_RL("sync message header too short\n");
> > > > +				continue;
> > > > +			}
> > > > +
> > > >  			/* disable bottom half, because it accesses the data
> > > >  			   shared by softirq while getting/creating conns */
> > > >  			local_bh_disable();
> > > > -- 
> > > > 1.7.2.3
> > > > 
> > > 
> > > Could you explain the motivation for this change?
> > 
> > in my opinion, before local_bh_disable, should ensure packets are look
> > like more resonable.
> > 
> > local_bh_disable will disable all bottom-half processing on local cpu,
> > if the multicast group flood of packets containing bad sync message,
> > local cpu will be busy doing local_bh_disable and local_bh_enable. 
> > 
> > if the backup pc has only one cpu, all other tasks will be pending until
> > the flood finished.
> 
> Ok, that does sound reasonable to some extent. But realistically
> this should only occur if bogus packets are being sent. And in
> that case it would be possible for bogus packets to be more carefully
> crafted such that we need to enter ip_vs_process_message() anyway.
> So I'm not sure if there really is a gain here.
> 
I do agree, first of all It's a multicast and they are never opened in
firewall so who should flood us? 
(If IPVS addr and port is open close it)
I don't think the extra rows actually adds anything as you say.





