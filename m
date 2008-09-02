From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCHv2 RFC 16/25] IPVS: Add/adjust Netfilter hook functions and helpers for v6
Date: Tue, 2 Sep 2008 15:34:20 +0200
Message-ID: <f4845fc0809020634l7e19f6abn7892bcb9cf12fee2@mail.gmail.com>
References: <1220273782-19901-1-git-send-email-juliusv@google.com>
	 <1220273782-19901-17-git-send-email-juliusv@google.com>
	 <20080902074049.GH13730@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220362463; bh=dyBR2Y6UPdGJfKL8K6gnkvOJ3Yo=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=EiMIFcL4u2/Re/xQeWlk91fTUCA2u2fn
	GRYLC9t3QqoMSg+vuUduQKvT0ZRSMdCqZKD2O3jpnS7qVeDgTvI9WA==
In-Reply-To: <20080902074049.GH13730@verge.net.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com

On Tue, Sep 2, 2008 at 9:40 AM, Simon Horman <horms@verge.net.au> wrote:
> On Mon, Sep 01, 2008 at 02:56:13PM +0200, Julius Volz wrote:
>> Add Netfilter hook functions or modify existing ones, if possible, to
>> process IPv6 packets. Some support functions are also added/modified for
>> this. ip_vs_nat_icmp_v6() was already added in the patch that added the v6
>> xmit functions, as it is called from one of them.
>>
>> Signed-off-by: Julius Volz <juliusv@google.com>
>
> Please run checkpatch.pl over this patch.
>
>>  1 files changed, 326 insertions(+), 36 deletions(-)
>>
>> diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
>> index 8bfd7c2..0bf871c 100644
>> --- a/net/ipv4/ipvs/ip_vs_core.c
>> +++ b/net/ipv4/ipvs/ip_vs_core.c
>> @@ -39,6 +39,11 @@
>>  #include <linux/netfilter.h>
>>  #include <linux/netfilter_ipv4.h>
>>
>> +#ifdef CONFIG_IP_VS_IPV6
>> +#include <net/ipv6.h>
>> +#include <linux/netfilter_ipv6.h>
>> +#endif
>> +
>>  #include <net/ip_vs.h>
>>
>>
>> @@ -60,6 +65,7 @@ EXPORT_SYMBOL(ip_vs_get_debug_level);
>>
>>  /* ID used in ICMP lookups */
>>  #define icmp_id(icmph)          (((icmph)->un).echo.id)
>> +#define icmpv6_id(icmph)        (icmph->icmp6_dataun.u_echo.identifier)
>
> Should this be ((icmph)->icmp6_dataun.u_echo.identifier) ?

Ah yeah, that is safer, thanks!

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
