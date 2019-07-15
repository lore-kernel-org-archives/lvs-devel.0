From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] ipvs: remove unnecessary space
Date: Mon, 15 Jul 2019 10:27:47 +0200
Message-ID: <20190715082747.fdlpvekbqyhwx724@salvia>
References: <20190710074552.74394-1-xingwu.yang@gmail.com>
 <20190710080609.smxjqe2d5jyro4hv@verge.net.au>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20190710080609.smxjqe2d5jyro4hv@verge.net.au>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: yangxingwu <xingwu.yang@gmail.com>, wensong@linux-vs.org, ja@ssi.bg, kadlec@blackhole.kfki.hu, fw@strlen.de, davem@davemloft.net, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

On Wed, Jul 10, 2019 at 10:06:09AM +0200, Simon Horman wrote:
> On Wed, Jul 10, 2019 at 03:45:52PM +0800, yangxingwu wrote:
> > ---
> >  net/netfilter/ipvs/ip_vs_mh.c | 4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/net/netfilter/ipvs/ip_vs_mh.c b/net/netfilter/ipvs/ip_vs_mh.c
> > index 94d9d34..98e358e 100644
> > --- a/net/netfilter/ipvs/ip_vs_mh.c
> > +++ b/net/netfilter/ipvs/ip_vs_mh.c
> > @@ -174,8 +174,8 @@ static int ip_vs_mh_populate(struct ip_vs_mh_state *s,
> >  		return 0;
> >  	}
> >  
> > -	table =  kcalloc(BITS_TO_LONGS(IP_VS_MH_TAB_SIZE),
> > -			 sizeof(unsigned long), GFP_KERNEL);
> > +	table =	kcalloc(BITS_TO_LONGS(IP_VS_MH_TAB_SIZE),
> > +			sizeof(unsigned long), GFP_KERNEL);

May I ask one thing? :-)

Please, remove all unnecessary spaces in one go, search for:

        git grep "=  "

in the netfilter tree, and send a v2 for this one.

Thanks.
