From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net] ipvs: fix oops in ip_vs_dst_event on rmmod
Date: Wed, 11 Jul 2012 09:04:28 +0900
Message-ID: <20120711000424.GA24026@verge.net.au>
References: <1341682211-4751-1-git-send-email-ja@ssi.bg>
 <20120710084629.GB27117@verge.net.au>
 <alpine.LFD.2.00.1207102230360.1882@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1207102230360.1882@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

On Tue, Jul 10, 2012 at 10:33:17PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Tue, 10 Jul 2012, Simon Horman wrote:
> 
> > On Sat, Jul 07, 2012 at 08:30:11PM +0300, Julian Anastasov wrote:
> > > 	After commit 39f618b4fd95ae243d940ec64c961009c74e3333 (3.4)
> > > "ipvs: reset ipvs pointer in netns" we can oops in
> > > ip_vs_dst_event on rmmod ip_vs because ip_vs_control_cleanup
> > > is called after the ipvs_core_ops subsys is unregistered and
> > > net->ipvs is NULL. Fix it by exiting early from ip_vs_dst_event
> > > if ipvs is NULL. It is safe because all services and dests
> > > for the net are already freed.
> > 
> > Hi Julian,
> > 
> > have you observed this oops or is it theoretical?
> > I ask because it effects if I should submit this change for
> > inclusion in 3.5 and 3.4-stable or just queue it up for 3.6.
> 
> 	Yes, oops happened to me. I'm not sure how I missed
> it while creating the mentioned change. Please, queue it
> for stable kernels.

Thanks, will do.
