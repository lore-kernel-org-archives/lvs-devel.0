From: Simon Horman <horms@verge.net.au>
Subject: Re: [v2 PATCH 0/4] IPVS: Backup Adding Ipv6 and Persistence support
Date: Sat, 6 Nov 2010 23:34:05 +0900
Message-ID: <20101106143405.GB27212@verge.net.au>
References: <201010291415.35299.hans.schillstrom@ericsson.com>
 <alpine.LFD.2.00.1010301741280.2294@ja.ssi.bg>
 <20101030231601.GA5908@verge.net.au>
 <201011032108.07311.hans.schillstrom@ericsson.com>
 <20101106005614.GA11220@verge.net.au>
 <alpine.LFD.2.00.1011061543130.4009@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1011061543130.4009@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, LVS-Devel <lvs-devel@vger.kernel.org>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "daniel.lezcano@free.fr" <daniel.lezcano@free.fr>

On Sat, Nov 06, 2010 at 04:07:22PM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Sat, 6 Nov 2010, Simon Horman wrote:
> 
> >I wonder if we could just remove the modular aspect of persistence engines
> >as there is currently only one module and no plans on the drawing board
> >for any more at this time. That is, compile ip_vs_pe_sip directly
> >into ip_vs.ko
> 
> 	May be it is better svc to hold module refcnt for
> PE as currently implemented. If in backup the svc and dest
> are not found when creating connection with PE data then just
> ignore the connection.

As far as I understand, the svc and dest existing hasn't
really been a requirement for syncrhonisation, except in corner cases.
Personally I think thats a good thing. But making it a requirement
would certainly simplify things.

> The PE name must match the PE attached
> to svc (ip_vs_find_dest). This check must exist. The benefit
> comes from the fact that svc is freed after all its connections
> are freed, cp->dest->svc is always valid. Then there is no
> need for cp->pe. ip_vs_conn_hashkey_conn() has checks for
> cp->dest, so there is no point to try to create synced
> connections in backup with PE but without cp->dest.

But dest could be created as part of failover and thus
exist by the time any packets need to be forwarded, right?

There are cases, such as where the backup is also a real-server
that its rather inconvenient for svc and dst to exist while
synchronisation information is being received.

> 	The benefits:
> 
> - no cp->pe, it is not needed, the persistent scheduler
> gets PE from svc, i.e. PEs are needed only during
> scheduling, so svc, PE and dest are present
> 
> - PEs can be modular

These are clear wins. But I think that we need to think
carefully when deciding that svc and dest must exist
on the backup for successful synchronisation.


