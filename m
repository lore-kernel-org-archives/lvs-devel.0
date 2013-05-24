From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] Sloppy TCP, SH rebalancing, SHP scheduling
Date: Fri, 24 May 2013 18:05:18 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1305241633430.1636@ja.ssi.bg>
References: <20130524120935.GL264@eldamar.org.uk>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130524120935.GL264@eldamar.org.uk>
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
> I've added some features that I needed for our purposes to LVS, and I'd
> like to submit a patch, in case they might be useful to other users.
> 
> The patch is against the Ubuntu 12.04 kernel (3.2.0).

	I assume this is not intended for kernel inclusion :)

> The patch adds three features:
> 
> 1.  Sloppy TCP handling.  When enabled (net.ipv4.vs.sloppy_tcp=1,
> default 0), it allows IPVS to create a TCP connection state on any TCP
> packet, not just a SYN.  This allows connections to fail over to a
> different director (our plan is to run multiple directors active-active)
> without being reset.

	For most of the connectoins the backup server
should get a sync messages in time, so it should be able
to find existing connection in correct state, usually
established. By using persistence the chances to
hit the right real server in backup are increased.

> 2. SH rebalancing.  When enabled (net.ipv4.vs.sh_rebalance=1, default
> 0), virtual servers using SH (or SHP --- see below) scheduling will
> retry the realserver selection if the realserver selected the first time
> round is unavailable (e.g., because it has weight 0).  This allows
> realservers to be paused on SH(P) virtual servers by setting the weight
> to 0.

	The SH authors decided to change the mapping in SH
table with destinations only when dest is added/removed
but not when weight is set to 0. It is better not to
complicate the SH scheduler, especially when more schedulers
can be created.

> 3. SHP (SH + port) scheduler.  This is a clone of the SH code, but
> hacked to also take the port number (TCP, UDP, SCTP) into account.  This
> may seem no different to round-robin, but in our scenario, if a
> connection is failed over to a different director, this guarantees that
> it will continue being forwarded to the same realserver.

	Is it a scenario where one client IP/net creates
many connections that can influence the balancing and
persistence can cause imbalance? Isn't persistence
suitable? IIRC, it can do failover when expire_quiescent_template
is enabled:

Documentation/networking/ipvs-sysctl.txt

Regards

--
Julian Anastasov <ja@ssi.bg>
