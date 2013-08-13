From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2] ipvs: fix overflow on dest weight multiply
Date: Tue, 13 Aug 2013 12:23:48 +1000
Message-ID: <20130813022348.GM4885@verge.net.au>
References: <20130523165836.GC436@hostway.ca>
 <alpine.LFD.2.00.1305232243220.1810@ja.ssi.bg>
 <20130524004318.GB14587@hostway.ca>
 <alpine.LFD.2.00.1305241013130.1636@ja.ssi.bg>
 <20130806024150.GA2393@hostway.ca>
 <alpine.LFD.2.00.1308060856200.1710@ja.ssi.bg>
 <20130808235434.GD7147@hostway.ca>
 <alpine.LFD.2.00.1308091114230.1702@ja.ssi.bg>
 <20130810082618.GB21768@hostway.ca>
 <alpine.LFD.2.00.1308101521210.1654@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1308101521210.1654@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Kirby <sim@hostway.ca>, lvs-devel@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>

On Sat, Aug 10, 2013 at 03:31:03PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Sat, 10 Aug 2013, Simon Kirby wrote:
> 
> > On Fri, Aug 09, 2013 at 12:02:11PM +0300, Julian Anastasov wrote:
> > 
> > > 	Looks good to me, even if you add space
> > > between "(__s64)" cast and "loh"/"doh".
> > 
> > I think (__s64)loh * doh makes more sense as the cast applies to the
> > variable before the multiply is evaluated.
> 
> 	OK
> 
> > > 	But after your fix for ip_vs_dest_conn_overhead
> > > I see that also ip_vs_nq_dest_overhead and ip_vs_sed_dest_overhead
> > > need to return int instead of unsigned int. I'll ack
> > > v2 with these changes.
> > 
> > Ok, fixed. :)
> 
> 	Thanks!
> 
> > > 	Also, shorter subject is preferred, you can use
> > > 'ipvs: fix overflow on dest weight multiply' or something
> > > else that you feel is better, '()' and '*' does not look
> > > good in subject. Thanks!
> > 
> > -- 8< --
> > 
> > Schedulers such as lblc and lblcr require the weight to be as high as the
> > maximum number of active connections. In commit b552f7e3a9524abcbcdf, the
> > consideration of inactconns and activeconns was cleaned up to always
> > count activeconns as 256 times more important than inactconns. In cases
> > where 3000 or more connections are expected, a weight of 3000 * 256 *
> > 3000 connections overflows the 32-bit signed result used to determine if
> > rescheduling is required.
> > 
> > On amd64, this merely changes the multiply and comparison instructions to
> > 64-bit. On x86, a 64-bit result is already present from imull, so only
> > a few more comparison instructions are emitted.
> > 
> > Signed-off-by: Simon Kirby <sim@hostway.ca>
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> 	Horms, please apply!

Sure, will do.

I am on vacation until the 21st and thus my net access is somewhat
sporadic. I apologise that this may delay me pushing this patch to
ipvs-next.
