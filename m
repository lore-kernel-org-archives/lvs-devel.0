From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] Sloppy TCP, SH rebalancing, SHP scheduling
Date: Tue, 28 May 2013 00:11:19 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1305272251170.1728@ja.ssi.bg>
References: <20130524120935.GL264@eldamar.org.uk> <alpine.LFD.2.00.1305241633430.1636@ja.ssi.bg> <20130524151408.GM264@eldamar.org.uk>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130524151408.GM264@eldamar.org.uk>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alexander Frolkin <avf@eldamar.org.uk>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Fri, 24 May 2013, Alexander Frolkin wrote:

> Hi,
> 
> > > 1.  Sloppy TCP handling.  When enabled (net.ipv4.vs.sloppy_tcp=1,
> > > default 0), it allows IPVS to create a TCP connection state on any TCP
> > > packet, not just a SYN.  This allows connections to fail over to a
> > > different director (our plan is to run multiple directors active-active)
> > > without being reset.
> > 	For most of the connectoins the backup server
> > should get a sync messages in time, so it should be able
> > to find existing connection in correct state, usually
> > established. By using persistence the chances to
> > hit the right real server in backup are increased.
> 
> We have a number of directors in active-active mode, we don't have any
> kind of state sync.  My understanding is that the state sync daemon only
> supports an active-backup configuration.  In our configuration it would
> have to be sending out updates and receiving updates from other servers
> at the same time.  Even if this works, we don't want a connection on one
> server creating state on all the servers in the cluster, because that
> would be a waste of memory most of the time.  Also, state sync
> introduces a race condition which doesn't exist without state sync.

	ok, I have to think more days about the
effects from sloppy_tcp. May be this logic is useful
also for SCTP.

> > 	The SH authors decided to change the mapping in SH
> > table with destinations only when dest is added/removed
> > but not when weight is set to 0. It is better not to
> > complicate the SH scheduler, especially when more schedulers
> > can be created.
> 
> Fair enough.  So if I create a new scheduler instead of hacking SH,
> would that be more likely to be accepted?

	OTOH, the difference is very small: the port.
The problem is that we add only global controls, it
would be good if we can configure such parameters
per virtual service:

- use port in source hash
- use source netmask for source address - similar to the
netmask used by persistence

	Not sure what solution is better. May be we
can add some IP_VS_SVC_F_SCHED1..N definitions to
parametrize the schedulers. As for the netmask, one
variant is to reuse the persistent mask/plen. For
example:

IP_VS_SVC_F_OPEN (or other name): sloppy_tcp/sloppy_sctp

	The problem here is that we call ip_vs_service_find()
after checking th->syn. So, may be it is better to have
global sysctl flag here, as in your patch.

IP_VS_SVC_F_SCHED1: scheduler flag 1 (SH: fallback to other dest if 
weight=0), i.e. the sh_rebalance flag

IP_VS_SVC_F_SCHED2: scheduler flag 1 (SH: add port in hash)

IP_VS_SVC_F_SCHED3: scheduler flag 2 (SH: consider mask/plen)

	Note that latest SH version supports weights and
RCU, you have to consider it for next patch versions.

	sh_rebalance can become sh_fallback if not
done with IP_VS_SVC_F_SCHED1. May be SHP is not needed
if SH is parametrized.

	Comments?

	Also, you have to check the coding style rules:
Documentation/CodingStyle

- there are lines above 80 chars
- '||' must not be first in line

# scripts/checkpatch.pl /tmp/ocado-ipvs.patch
gives more warnings.

Regards

--
Julian Anastasov <ja@ssi.bg>
