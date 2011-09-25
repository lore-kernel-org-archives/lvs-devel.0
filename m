From: Simon Horman <horms@verge.net.au>
Subject: Re: Forward Shared Patch
Date: Mon, 26 Sep 2011 08:00:51 +0900
Message-ID: <20110925230050.GL19787@verge.net.au>
References: <20110925011347.GB31019@verge.net.au>
 <alpine.LFD.2.00.1109251129190.1474@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1109251129190.1474@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org

On Sun, Sep 25, 2011 at 11:39:21AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Sun, 25 Sep 2011, Simon Horman wrote:
> 
> > Hi Julian,
> > 
> > I am wondering if you have any interest in/objections to trying
> > to merge your forward shared patch which allows an IPVS director
> > to act as a router for realservers using the direct routing or tunnelling
> > forwarding mechanisms.
> > 
> > http://www.ssi.bg/~ja/#lvsgw
> 
> 	Such feature is already added to 2.6.33:
> 
> /proc/sys/net/ipv4/conf/*/accept_local

Oh, great. Sorry for the noise.
