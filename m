From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [v2 PATCH 0/4] IPVS: Backup Adding Ipv6 and Persistence
 support
Date: Sat, 6 Nov 2010 20:57:11 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1011061959370.5280@ja.ssi.bg>
References: <201010291415.35299.hans.schillstrom@ericsson.com> <alpine.LFD.2.00.1010301741280.2294@ja.ssi.bg> <20101030231601.GA5908@verge.net.au> <201011032108.07311.hans.schillstrom@ericsson.com> <20101106005614.GA11220@verge.net.au>
 <alpine.LFD.2.00.1011061543130.4009@ja.ssi.bg> <20101106143405.GB27212@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20101106143405.GB27212@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, LVS-Devel <lvs-devel@vger.kernel.org>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "daniel.lezcano@free.fr" <daniel.lezcano@free.fr>


 	Hello,

On Sat, 6 Nov 2010, Simon Horman wrote:

>> 	May be it is better svc to hold module refcnt for
>> PE as currently implemented. If in backup the svc and dest
>> are not found when creating connection with PE data then just
>> ignore the connection.
>
> As far as I understand, the svc and dest existing hasn't
> really been a requirement for syncrhonisation, except in corner cases.
> Personally I think thats a good thing. But making it a requirement
> would certainly simplify things.

 	I mean, requirement only for connections with PE data.
But lets leave it this way, so that we can support deferred
binding to dest.

>> The PE name must match the PE attached
>> to svc (ip_vs_find_dest). This check must exist. The benefit
>> comes from the fact that svc is freed after all its connections
>> are freed, cp->dest->svc is always valid. Then there is no
>> need for cp->pe. ip_vs_conn_hashkey_conn() has checks for
>> cp->dest, so there is no point to try to create synced
>> connections in backup with PE but without cp->dest.
>
> But dest could be created as part of failover and thus
> exist by the time any packets need to be forwarded, right?
>
> There are cases, such as where the backup is also a real-server
> that its rather inconvenient for svc and dst to exist while
> synchronisation information is being received.

 	OK, then we should not reach request_module,
new arg to ip_vs_pe_get() can specify that we call it
from interrupt, so the PE must be already loaded as module.
Then cp->pe can hold the reference to PE until
we bind the template to svc and dest where svc->pe
should be compared to ct->pe. ct->pe is needed only
for this purpose because later it can be determined
from svc. But I see another problem which is not backup
specific: how ip_vs_sip_ct_match knows that ct->pe_data
is created by ip_vs_sip_fill_param and not by another PE?
We need to compare p->pe with cp->pe in ip_vs_ct_in_get
before calling ct_match.

Regards

--
Julian Anastasov <ja@ssi.bg>
