From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net] ipvs: sctp: fix checksumming by adding hardware offload
 support
Date: Tue, 05 Feb 2013 09:54:18 +0100
Message-ID: <5110C8BA.4080205@redhat.com>
References: <cover.1359997089.git.dborkman@redhat.com> <916047bfad2e27385c15954a71e9462bb2f828f2.1359997089.git.dborkman@redhat.com> <alpine.LFD.2.00.1302042349350.1869@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1302042349350.1869@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julian Anastasov <ja@ssi.bg>
Cc: horms@verge.net.au, mohanreddykv@gmail.com, pablo@netfilter.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-sctp@vger.kernel.org

On 02/05/2013 12:27 AM, Julian Anastasov wrote:
> On Mon, 4 Feb 2013, Daniel Borkmann wrote:
>
>> In our test lab, we have a simple SCTP client connecting to a SCTP
>> server via an IPVS load balancer. On some machines, load balancing
>> works, but on others the initial handshake just fails, thus no
>> SCTP connection whatsoever can be established.
>>
>> We observed that the SCTP INIT-ACK handshake reply from the IPVS
>> machine to the client had a correct IP checksum, but corrupt SCTP
>> checksum when forwarded, thus on the client-side the packet was
>> dropped and an intial handshake retriggered until all attempts
>> run into the void.
>
> 	Hm, may be packet is received with CHECKSUM_PARTIAL
> value? Is it a virtual NIC or a real NIC with the
> forwarding problem?

Thanks for your feedback!

The setup was about ...

  SCTP Client <--> IPVS Balancer <--> SCTP Server
  172.16.100.2    172.16.100.1(eth1)  192.168.100.11
                 192.168.100.1(eth2)

... where eth1 on IPVS uses the igb driver, which in fact seems to
support NETIF_F_SCTP_CSUM.

Interestingly, the path from the client to the server had no checksum
issues (no errors on the server in /proc/net/sctp/snmp), but on the
way back however from IPVS onwards to the client, the checksum is
wrong. With turned off SCTP checksum validation on the client side it
works obviously.

I think your hint might be correct to set

  skb->ip_summed = CHECKSUM_UNNECESSARY;

since this is also done in ip_vs_proto_tcp.c after a full checksum
calculation. I will come back to your questions resp. with a version 2
of the patch a bit later after doing some experiments.

