From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next 4/6] ipvs: fix sparse warnings for sync msg size
Date: Tue, 23 Apr 2013 11:52:32 +0900
Message-ID: <20130423025232.GS12017@verge.net.au>
References: <1366610151.29441.3.camel@hawk.mlab.se>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1366610151.29441.3.camel@hawk.mlab.se>
 <alpine.LFD.2.00.1304220838030.1626@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans@schillstrom.com>
Cc: lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>

On Mon, Apr 22, 2013 at 08:39:46AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 22 Apr 2013, Simon Horman wrote:
> 
> > > 	It seems v0 should be changed too,
> > > ip_vs_send_sync_msg() handles both versions in sb->mesg.
> > 
> > Thanks and sorry for missing that.
> > How about this?
> > 
> > From: Simon Horman <horms@verge.net.au>
> > 
> > ipvs: Use network byte order for sync message size
> > 
> > struct ip_vs_sync_mesg and ip_vs_sync_mesg_v0 are both sent across the wire
> > and used internally to store IPVS synchronisation messages.
> > 
> > Up until now the scheme used has been to convert the size field
> > to network byte order before sending a message on the wire and
> > convert it to host byte order when sending a message.
> > 
> > This patch changes that scheme to always treat the field
> > as being network byte order. This seems appropriate as
> > the structure is sent across the wire. And by consistently
> > treating the field has network byte order it is now possible
> > to take advantage of sparse to flag any future miss-use.
> > 
> > Signed-off-by: Simon Horman <horms@verge.net.au>
> > 
> > ---
> > 
> > v2
> > * As suggested by Julian Anastasov,
> >   update struct ip_vs_sync_mesg_v0  as well as struct ip_vs_sync_mesg.
> 
> 	v2 looks good,
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>

[snip]

On Mon, Apr 22, 2013 at 07:55:51AM +0200, Hans Schillstrom wrote:
> Hello Simon
> 
> On Mon, 2013-04-22 at 13:05 +0900, Simon Horman wrote:
> > On Fri, Apr 19, 2013 at 10:35:04PM +0300, Julian Anastasov wrote:
> > > 
> > > 	Hello,
> > > 
> > > On Fri, 19 Apr 2013, Simon Horman wrote:
> > > 
> > > > My idea is as follows:
> > > > 
> > > > From: Simon Horman <horms@verge.net.au>
> > > > 
> > > > ipvs: Use network byte order for sync message size
> > > > 
> > > > struct ip_vs_sync_mesg is both sent across the wire and
> > > > used internally to store IPVS synchronisation messages.
> > > > 
> > > > Up until now the scheme used has been to convert the size field
> > > > to network byte order before sending a message on the wire and
> > > > convert it to host byte order when sending a message.
> > > > 
> > > > This patch changes that scheme to always treat the field
> > > > as being network byte order. This seems appropriate as
> > > > the structure is sent across the wire. And by consistently
> > > > treating the field has network byte order it is now possible
> > > > to take advantage of sparse to flag any future miss-use.
> > > > 
> > > > Signed-off-by: Simon Horman <horms@verge.net.au>
> > > > ---
> > > >  net/netfilter/ipvs/ip_vs_sync.c |   15 +++++----------
> > > >  1 file changed, 5 insertions(+), 10 deletions(-)
> > > > 
> > > > diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> > > > index 8e57077..c73778a 100644
> > > > --- a/net/netfilter/ipvs/ip_vs_sync.c
> > > > +++ b/net/netfilter/ipvs/ip_vs_sync.c
> > > > @@ -255,7 +255,7 @@ struct ip_vs_sync_mesg_v0 {
> > > >  struct ip_vs_sync_mesg {
> > > >  	__u8			reserved;	/* must be zero */
> > > >  	__u8			syncid;
> > > > -	__u16			size;
> > > > +	__be16			size;
> > > 
> > > 	It seems v0 should be changed too,
> > > ip_vs_send_sync_msg() handles both versions in sb->mesg.
> > 
> > Thanks and sorry for missing that.
> > How about this?
> > 
> > From: Simon Horman <horms@verge.net.au>
> > 
> > ipvs: Use network byte order for sync message size
> > 
> > struct ip_vs_sync_mesg and ip_vs_sync_mesg_v0 are both sent across the wire
> > and used internally to store IPVS synchronisation messages.
> > 
> > Up until now the scheme used has been to convert the size field
> > to network byte order before sending a message on the wire and
> > convert it to host byte order when sending a message.
> > 
> > This patch changes that scheme to always treat the field
> > as being network byte order. This seems appropriate as
> > the structure is sent across the wire. And by consistently
> > treating the field has network byte order it is now possible
> > to take advantage of sparse to flag any future miss-use.
> > 
> > Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> It looks good 
> 
> Ack-by: Hans Schillstrom <hans@schillstrom.com>

[snip]

Thanks, I have added your Acks and queued-up this this
change in ipvs-next.


