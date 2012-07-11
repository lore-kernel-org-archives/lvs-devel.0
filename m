From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net] ipvs: fix oops in ip_vs_dst_event on rmmod
Date: Wed, 11 Jul 2012 16:45:24 +0900
Message-ID: <20120711074524.GA27101@verge.net.au>
References: <1341682211-4751-1-git-send-email-ja@ssi.bg>
 <20120710084629.GB27117@verge.net.au>
 <alpine.LFD.2.00.1207102230360.1882@ja.ssi.bg>
 <20120711000424.GA24026@verge.net.au>
 <alpine.LFD.2.00.1207110952460.1838@ja.ssi.bg>
 <alpine.LFD.2.00.1207111010380.1838@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1207111010380.1838@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

On Wed, Jul 11, 2012 at 10:11:27AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Wed, 11 Jul 2012, Julian Anastasov wrote:
> 
> > > > > have you observed this oops or is it theoretical?
> > > > > I ask because it effects if I should submit this change for
> > > > > inclusion in 3.5 and 3.4-stable or just queue it up for 3.6.
> > > > 
> > > > 	Yes, oops happened to me. I'm not sure how I missed
> > > > it while creating the mentioned change. Please, queue it
> > > > for stable kernels.
> > > 
> > > Thanks, will do.
> > 
> > 	Only for 3.4-stable, it seems
> 
> 	Of course, it is for 3.5 and 3.4-stable (3.4+)

Thanks, got it.
