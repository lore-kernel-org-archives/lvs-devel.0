From: Chris J Arges <chris.j.arges@canonical.com>
Subject: Re: [PATCH net] ipvs: fix ipv6 hook registration for local replies
Date: Wed, 24 Sep 2014 09:55:11 -0500
Message-ID: <5422DB4F.5060900@canonical.com>
References: <1408719221-8042-1-git-send-email-ja@ssi.bg> <20140828015534.GE5936@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20140828015534.GE5936@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

On 08/27/2014 08:55 PM, Simon Horman wrote:
> On Fri, Aug 22, 2014 at 05:53:41PM +0300, Julian Anastasov wrote:
>> commit fc604767613b6d2036cdc35b660bc39451040a47
>> ("ipvs: changes for local real server") from 2.6.37
>> introduced DNAT support to local real server but the
>> IPv6 LOCAL_OUT handler ip_vs_local_reply6() is
>> registered incorrectly as IPv4 hook causing any outgoing
>> IPv4 traffic to be dropped depending on the IP header values.
>>
>> Chris tracked down the problem to CONFIG_IP_VS_IPV6=y
>> Bug report: https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1349768
>>
>> Reported-by: Chris J Arges <chris.j.arges@canonical.com>
>> Tested-by: Chris J Arges <chris.j.arges@canonical.com>
>> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> 
> Thanks, and sorry for the delay.
> I have queued this up in the ipvs tree as a fix for v3.17.
> I also plan to ask for it to be considered for -stable.
> 
Julian,
Has this been queued up for netdev stable? Or should I send an email?
Thanks,
--chris j arges

>> ---
>>  net/netfilter/ipvs/ip_vs_core.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
>> index e683675..5c34e8d 100644
>> --- a/net/netfilter/ipvs/ip_vs_core.c
>> +++ b/net/netfilter/ipvs/ip_vs_core.c
>> @@ -1906,7 +1906,7 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
>>  	{
>>  		.hook		= ip_vs_local_reply6,
>>  		.owner		= THIS_MODULE,
>> -		.pf		= NFPROTO_IPV4,
>> +		.pf		= NFPROTO_IPV6,
>>  		.hooknum	= NF_INET_LOCAL_OUT,
>>  		.priority	= NF_IP6_PRI_NAT_DST + 1,
>>  	},
>> -- 
>> 1.9.0
>>
> 
