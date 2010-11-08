From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [v2 PATCH 0/4] IPVS: Backup Adding Ipv6 and Persistence
 support
Date: Mon, 8 Nov 2010 10:51:58 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1011081027080.1504@ja.ssi.bg>
References: <201010291415.35299.hans.schillstrom@ericsson.com> <alpine.LFD.2.00.1010301741280.2294@ja.ssi.bg> <20101030231601.GA5908@verge.net.au> <201011032108.07311.hans.schillstrom@ericsson.com> <20101106005614.GA11220@verge.net.au>
 <alpine.LFD.2.00.1011061543130.4009@ja.ssi.bg> <20101106143405.GB27212@verge.net.au> <alpine.LFD.2.00.1011061959370.5280@ja.ssi.bg> <20101108062121.GA17685@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20101108062121.GA17685@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, LVS-Devel <lvs-devel@vger.kernel.org>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "daniel.lezcano@free.fr" <daniel.lezcano@free.fr>


 	Hello,

On Mon, 8 Nov 2010, Simon Horman wrote:

>>> But dest could be created as part of failover and thus
>>> exist by the time any packets need to be forwarded, right?
>>>
>>> There are cases, such as where the backup is also a real-server
>>> that its rather inconvenient for svc and dst to exist while
>>> synchronisation information is being received.
>>
>> 	OK, then we should not reach request_module,
>> new arg to ip_vs_pe_get() can specify that we call it
>> from interrupt, so the PE must be already loaded as module.
>> Then cp->pe can hold the reference to PE until
>> we bind the template to svc and dest where svc->pe
>> should be compared to ct->pe. ct->pe is needed only
>> for this purpose because later it can be determined
>> from svc.
>
> Do you have a preference for this approach
> over making ip_vs_pe_sip non-modular?

 	We already decided about "IPVS: Add persistence engine to 
connection entry", so cp->pe should be attached to backup
and I hope Hans will add checks for same PE in ip_vs_find_dest
and ip_vs_try_bind_dest. Then the only problem remains
to change code so that request_module is not called by
softirq. If the svc is not created yet in backup to
load the PE module, it must be loaded manually to
allow connections with PE to be created. If you still
prefer to see some code I have to create fresh tree later
today. May be if Hans uses ip_vs_pe_getbyname instead of
ip_vs_pe_get that should solve the request_module problem.

 	What should we do if PE module is not loaded
while we are creating connection in backup? We can not
load modules, may be when connection is bound to
dest+svc we should inherit the PE from svc->pe ?
May be using request_module_nowait is not an option
because we risk to try forever if module is not
present.

>> But I see another problem which is not backup
>> specific: how ip_vs_sip_ct_match knows that ct->pe_data
>> is created by ip_vs_sip_fill_param and not by another PE?
>> We need to compare p->pe with cp->pe in ip_vs_ct_in_get
>> before calling ct_match.
>
> Yes, I agree that is a problem.
>
> In practice it won't be affecting anyone at this time
> as there is only one pe.
>
> How about this, which applies on top of
> "IPVS: Add persistence engine to connection entry".

 	Yes, it is fine

Signed-off-by: Julian Anastasov <ja@ssi.bg>

> From: Simon Horman <horms@verge.net.au>
> Subject: IPVS: Only match pe_data created by the same pe
>
> Only match persistence engine data if it was
> created by the same persistence engine.
>
> Reported-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Simon Horman <horms@verge.net.au>
>
> Index: lvs-test-2.6/net/netfilter/ipvs/ip_vs_conn.c
> ===================================================================
> --- lvs-test-2.6.orig/net/netfilter/ipvs/ip_vs_conn.c	2010-11-08 15:18:57.000000000 +0900
> +++ lvs-test-2.6/net/netfilter/ipvs/ip_vs_conn.c	2010-11-08 15:19:02.000000000 +0900
> @@ -354,7 +354,7 @@ struct ip_vs_conn *ip_vs_ct_in_get(const
>
> 	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
> 		if (p->pe_data && p->pe->ct_match) {
> -			if (p->pe->ct_match(p, cp))
> +			if (p->pe == cp->pe && p->pe->ct_match(p, cp))
> 				goto out;
> 			continue;
> 		}

Regards

--
Julian Anastasov <ja@ssi.bg>
