From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2] ipvs: Fix panic due to non-linear skb
Date: Mon, 26 May 2014 10:37:36 +0900
Message-ID: <20140526013735.GG31096@verge.net.au>
References: <1400960412-12830-1-git-send-email-pch@ordbogen.com>
 <alpine.LFD.2.11.1405250010210.1539@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1405250010210.1539@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Peter Christensen <pch@ordbogen.com>, Wensong Zhang <wensong@linux-vs.org>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org

On Sun, May 25, 2014 at 12:16:31AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Sat, 24 May 2014, Peter Christensen wrote:
> 
> > Receiving a ICMP response to an IPIP packet in a non-linear skb could
> > cause a kernel panic in __skb_pull.
> > 
> > The problem was introduced in
> > commit f2edb9f7706dcb2c0d9a362b2ba849efe3a97f5e ("ipvs: implement
> > passive PMTUD for IPIP packets").
> > 
> > Signed-off-by: Peter Christensen <pch@ordbogen.com>
> 
> 	Thanks!
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> 	Simon, please apply to ipvs tree!

Thanks, done.
