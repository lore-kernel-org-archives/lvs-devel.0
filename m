From: Calvin Owens <calvinowens@fb.com>
Subject: Re: [PATCH] ipvs: Keep skb->sk when allocating headroom on tunnel
 xmit
Date: Fri, 7 Nov 2014 14:12:13 -0800
Message-ID: <545D43BD.8030203@fb.com>
References: <1415147860-11389-1-git-send-email-calvinowens@fb.com> <alpine.LFD.2.11.1411051048540.1631@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=message-id : date : from :
 mime-version : to : cc : subject : references : in-reply-to : content-type
 : content-transfer-encoding; s=facebook;
 bh=vLPlPaHl6QC3e8x19G/Q+7NDIQTGYHU1Ia90cwggXX4=;
 b=HrzGKU/OVEmhJ+zeo0JH+cI4HwvWmuxjU9r1KBuFesjTZyIDQg9TZpoGWtspMCzwCNd1
 b0hkdnK/ISdSTmYg7KJnwvfyKhH83GPhEZ+IT/1cZSoqT/3C6rnttNcyVMrUCK90quJv
 i5PF/5L033jxX29fb570mSUU7B0CUTZwWJc= 
In-Reply-To: <alpine.LFD.2.11.1411051048540.1631@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, agartrell@fb.com, kernel-team@fb.com

On 11/05/2014 01:21 AM, Julian Anastasov wrote:
>
> 	Hello,
>
> On Tue, 4 Nov 2014, Calvin Owens wrote:
>
>> ip_vs_prepare_tunneled_skb() ignores ->sk when allocating a new
>> skb, either unconditionally setting ->sk to NULL or allowing
>> the uninitialized ->sk from a newly allocated skb to leak through
>> to the caller.
>>
>> This patch properly copies ->sk and increments its reference count.
>>
>> Signed-off-by: Calvin Owens <calvinowens@fb.com>
>
> 	Good catch. Please, extend your patch to
> fix also the second place that has such error,
> ip_vs_tunnel_xmit_v6. This call is missing from long time,
> it was not needed. But commits that allow skb->sk (local
> clients) already need it, eg.

I'm not sure where exactly you mean: ip_vs_tunnel_xmit_v6() calls
ip_vs_prepare_tunneled_skb() to do the allocation, so this patch covers 
that case.

In older versions of the kernel, ip_vs_tunnel_xmit_v6() does it 
directly, could that be what you're looking at?

> - f2428ed5e7bc89c7 ("ipvs: load balance ipv6 connections from a local
> process"), 2.6.28
> - 4856c84c1358b798 ("ipvs: load balance IPv4 connections from a local
> process"), 2.6.28
>
>> ---
>>   net/netfilter/ipvs/ip_vs_xmit.c | 2 ++
>>   1 file changed, 2 insertions(+)
>>
>> diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
>> index 437a366..bd90bf8 100644
>> --- a/net/netfilter/ipvs/ip_vs_xmit.c
>> +++ b/net/netfilter/ipvs/ip_vs_xmit.c
>> @@ -846,6 +846,8 @@ ip_vs_prepare_tunneled_skb(struct sk_buff *skb, int skb_af,
>>   		new_skb = skb_realloc_headroom(skb, max_headroom);
>>   		if (!new_skb)
>>   			goto error;
>> +		if (skb->sk)
>> +			skb_set_owner_w(new_skb, skb->sk);
>>   		consume_skb(skb);
>>   		skb = new_skb;
>>   	}
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
>
