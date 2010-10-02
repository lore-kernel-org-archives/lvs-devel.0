From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch v2 03/12] [PATCH 03/12] IPVS: compact
 ip_vs_sched_persist()
Date: Sat, 2 Oct 2010 17:08:50 +0900
Message-ID: <20101002080850.GC2248@verge.net.au>
References: <20101001143517.645421976@akiko.akashicho.tokyo.vergenet.net>
 <20101001143941.949669349@akiko.akashicho.tokyo.vergenet.net>
 <alpine.LFD.2.00.1010020129400.2462@ja.ssi.bg>
 <20101002022050.GA16593@verge.net.au>
 <alpine.LFD.2.00.1010021048260.1814@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1010021048260.1814@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org, Jan Engelhardt <jengelh@medozas.de>, Stephen Hemminger <shemminger@vyatta.com>, Wensong Zhang <wensong@linux-vs.org>, Patrick McHardy <kaber@trash.net>

On Sat, Oct 02, 2010 at 10:56:19AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Sat, 2 Oct 2010, Simon Horman wrote:
> 
> >>	Here dport:
> >>
> >>>+	dport = dest->port;
> >>
> >>	should be:
> >>
> >>	dport = ports[1];
> >>	if (dport == svc->port && dest->port)
> >>		dport = dest->port;
> >
> >Thanks, fixed.
> 
> 	I'm still wondering, may be it needs separate patch
> but we do not support NAT to different dest->port in the
> case for fwmark. May be the above logic can be changed to
> support it. By this way web to different VIPs and VPORTs
> in a single virtual service (fwmark) can use single NAT
> real server for name-based virtual hosting. But such change
> can create compatibility problems for setups that used
> different vports for the fwmark service and still expect
> it in that way (vport to same dport).

Hi Julian,

I think that this sounds line a new flavour of fwmark virtual services to me.
Perhaps yet another flag is in order?

To be clear, what you have in mind is essentially to nat *:* (as matched by
a fwmark) to x:y, where as at this time *:y may be natted to x:y.

