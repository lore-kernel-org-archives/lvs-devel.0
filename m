From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [v2 PATCH 0/4] IPVS: Backup Adding Ipv6 and Persistence
 support
Date: Sat, 6 Nov 2010 16:07:22 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1011061543130.4009@ja.ssi.bg>
References: <201010291415.35299.hans.schillstrom@ericsson.com> <alpine.LFD.2.00.1010301741280.2294@ja.ssi.bg> <20101030231601.GA5908@verge.net.au> <201011032108.07311.hans.schillstrom@ericsson.com> <20101106005614.GA11220@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20101106005614.GA11220@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, LVS-Devel <lvs-devel@vger.kernel.org>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "daniel.lezcano@free.fr" <daniel.lezcano@free.fr>


 	Hello,

On Sat, 6 Nov 2010, Simon Horman wrote:

> I wonder if we could just remove the modular aspect of persistence engines
> as there is currently only one module and no plans on the drawing board
> for any more at this time. That is, compile ip_vs_pe_sip directly
> into ip_vs.ko

 	May be it is better svc to hold module refcnt for
PE as currently implemented. If in backup the svc and dest
are not found when creating connection with PE data then just
ignore the connection. The PE name must match the PE attached
to svc (ip_vs_find_dest). This check must exist. The benefit
comes from the fact that svc is freed after all its connections
are freed, cp->dest->svc is always valid. Then there is no
need for cp->pe. ip_vs_conn_hashkey_conn() has checks for
cp->dest, so there is no point to try to create synced
connections in backup with PE but without cp->dest.

 	The benefits:

- no cp->pe, it is not needed, the persistent scheduler
gets PE from svc, i.e. PEs are needed only during
scheduling, so svc, PE and dest are present

- PEs can be modular

Regards

--
Julian Anastasov <ja@ssi.bg>
