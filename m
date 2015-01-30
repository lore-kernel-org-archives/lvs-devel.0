From: Alex Gartrell <agartrell@fb.com>
Subject: Re: [PATCH net-next,v2] ipvs: orphan skb on LOCAL_IN path
Date: Thu, 29 Jan 2015 17:24:27 -0800
Message-ID: <54CADD4B.9080408@fb.com>
References: <1422566751-92285-1-git-send-email-agartrell@fb.com> <20150130010219.GD11897@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=message-id : date : from :
 mime-version : to : cc : subject : references : in-reply-to : content-type
 : content-transfer-encoding; s=facebook;
 bh=AoP7bxFO3x3lMlHEDjplEDrad1EZbir7is/nwcxWEsM=;
 b=UvsTVZD6ivNuosiv9mP4cpjwk89d/AjfTY557Ye+jAZN/DdzjiDwNT37yEGaqGPROTJP
 bW4XwqSOp/HRFX91EjgGvb/zQmnRgHM/v6VeWTY5kbASm+KXj1WicBFj1E2llJLIVBmn
 WO+g/EWjwbTa19/iqSPsdGzfkQERLZF8x0E= 
In-Reply-To: <20150130010219.GD11897@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Simon Horman <horms@verge.net.au>
Cc: wensong@linux-vs.org, ja@ssi.bg, lvs-devel@vger.kernel.org, kernel-team@fb.com

Hey Simon

On 01/29/2015 05:02 PM, Simon Horman wrote:
> Hi Alex,
>
> when you say "blow" what exactly happens? Does the kernel panic?
> Assuming this is a bug fix could you provide some information
> on when the problem was introduced? The reason is to facilitate
> backporting to stable.
>

The kernel panics upon a garbage value dereference.  ip6_skb_dst_mtu 
features the following code:

static inline int ip6_skb_dst_mtu(struct sk_buff *skb)
{
         struct ipv6_pinfo *np = skb->sk ? inet6_sk(skb->sk) : NULL;

         return (np && np->pmtudisc >= IPV6_PMTUDISC_PROBE) ?
                skb_dst(skb)->dev->mtu : dst_mtu(skb_dst(skb));
}

inet6_sk(skb->sk) expands to
inet_sk(skb->sk)->pinet6 which expands to
((struct inet_sock*)skb->sk)->pinet6

Because skb->sk is not actually an inet_sock, dereferencing at such is 
nonsense and gives you a bunch of fields as a pointer, which is totally 
bogus.  The dereference into the structure to retrieve pmtudisc causes a 
kernel panic after that.

We found this with our 3.10 porting effort (from 3.2).  This failure was 
introduced with early_demux in c7109986d "ipv6: Early TCP socket demux" 
(2012-07-26) and has been present since.  The underlying problem has 
existed forever, but it wasn't possible to trigger it (AFAICT) prior to 
that.

In terms of stable kernels, I believe 3.10 needs to be patched but 3.4 
does not.

Thanks,
-- 
Alex Gartrell <agartrell@fb.com>
