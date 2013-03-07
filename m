From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next 11/12] ipvs: reorder keys in connection
 structure
Date: Fri, 8 Mar 2013 01:23:44 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1303080120290.3035@ja.ssi.bg>
References: <1362559342-18784-1-git-send-email-ja@ssi.bg>   <1362559342-18784-12-git-send-email-ja@ssi.bg>  <1362563014.17102.63.camel@hawk.mlab.se>  <alpine.LFD.2.00.1303062246480.1899@ja.ssi.bg> <1362642592.17102.140.camel@hawk.mlab.se>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1362642592.17102.140.camel@hawk.mlab.se>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org


	Hello,

On Thu, 7 Mar 2013, Hans Schillstrom wrote:

> I made some tests on weaker machine (i7-3930K) with moderate background
> load, there is absolute no measurable difference with daddr in first
> cache line or in second line.
> So based on that I prefer your solution since it keeps data together.

	Thanks for the review and the tests. But I'll
slightly extend this patch in v2 with more optimizations...

Regards

--
Julian Anastasov <ja@ssi.bg>