>> This patch fixes the problem by taking hardware offload features
>> of the NIC into account (which was just ignored here), similar as
>
> 	So, if NIC has no such support the bug remains?
> Why it works for some boxes? Where is the difference in
> the RX devices? GRO? skb->ip_summed?
>
>> done in the SCTP checksumming code itself. Also, while at it,
>> the checksum is in little-endian format (as fixed in commit 458f04c:
>> sctp: Clean up sctp checksumming code). Tested by myself.
>
> 	I don't feel such optimization can work in all cases.
> skb->dev is NULL in LOCAL_OUT hook (NAT via loopback).
> For dnat_handler skb->dev can be present but it is an old
> value. The new skb->dst value is prepared by ip_vs_nat_xmit
> but is still not set. For snat_handler the ip_vs_route_me_harder()
> can reroute, for example, when traffic from different VIPs
> use their own ISP link (another device).
>
> 	Even if we provide the new dst to IPVS nat handlers,
> later a netfilter rule can change the path and reroute the
> packet to different device. As result, I'm not sure
> CHECKSUM_PARTIAL is handled properly for SCTP in
> dev_hard_start_xmit and skb_checksum_help for the
> case where we are rerouted to device without hw csum
> support. skb_checksum_help supports only csum in 16 bits.
>
> 	Also, skb_transport_header is not updated yet,
> IPVS runs before such protocols, i.e. in LOCAL_IN, while
> ip_local_deliver_finish (where iphdr is skipped) is
> called after all handlers in this hook. It is not
> valid for FORWARD hook (for the snat_handler case).
> Still, the sctphoff value is present and can be used
> instead.
>
> 	May be you can instead test a change that adds a
> missing skb->ip_summed = CHECKSUM_UNNECESSARY in
> both handlers, including a change for the
> mentioned commit for endian format. May be crc32 should
> be changed from __be32 to __u32 and using the
> sctph->checksum = sctp_end_cksum(crc32) variant?
> I hope it will fix the wrong checksum in forwarding path
> if it is caused by the wrong ip_summed value.
>
>> Cc: Venkata Mohan Reddy <mohanreddykv@gmail.com>
>> Cc: Simon Horman <horms@verge.net.au>
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>> ---
>>   net/netfilter/ipvs/ip_vs_proto_sctp.c | 41 ++++++++++++++++++++---------------
>>   1 file changed, 23 insertions(+), 18 deletions(-)
>>
>> diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
>> index 746048b..dc41622 100644
>> --- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
>> +++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
>> @@ -61,14 +61,33 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
>>   	return 1;
>>   }
>>
>> +static void sctp_nat_csum(struct sk_buff *skb, sctp_sctphdr_t *sctph,
>> +			  unsigned int sctphoff)
>> +{
>> +	struct sk_buff *iter;
>> +
>> +	/* Calculate the checksum */
>> +	if (!(skb->dev->features & NETIF_F_SCTP_CSUM)) {
>> +		__u32 crc32 = sctp_start_cksum((__u8 *)sctph,
>> +					       skb_headlen(skb) - sctphoff);
>> +		skb_walk_frags(skb, iter)
>> +			crc32 = sctp_update_cksum((u8 *) iter->data,
>> +						  skb_headlen(iter), crc32);
>> +		sctph->checksum = sctp_end_cksum(crc32);
>> +	} else {
>> +		/* no need to seed pseudo checksum for SCTP */
>> +		skb->ip_summed = CHECKSUM_PARTIAL;
>> +		skb->csum_start = (skb_transport_header(skb) - skb->head);
>> +		skb->csum_offset = offsetof(struct sctphdr, checksum);
>> +	}
>> +}
>> +
>>   static int
>>   sctp_snat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
>>   		  struct ip_vs_conn *cp, struct ip_vs_iphdr *iph)
>>   {
>>   	sctp_sctphdr_t *sctph;
>>   	unsigned int sctphoff = iph->len;
>> -	struct sk_buff *iter;
>> -	__be32 crc32;
>>
>>   #ifdef CONFIG_IP_VS_IPV6
>>   	if (cp->af == AF_INET6 && iph->fragoffs)
>> @@ -92,13 +111,7 @@ sctp_snat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
>>   	sctph = (void *) skb_network_header(skb) + sctphoff;
>>   	sctph->source = cp->vport;
>>
>> -	/* Calculate the checksum */
>> -	crc32 = sctp_start_cksum((u8 *) sctph, skb_headlen(skb) - sctphoff);
>> -	skb_walk_frags(skb, iter)
>> -		crc32 = sctp_update_cksum((u8 *) iter->data, skb_headlen(iter),
>> -				          crc32);
>> -	crc32 = sctp_end_cksum(crc32);
>> -	sctph->checksum = crc32;
>> +	sctp_nat_csum(skb, sctph, sctphoff);
>>
>>   	return 1;
>>   }
>> @@ -109,8 +122,6 @@ sctp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
>>   {
>>   	sctp_sctphdr_t *sctph;
>>   	unsigned int sctphoff = iph->len;
>> -	struct sk_buff *iter;
>> -	__be32 crc32;
>>
>>   #ifdef CONFIG_IP_VS_IPV6
>>   	if (cp->af == AF_INET6 && iph->fragoffs)
>> @@ -134,13 +145,7 @@ sctp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
>>   	sctph = (void *) skb_network_header(skb) + sctphoff;
>>   	sctph->dest = cp->dport;
>>
>> -	/* Calculate the checksum */
>> -	crc32 = sctp_start_cksum((u8 *) sctph, skb_headlen(skb) - sctphoff);
>> -	skb_walk_frags(skb, iter)
>> -		crc32 = sctp_update_cksum((u8 *) iter->data, skb_headlen(iter),
>> -					  crc32);
>> -	crc32 = sctp_end_cksum(crc32);
>> -	sctph->checksum = crc32;
>> +	sctp_nat_csum(skb, sctph, sctphoff);
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
>
