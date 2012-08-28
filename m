From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2] ipvs: Extend MTU check to account for IPv6 NAT defrag
 changes
Date: Tue, 28 Aug 2012 10:22:05 +0200 (MEST)
Message-ID: <Pine.GSO.4.63.1208281020530.18770@stinky-local.trash.net>
References: <20120827144024.5754.23872.stgit@dragon> <20120827144059.5754.55303.stgit@dragon>
 <alpine.LFD.2.00.1208271810070.24809@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1208271810070.24809@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Hans Schillstrom <hans@schillstrom.com>, Wensong Zhang <wensong@linux-vs.org>, netfilter-devel@vger.kernel.org

On Mon, 27 Aug 2012, Julian Anastasov wrote:

>
> 	Hello,
>
> On Mon, 27 Aug 2012, Jesper Dangaard Brouer wrote:
>
>> This patch is necessary, to make IPVS work, after Patrick McHardys
>> IPv6 NAT defragmentation changes.
>>
>> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
>> ---
>>
>> I would appriciate, if someone (e.g. Julian) double check the tunnel mode code.
>
> 	Sure
>
>> --Jesper
>>
>>  net/netfilter/ipvs/ip_vs_xmit.c |   16 +++++++++++++---
>>  1 files changed, 13 insertions(+), 3 deletions(-)
>>
>> @@ -956,8 +963,11 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
>>  		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, mtu);
>>
>>  	/* MTU checking: Special for tunnel mode */
>> -	if (mtu < ntohs(old_iph->payload_len) + sizeof(struct ipv6hdr) &&
>> -	    !skb_is_gso(skb)) {
>> +	if ((!IP6CB(skb)->frag_max_size &&
>> +	     (mtu < ntohs(old_iph->payload_len) + sizeof(struct ipv6hdr) &&
>> +	      !skb_is_gso(skb)))
>> +	    || IP6CB(skb)->frag_max_size + sizeof(struct ipv6hdr) > mtu) {
>> +
>
> 	mtu is already reduced with the new outer header size,
> may be we can just call __mtu_check_toobig_v6 with mtu?
>
>>  		if (!skb->dev) {
>>  			struct net *net = dev_net(skb_dst(skb)->dev);
>
> 	All other changes in patch 1 and 2 look ok and
> I'll ack them next time.

I'd like to take the final patches through my nat-ipv6 tree in order
to avoid temporary regressions. Please let me know when they're ready
for applying.
