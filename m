From: Alexander Frolkin <avf@eldamar.org.uk>
Subject: Re: [PATCH] Sloppy TCP, SH rebalancing, SHP scheduling
Date: Fri, 24 May 2013 16:14:08 +0100
Message-ID: <20130524151408.GM264@eldamar.org.uk>
References: <20130524120935.GL264@eldamar.org.uk>
 <alpine.LFD.2.00.1305241633430.1636@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1305241633430.1636@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

Hi,

> > 1.  Sloppy TCP handling.  When enabled (net.ipv4.vs.sloppy_tcp=1,
> > default 0), it allows IPVS to create a TCP connection state on any TCP
> > packet, not just a SYN.  This allows connections to fail over to a
> > different director (our plan is to run multiple directors active-active)
> > without being reset.
> 	For most of the connectoins the backup server
> should get a sync messages in time, so it should be able
> to find existing connection in correct state, usually
> established. By using persistence the chances to
> hit the right real server in backup are increased.

We have a number of directors in active-active mode, we don't have any
kind of state sync.  My understanding is that the state sync daemon only
supports an active-backup configuration.  In our configuration it would
have to be sending out updates and receiving updates from other servers
at the same time.  Even if this works, we don't want a connection on one
server creating state on all the servers in the cluster, because that
would be a waste of memory most of the time.  Also, state sync
introduces a race condition which doesn't exist without state sync.

> 	The SH authors decided to change the mapping in SH
> table with destinations only when dest is added/removed
> but not when weight is set to 0. It is better not to
> complicate the SH scheduler, especially when more schedulers
> can be created.

Fair enough.  So if I create a new scheduler instead of hacking SH,
would that be more likely to be accepted?

> > 3. SHP (SH + port) scheduler.  This is a clone of the SH code, but
> > hacked to also take the port number (TCP, UDP, SCTP) into account.  This
> > may seem no different to round-robin, but in our scenario, if a
> > connection is failed over to a different director, this guarantees that
> > it will continue being forwarded to the same realserver.
> 	Is it a scenario where one client IP/net creates
> many connections that can influence the balancing and
> persistence can cause imbalance? Isn't persistence
> suitable? IIRC, it can do failover when expire_quiescent_template
> is enabled:

It's not about imbalance, it's just about running a number of
independent directors, with no state sync, but with the ability to fail
over from one to another.


Alex

