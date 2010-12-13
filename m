From: Tinggong Wang <wangtinggong@gmail.com>
Subject: Re: [PATCH 2/3] ipvs: check data validation before local_bh_disable
Date: Mon, 13 Dec 2010 18:49:11 +0800
Message-ID: <20101213104911.GB6558@wangtg>
References: <adb973b711975ac5a24c69818fd0439d88f4c68c.1292153764.git.wangtinggong@gmail.com>
 <3236859ec32d32324ce6e1f8a4456d2d1a84ed7b.1292153764.git.wangtinggong@gmail.com>
 <20101212214806.GF7914@verge.net.au>
 <20101213034438.GA3814@wangtg>
 <20101213062921.GE4748@verge.net.au>
 <1292230381.4983.31.camel@seasc0214>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:received:received:date:from:to:cc:subject
         :message-id:references:mime-version:content-type:content-disposition
         :in-reply-to;
        bh=NJ3VNz504jchwwpib7TQdZWcIiC7/q+bLR+VYLs+j8M=;
        b=c+d4I4zTmx7mFvJF4kS8cSS7AehPFqkO6n/kEnUtlce8t738UiItJs7jQlsJ1RqwJ3
         xYUUFpYhpjmm3TRHtfnIH7E7tlvB0UlcFHbzXIzVhPrgtlE1/0mYfQj8yWVI2KEs6ekk
         V7Zn6kcj9zZtqbusbmJMAmqadrU928+DggF1E=
Content-Disposition: inline
In-Reply-To: <1292230381.4983.31.camel@seasc0214>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: Simon Horman <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, Hans Schillstrom <hans@schillstrom.com>, Julian Anastasov <ja@ssi.bg>

on Mon, 13 Dec 2010 09:53:01AM +0100 Hans Schillstrom (hans.schillstrom@ericsson.com) wrote:
> On Mon, 2010-12-13 at 07:29 +0100, Simon Horman wrote:
> > On Mon, Dec 13, 2010 at 11:44:38AM +0800, Tinggong Wang wrote:
> > > on Mon, 13 Dec 2010 06:48:06AM +0900 Simon Horman (horms@verge.net.au) wrote:
> > > > [ CCed Hans Schillstrom and Julian Anastasov ]
> > > > 
> > > > On Sun, Dec 12, 2010 at 07:42:29PM +0800, Tinggong Wang wrote:
> > > > > Signed-off-by: Tinggong Wang <wangtinggong@gmail.com>
> > > > > ---
> > > > >  net/netfilter/ipvs/ip_vs_sync.c |   13 ++++++++-----
> > > > >  1 files changed, 8 insertions(+), 5 deletions(-)
> > > > > 
> > > > > diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> > > > > index 7632a17..2b6b0cb 100644
> > > > > --- a/net/netfilter/ipvs/ip_vs_sync.c
> > > > > +++ b/net/netfilter/ipvs/ip_vs_sync.c
> > > > > @@ -315,11 +315,6 @@ static void ip_vs_process_message(const char *buffer, const size_t buflen)
> > > > >  	char *p;
> > > > >  	int i;
> > > > >  
> > > > > -	if (buflen < SYNC_MESG_HEADER_LEN) {
> > > > > -		IP_VS_ERR_RL("sync message header too short\n");
> > > > > -		return;
> > > > > -	}
> > > > > -
> > > > >  	/* Convert size back to host byte order */
> > > > >  	m->size = ntohs(m->size);
> > > > >  
> > > > > @@ -823,6 +818,14 @@ static int sync_thread_backup(void *data)
> > > > >  				break;
> > > > >  			}
> > > > >  
> > > > > +			/* throw invalid data before local_bh_disable,
> > > > > +			 * so performance won't be downgraded by it
> > > > > +			 */
> > > > > +			if (len < SYNC_MESG_HEADER_LEN) {
> > > > > +				IP_VS_ERR_RL("sync message header too short\n");
> > > > > +				continue;
> > > > > +			}
> > > > > +
> > > > >  			/* disable bottom half, because it accesses the data
> > > > >  			   shared by softirq while getting/creating conns */
> > > > >  			local_bh_disable();
> > > > > -- 
> > > > > 1.7.2.3
> > > > > 
> > > > 
> > > > Could you explain the motivation for this change?
> > > 
> > > in my opinion, before local_bh_disable, should ensure packets are look
> > > like more resonable.
> > > 
> > > local_bh_disable will disable all bottom-half processing on local cpu,
> > > if the multicast group flood of packets containing bad sync message,
> > > local cpu will be busy doing local_bh_disable and local_bh_enable. 
> > > 
> > > if the backup pc has only one cpu, all other tasks will be pending until
> > > the flood finished.
> > 
> > Ok, that does sound reasonable to some extent. But realistically
> > this should only occur if bogus packets are being sent. And in
> > that case it would be possible for bogus packets to be more carefully
> > crafted such that we need to enter ip_vs_process_message() anyway.
> > So I'm not sure if there really is a gain here.
> > 
> I do agree, first of all It's a multicast and they are never opened in
> firewall so who should flood us? 
> (If IPVS addr and port is open close it)
> I don't think the extra rows actually adds anything as you say.
> 
Yes, it has small possibility to occur. and this patch only make sense
when the bogus packets length less than SYNC_MESG_HEADER_LEN.

but if it occurs, for example, someone write a program, join the
multicast group cursorily, and floods bogus packets accidentally.
backup's performace will be downgraded.

is this scenario should be included? if so, i'll try to improve this
patch. 

Thanks!
