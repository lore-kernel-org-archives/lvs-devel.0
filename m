From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [*v2 PATCH 00/22] IPVS, Network Name Space aware
Date: Wed, 15 Dec 2010 11:52:12 +0100
Message-ID: <1292410332.4983.321.camel@seasc0214>
References: <1292247510-753-1-git-send-email-hans.schillstrom@ericsson.com>
	 <alpine.LFD.2.00.1012150136410.2010@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1012150136410.2010@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: "horms@verge.net.au" <horms@verge.net.au>, "daniel.lezcano@free.fr" <daniel.lezcano@free.fr>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, "hans@schillstrom.com" <hans@schillstrom.com>

On Wed, 2010-12-15 at 00:43 +0100, Julian Anastasov wrote:
> 	Hello,
> 
> On Mon, 13 Dec 2010, Hans Schillstrom wrote:
[snip]
> >
> > Procfs ip_vs_stats is also changed to reflect the "per cpu"
> > ex.
> > # cat /proc/net/ip_vs_stats
> >       Total Incoming Outgoing         Incoming         Outgoing
> > CPU    Conns  Packets  Packets            Bytes            Bytes
> >  0        0        3        1               9D               34
> >  1        0        1        2               49               70
> >  2        0        1        2               34               76
> >  3        1        2        2               70               74
> >  ~        1        7        7              18A              18E
> >
> >     Conns/s   Pkts/s   Pkts/s          Bytes/s          Bytes/s
> >           0        0        0                0                0
> >
[snip]
> > Algorithm files are untouched except for lblc and lblcr.

> v2 PATCH 15/22 - ip_vs_stats
>  	- This was one of the hurdles for IPVS RCU conversion, the others
>  	being dest->svc->stats and scheduler state. But can this
>  	change break some scripts that parse /proc/net/ip_vs_stats ?
> 

Should I keep /proc/net/ip_vs_stats as it was before and add a new entry
like /proc/net/ip_vs_stats_percpu ?
(or maybe just skip the per cpu info ?)


Regards 
Hans Schillstrom <hans.schillstrom@ericsson.com>


