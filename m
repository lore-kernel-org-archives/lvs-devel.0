From: Alexander Frolkin <avf@eldamar.org.uk>
Subject: Re: [PATCH] Sloppy TCP, SH rebalancing, SHP scheduling
Date: Fri, 7 Jun 2013 09:12:52 +0100
Message-ID: <20130607081252.GC11902@eldamar.org.uk>
References: <20130524120935.GL264@eldamar.org.uk>
 <alpine.LFD.2.00.1305241633430.1636@ja.ssi.bg>
 <20130524151408.GM264@eldamar.org.uk>
 <alpine.LFD.2.00.1305272251170.1728@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1305272251170.1728@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

Hi,

> 	OTOH, the difference is very small: the port.
> The problem is that we add only global controls, it
> would be good if we can configure such parameters
> per virtual service:
> - use port in source hash

Well, this one can be configured per service by changing the scheduler.
Or are you concerned about the fact that the code for SHP and SH is
essentially the same and should be merged?

> 	The problem here is that we call ip_vs_service_find()
> after checking th->syn. So, may be it is better to have
> global sysctl flag here, as in your patch.

I don't think a global sysctl is a problem for sloppy TCP (SCTP).  I
think it's unlikely that you'll want to enable it on one service but not
on another.

> IP_VS_SVC_F_SCHED1: scheduler flag 1 (SH: fallback to other dest if 
> weight=0), i.e. the sh_rebalance flag
> IP_VS_SVC_F_SCHED2: scheduler flag 1 (SH: add port in hash)
> IP_VS_SVC_F_SCHED3: scheduler flag 2 (SH: consider mask/plen)

This isn't a bad idea, and it will probably find other uses, too.

Is there a reason why the SH fallback behaviour shouldn't be default?
That is, is there a reason why the current behaviour (client connection
gets reset if it is directed to a realserver with weight 0) is
desirable?

> 	Note that latest SH version supports weights and
> RCU, you have to consider it for next patch versions.

I'll take a look at the latest version.


Alex

