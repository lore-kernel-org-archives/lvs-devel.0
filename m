From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: fix ipv6 icmp forwarding in natted services
Date: Wed, 19 Feb 2014 23:34:46 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1402192254040.1889@ja.home.ssi.bg>
References: <20140217153206.GC18029@telegraafnet.nl>  <20140217161601.GD18029@telegraafnet.nl>  <alpine.LFD.2.11.1402172321200.2420@ja.home.ssi.bg>  <20140218100533.GE18029@telegraafnet.nl>  <20140218133725.GA20771@telegraafnet.nl>  <20140218135439.GB20771@telegraafnet.nl>
  <alpine.LFD.2.11.1402182225560.2011@ja.home.ssi.bg>  <20140219102751.GD20771@telegraafnet.nl> <1392825857.5821.422.camel@hawk.mlab.se>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1392825857.5821.422.camel@hawk.mlab.se>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: Art -kwaak- van Breemen <ard@telegraafnet.nl>, Ansis Atteka <aatteka@nicira.com>, lvs-devel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, Hans Schillstrom <hans.schillstrom@ericsson.com>


	Hello,

On Wed, 19 Feb 2014, Hans Schillstrom wrote:

> The problem is if icmp6 is not the first header it will not work...
> i.e. it can be other headers before icmp and if you have -1 you will not
> always get the icmp header.
> 
> 
> The patch that broke it was:
> commit 9195bb8e381d81d5a315f911904cdf0cfcc919b8
> Author: Ansis Atteka <aatteka@nicira.com>
> 
> Before there was a 
> while (nexthdr != target) {
> ..
> }
> 
> now it's  
> 
> do {
> ..
> } while (!found)
> 
> which doesn't work for ipvs, when target is != -1
> 
> If you specify a target and it's the first header you should break.
> 
> I need to look deeper into the other users also to see that it doesn't
> break anything.
> 
> Ansis, I don't think it will break your patch or ?
> 
> 
> --- a/net/ipv6/exthdrs_core.c     2014-02-19 16:36:22.031686037 +0100
> +++ b/net/ipv6/exthdrs_core.c     2014-02-19 16:37:28.838082168 +0100
> @@ -211,6 +211,9 @@ int ipv6_find_hdr(const struct sk_buff *
>                 unsigned int hdrlen;
>                 found = (nexthdr == target);
>  
> +               if (found && (target > 0))
> +                       break;
> +

	This is against the goal of the above commit.

>                 if ((!ipv6_ext_hdr(nexthdr)) || nexthdr == NEXTHDR_NONE)
> {
>                         if (target < 0)
>                                 break;

	May be above check should be:

	if (target < 0 || found)
		break;

	We have to check some callers with -1, may be some
need check for NEXTHDR_NONE, for example, tproxy_tg6_v1(),
also the second call in hmark_pkt_set_htuple_ipv6(). Not sure
about nft_set_pktinfo_ipv6 and its callers.

Regards

--
Julian Anastasov <ja@ssi.bg>
