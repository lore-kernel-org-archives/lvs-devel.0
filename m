From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net] ipvs: fix oops in ip_vs_dst_event on rmmod
Date: Wed, 11 Jul 2012 10:11:27 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1207111010380.1838@ja.ssi.bg>
References: <1341682211-4751-1-git-send-email-ja@ssi.bg> <20120710084629.GB27117@verge.net.au> <alpine.LFD.2.00.1207102230360.1882@ja.ssi.bg> <20120711000424.GA24026@verge.net.au> <alpine.LFD.2.00.1207110952460.1838@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1207110952460.1838@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Wed, 11 Jul 2012, Julian Anastasov wrote:

> > > > have you observed this oops or is it theoretical?
> > > > I ask because it effects if I should submit this change for
> > > > inclusion in 3.5 and 3.4-stable or just queue it up for 3.6.
> > > 
> > > 	Yes, oops happened to me. I'm not sure how I missed
> > > it while creating the mentioned change. Please, queue it
> > > for stable kernels.
> > 
> > Thanks, will do.
> 
> 	Only for 3.4-stable, it seems

	Of course, it is for 3.5 and 3.4-stable (3.4+)

Regards

--
Julian Anastasov <ja@ssi.bg>
