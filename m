From: Simon Horman <horms@verge.net.au>
Subject: Re: ipvs: Pull out crosses_local_route_boundary logic
Date: Mon, 6 Oct 2014 16:32:32 +0900
Message-ID: <20141006073232.GA10073@verge.net.au>
References: <20141001174526.GA16206@mwanda>
 <alpine.LFD.2.11.1410012225530.3494@ja.home.ssi.bg>
 <5431D876.5020002@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5431D876.5020002@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Gartrell <agartrell@fb.com>
Cc: Julian Anastasov <ja@ssi.bg>, Dan Carpenter <dan.carpenter@oracle.com>, lvs-devel@vger.kernel.org

On Sun, Oct 05, 2014 at 04:47:02PM -0700, Alex Gartrell wrote:
> Hey everyone,
> 
> On 10/1/14 12:37 PM, Julian Anastasov wrote:
> >>    312				*ret_saddr = saddr;
> >>    313		}
> >>    314	
> >>    315		local = (rt->rt_flags & RTCF_LOCAL) ? 1 : 0;
> >>    316		if (unlikely(crosses_local_route_boundary(skb_af, skb, rt_mode,
> >>    317							  local))) {
> >>    318			IP_VS_DBG_RL("We are crossing local and non-local addresses"
> >>    319				     " daddr=%pI4\n", &dest->addr.ip);
> >>                                                        ^^^^^^^^^^^^^
> >
> >	Good catch. In fact, I requested Alex to print
> >daddr in this case but then we both missed this dest here...
> >Alex, both v4 (&daddr) and v6 (daddr) should be fixed.
> 
> It doesn't appear to me that there's been a patch for this yet.  I'll write
> one and send it out right away.  Please LMK if there's anyone else I should
> send it to.

I am following this thread so its not a big deal but in general please CC
me as well as Julian and lvs-devel on any patches you want considered for
inclusion in IPVS kernel code.

Thanks
