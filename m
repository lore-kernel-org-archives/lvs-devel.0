From: Chris J Arges <chris.j.arges@canonical.com>
Subject: Re: ip_vs: bug in ip_vs_out when CONFIG_IP_VS_IPV6 is enabled
Date: Fri, 22 Aug 2014 08:51:07 -0500
Message-ID: <53F74ACB.7060609@canonical.com>
References: <53F64C24.1080309@canonical.com> <alpine.LFD.2.11.1408212342280.1896@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.11.1408212342280.1896@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>



On 08/21/2014 05:22 PM, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 21 Aug 2014, Chris J Arges wrote:
> 
>> A bug was reported against our kernel, which looks to be an upstream
>> issue after some testing (as of 3.17-rc1).
>>
>> In short, it seems that using ip_vs with something like dnsmasq-tftp to
>> send data will cause the transfer to stop at some point where the read
>> will error giving EPERM. It was discovered that CONFIG_IP_VS_IPV6 was
>> the change that introduce this difference in behavor.
>>
>> The bug report is here:
>> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1349768
> 
> ...
> 
>> We've just recently enabled CONFIG_IP_VS_IPV6, which exposed this issue;
>> and the user is not using IPV6 functionality.
>>
>> I've traced through the code and found that this segment in
>> net/netfilter/ipvs/ip_vs_core.c
>> function ip_vs_out is what triggers this issue, if commented out the
>> problem does not occur:
>>
>> #ifdef CONFIG_IP_VS_IPV6
>>         if (af == AF_INET6) {
>>                 if (unlikely(iph.protocol == IPPROTO_ICMPV6)) {
>>                         int related;
>>                         int verdict = ip_vs_out_icmp_v6(skb, &related,
>>                                                         hooknum, &iph);
>>
>>                         if (related)
>>                                 return verdict;
>>                 }
>>         } else
>> #endif
>>
>> Printk'ing further into this, I see that ip_vs_out_icmp_v6 utimately
>> fails as frag_safe_skb_hp return NULL when packets are no longer being
>> sent with the test case.
> 
> 	Looking at the stack trace in your bug report it is
> strange to see ip_vs_local_reply6 called by ip_local_out (v4).
> It can also explain the ipv6_find_hdr errors, we are providing
> IPv4 packet to IPv6 code... OK, found it, my fault:
> 
> commit fc604767613b6d2036cdc35b660bc39451040a47
> Author: Julian Anastasov <ja@ssi.bg>
> Date:   Sun Oct 17 16:38:15 2010 +0300
> 
>     ipvs: changes for local real server
> 
> 	It is evident that ip_vs_local_reply6() is
> registered in PF_INET, not in PF_INET6. Later commit
> 4c809d630c17af0e8112d5362367ced9b44b009b
> renames it to NFPROTO_IPV4.
> 
>> Any suggestions for a fix for this issue, or a places to continue
>> looking? I'd be happy to continue hacking on this and provide testing.
> 
> 	IPPROTO_ICMPV6 is 58 (0x3A). Not sure how
> ipv6_find_hdr() finds it in some of the IPv4 packets,
> it is at offset 6 which is frag_off word in IPv4 header.
> In all other cases I think traffic is passed because
> it does not look like IPPROTO_ICMPV6. I think, it
> depends on IPPROTO_ICMPV6 being found in the header
> and the ipvsh->len which is again something wrong.
> 
> 	Please, try this patch and report for result:
> 
> [PATCH net] ipvs: fix ipv6 hook registration for local replies
> 
> From: Julian Anastasov <ja@ssi.bg>
> 
> commit fc604767613b6d2036cdc35b660bc39451040a47
> ("ipvs: changes for local real server") from 2.6.37
> introduced support for replies from local real server
> but the IPv6 handler ip_vs_local_reply6() is registered
> incorrectly as IPv4 hook leading to dropped traffic
> depending on IPv4 header values.
> 
> Reported-by: Chris J Arges <chris.j.arges@canonical.com>
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
>  net/netfilter/ipvs/ip_vs_core.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index e683675..5c34e8d 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -1906,7 +1906,7 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
>  	{
>  		.hook		= ip_vs_local_reply6,
>  		.owner		= THIS_MODULE,
> -		.pf		= NFPROTO_IPV4,
> +		.pf		= NFPROTO_IPV6,
>  		.hooknum	= NF_INET_LOCAL_OUT,
>  		.priority	= NF_IP6_PRI_NAT_DST + 1,
>  	},
> 

Julian,
My initial testing of this patch shows that it works. The test case
passes. Thanks!
--chris j arges

