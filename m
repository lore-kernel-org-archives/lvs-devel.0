From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net] ipvs: properly declare tunnel encapsulation
Date: Thu, 28 Aug 2014 10:52:06 +0900
Message-ID: <20140828015206.GA25073@verge.net.au>
References: <1406878577-4506-1-git-send-email-ja@ssi.bg>
 <20140825011852.GB31233@verge.net.au>
 <alpine.LFD.2.11.1408250809380.1935@ja.home.ssi.bg>
 <20140825064919.GA2691@verge.net.au>
 <alpine.LFD.2.11.1408251100050.1526@ja.home.ssi.bg>
 <20140827053324.GA1626@verge.net.au>
 <alpine.LFD.2.11.1408271002340.2348@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1408271002340.2348@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, Alex Gartrell <agartrell@fb.com>, kernel-team <Kernel-team@fb.com>

On Wed, Aug 27, 2014 at 10:04:21AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Wed, 27 Aug 2014, Simon Horman wrote:
> 
> > On Mon, Aug 25, 2014 at 11:11:38AM +0300, Julian Anastasov wrote:
> > > 
> > > 	Hello,
> > > 
> > > On Mon, 25 Aug 2014, Simon Horman wrote:
> > > 
> > > > On Mon, Aug 25, 2014 at 08:13:14AM +0300, Julian Anastasov wrote:
> > > > > 
> > > > > 	Hello,
> > > > > 
> > > > > On Mon, 25 Aug 2014, Simon Horman wrote:
> > > > > 
> > > > > > On Fri, Aug 01, 2014 at 10:36:17AM +0300, Julian Anastasov wrote:
> > > > > > > The tunneling method should properly use tunnel encapsulation.
> > > > > > > Fixes problem with CHECKSUM_PARTIAL packets when TCP/UDP csum
> > > > > > > offload is supported.
> > > > > > > 
> > > > > > > Thanks to Alex Gartrell for reporting the problem, providing
> > > > > > > solution and for all suggestions.
> > > > > > 
> > > > > > With this patch is Alex's patch "[PATCH ipvs] ipvs: invoke
> > > > > > skb_checksum_help prior to encapsulation in tunnel xmit " also needed?
> > > > > 
> > > > > 	Not needed, we prefer to avoid csum calculation by CPU.
> > > > 
> > > > Thanks, understood.
> > > > 
> > > > I have applied (only) this patch to ipvs-next.
> > > 
> > > 	May be we should apply it as bugfix to ipvs tree.
> > > Later stable kernels may need it. Also, new changes from
> > > Alex Gartrell about tunneling depend on it, they are
> > > net-next material, still in development, so I guess this
> > > patch will appear soon on net-next via next -rc if
> > > applied now as bugfix.
> > 
> > Sure, I'll do as you suggest.
> 
> 	Don't forget "ipvs: fix ipv6 hook registration for local replies"
> from August 22. It is a bugfix too.

Thanks, and sorry for letting that slip through the cracks.
I'll queue it up ASAP.
