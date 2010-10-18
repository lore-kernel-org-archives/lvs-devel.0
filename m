From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [RFC PATCH 1/9] ipvs network name space aware
Date: Mon, 18 Oct 2010 16:26:34 +0200
Message-ID: <4CBC591A.1000105@free.fr>
References: <201010081316.46690.hans.schillstrom@ericsson.com> <201010181154.35792.hans.schillstrom@ericsson.com> <4CBC3182.80605@free.fr> <201010181523.49568.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <201010181523.49568.hans.schillstrom@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, "horms@verge.net.au" <horms@verge.net.au>, "ja@ssi.bg" <ja@ssi.bg>, "wensong@linux-vs.org" <wensong@linux-vs.org>

On 10/18/2010 03:23 PM, Hans Schillstrom wrote:
> On Monday 18 October 2010 13:37:38 Daniel Lezcano wrote:
>    
>> On 10/18/2010 11:54 AM, Hans Schillstrom wrote:
>>      
>>> On Monday 18 October 2010 10:59:25 Daniel Lezcano wrote:
>>>
>>>        
>>>> On 10/08/2010 01:16 PM, Hans Schillstrom wrote:
>>>>
>>>>          
>>>>> This part contains the include files
>>>>> where include/net/netns/ip_vs.h is new and contains all moved vars.
>>>>>
>>>>> SUMMARY
>>>>>
>>>>>     include/net/ip_vs.h                     |  136 ++++---
>>>>>     include/net/net_namespace.h             |    2 +
>>>>>     include/net/netns/ip_vs.h               |  112 +++++
>>>>>
>>>>> Signed-off-by:Hans Schillstrom<hans.schillstrom@ericsson.com>
>>>>> ---
>>>>>
>>>>>
>>>>>
>>>>>            
>>>> [ ... ]
>>>>
>>>>
>>>>          
>>>>>     #ifdef CONFIG_IP_VS_IPV6
>>>>> diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
>>>>> index bd10a79..b59cdc5 100644
>>>>> --- a/include/net/net_namespace.h
>>>>> +++ b/include/net/net_namespace.h
>>>>> @@ -15,6 +15,7 @@
>>>>>     #include<net/netns/ipv4.h>
>>>>>     #include<net/netns/ipv6.h>
>>>>>     #include<net/netns/dccp.h>
>>>>> +#include<net/netns/ip_vs.h>
>>>>>     #include<net/netns/x_tables.h>
>>>>>     #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
>>>>>     #include<net/netns/conntrack.h>
>>>>> @@ -91,6 +92,7 @@ struct net {
>>>>>     	struct sk_buff_head	wext_nlevents;
>>>>>     #endif
>>>>>     	struct net_generic	*gen;
>>>>> +	struct netns_ipvs       *ipvs;
>>>>>     };
>>>>>
>>>>>
>>>>>            
>>>> IMHO, it would be better to use the net_generic infra-structure instead
>>>> of adding a new field in the netns structure.
>>>>
>>>>
>>>>
>>>>          
>>> I realized that to, but the performance penalty is quite high with net_generic :-(
>>> But on the other hand if you are going to backport it, (without recompiling the kernel)
>>> you gonna need it!
>>>
>>>        
>> Hmm, yes. We don't want to have the init_net_ns performances to be impacted.
>>
>> You use here a pointer which will be dereferenced like the net_generic,
>> I don't think there will be
>> a big difference between using net_generic and using a pointer in the
>> net namespace structure.
>>
>> The difference is the id usage, but this one is based on the idr which
>> is quite fast.
>>
>>      
> I'm not so sure about that, have a look at net_generic and rcu_read_lock
> and compare
>   ipvs = net->ipvs;
> vs.
>   ipvs = net_generic(net, id)
>
> static inline void *net_generic(struct net *net, int id)
> {
> 	struct net_generic *ng;
> 	void *ptr;
>
> 	rcu_read_lock();
> 	ng = rcu_dereference(net->gen);
> 	BUG_ON(id == 0 || id>  ng->len);
> 	ptr = ng->ptr[id - 1];
> 	rcu_read_unlock();
>
> 	return ptr;
> }
> ...
> static inline void rcu_read_lock(void)
> {
>          __rcu_read_lock();
>          __acquire(RCU);
>          rcu_read_acquire();
> }
>    

Yep, right. In fact I don't really like the net_generic and an ipvs ptr. 
I am not sure it is adequate for this component.

> Another way of doing it is to pass the ipvs ptr instead of the net ptr,
> and add *net to the ipvs struct.
>
>    
>> We should experiment a bit here to compare both solutions.
>>      
> Agre
>    
>>      
> I single stepped through the rcu_read_lock() on a x86_64
> and it's quite many "stepi" that you need to enter :-(
>
>    
>> IMHO, we can (1) create a non-pointer netns_ipvs field in the net
>> namespace structure or (2) use a pointer [with net_generic].
>>
>> (1) is the faster but with the drawback of having a bigger memory
>> footprint even if the ipvs module is not loaded.
>> In this case we have to take care of what we store in the netns_ipvs
>> structure, that is reduce the per namespace table and so. At the first
>> glance, I think we can reduce this to the sysctls and a very few data,
>> for example using global tables tagged with the namespace and we don't
>> break the cacheline alignment optimization.
>>
>> (2) is slower but as the memory is allocated and freed when the module
>> is loaded/unloaded. What I don't like with this approach is we add some
>> overhead even if the netns is not compiled in the kernel.
>>
>>      
> or (3)
>   Like (1) with data that needs to be cache aligned in "struct net"
>   and the rest in an ipvs struct.
>    

Ah, right. That could be a nice solution.


>   Global hash tables or not ?
>    

In the past, we used global hash tables because of the cacheline miss.
