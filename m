From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH ipvs 2/2] net: ipvs: sctp: do not recalc sctp checksum
 when not needed
Date: Sat, 26 Oct 2013 20:55:40 +0200
Message-ID: <526C102C.9040306@redhat.com>
References: <1af1d5e1aae9df91683625f0cb120b329e8d2f10.1382689350.git.dborkman@redhat.com> <8390127344501c35ed3c23f3690b8a671d353870.1382689350.git.dborkman@redhat.com> <alpine.LFD.2.03.1310252306230.1600@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.03.1310252306230.1600@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julian Anastasov <ja@ssi.bg>
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, linux-sctp@vger.kernel.org

On 10/25/2013 11:00 PM, Julian Anastasov wrote:
>
> 	Hello,
>
> On Fri, 25 Oct 2013, Daniel Borkmann wrote:
>
>> Unlike UDP or TCP, we do not take the pseudo-header into account
>> in SCTP checksums [1]. So in case port mapping is the very same, we
>> do not need to recalculate the whole SCTP checksum in software, which
>> is expensive.
>>
>> Also, similarly as in IPVS/TCP, take into account when a private
>> helper mangled the packet. In that case, we also need to recalculate
>> the checksum even if ports might be same.
>>
>>   [1] http://tools.ietf.org/html/rfc4960#section-6.8
>>
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>> ---
>>   net/netfilter/ipvs/ip_vs_proto_sctp.c | 30 ++++++++++++++++++++++++------
>>   1 file changed, 24 insertions(+), 6 deletions(-)
>>
>> diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
>> index 9ca7aa0..e56661e 100644
>> --- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
>> +++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
>> @@ -81,6 +81,7 @@ sctp_snat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
>>   {
>>   	sctp_sctphdr_t *sctph;
>>   	unsigned int sctphoff = iph->len;
>> +	bool payload_csum = false;
>>
>>   #ifdef CONFIG_IP_VS_IPV6
>>   	if (cp->af == AF_INET6 && iph->fragoffs)
>> @@ -92,19 +93,27 @@ sctp_snat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
>
> ...
>
>> -	sctp_nat_csum(skb, sctph, sctphoff);
>> +	/* Only update csum if we really have to */
>> +	if (sctph->source != cp->vport || payload_csum) {
>
> 	The above check should be little more complicated
> because local SCTP can decide to avoid setting ->checksum,
> there is a case when we can see CHECKSUM_PARTIAL for
> locally generated packets. And it happens both for
> requests (dnat_handler) and replies (snat_handler).
>
> 	I mean both places should be fixed because you can
> see in ip_vs_ops[] that in NF_INET_LOCAL_OUT we can call both
> snat_handler and dnat_handler.
>
> 	May be the simplest change can be to add check for
> !skb->dev to catch the LOCAL_OUT hook, so that we can
> perform full recalculation. We can further optimize this
> check for dnat_handler because the dnat_handler can look
> at the skb_dst()->dev->features as done by sctp_packet_transmit().
> The idea is that SCTP decides to avoid csum calculation
> if hardware supports offloading. IPVS can change the
> device after rerouting to real server but we can preserve
> the CHECKSUM_PARTIAL mode if the new device supports
> offloading too. This works because skb dst is changed
> before dnat_handler and we see the new device.
>
> 	For snat_handler it is more complex. skb contains
> the original route and ip_vs_route_me_harder() can change
> the route after snat_handler. So, for locally generated
> replies from local server we can not preserve the
> CHECKSUM_PARTIAL mode. It is an chicken or egg dilemma:
> snat_handler needs the device after rerouting (to
> check for NETIF_F_SCTP_CSUM), while ip_route_me_harder() wants
> the snat_handler() to put the new saddr for proper rerouting.
> So, for snat_handler we need just the !skb->dev check,
> sort of:
>
> 	if (sctph->source != cp->vport || payload_csum ||
> 	    (!skb->dev && skb->ip_summed == CHECKSUM_PARTIAL)) {
>
> 	But I have to think more whether we can preserve
> the ip_summed value in other cases, see skb_forward_csum()
> for reference.

Thanks for all your feedback Julian !

Let me think about this, and come back to you w/ a 2nd version
of the set at latest on Monday.

>> +		sctph->source = cp->vport;
>> +		sctp_nat_csum(skb, sctph, sctphoff);
>> +	}
>>
>>   	return 1;
>>   }
>
>> @@ -126,19 +136,27 @@ sctp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
>
> ...
>
>> -	sctp_nat_csum(skb, sctph, sctphoff);
>> +	/* Only update csum if we really have to */
>> +	if (sctph->dest != cp->dport || payload_csum) {
>
> 	Here we can can preserve CHECKSUM_PARTIAL after
> some checks, eg. when the new device in skb_dst supports
> offloading.
>
>> +		sctph->dest = cp->dport;
>> +		sctp_nat_csum(skb, sctph, sctphoff);
>> +	}
>>
>>   	return 1;
>>   }
>> --
>> 1.7.11.7
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
> --
> To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
