From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Forward Shared Patch
Date: Sun, 25 Sep 2011 11:39:21 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1109251129190.1474@ja.ssi.bg>
References: <20110925011347.GB31019@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20110925011347.GB31019@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org


	Hello,

On Sun, 25 Sep 2011, Simon Horman wrote:

> Hi Julian,
> 
> I am wondering if you have any interest in/objections to trying
> to merge your forward shared patch which allows an IPVS director
> to act as a router for realservers using the direct routing or tunnelling
> forwarding mechanisms.
> 
> http://www.ssi.bg/~ja/#lvsgw

	Such feature is already added to 2.6.33:

/proc/sys/net/ipv4/conf/*/accept_local

Regards

--
Julian Anastasov <ja@ssi.bg>
