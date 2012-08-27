From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Multiple load balancers problem
Date: Mon, 27 Aug 2012 14:17:27 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1208271313420.1934@ja.ssi.bg>
References: <503880A4.6000801@stalker.com> <alpine.LFD.2.00.1208251118260.1864@ja.ssi.bg> <503B2982.7010507@stalker.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <503B2982.7010507@stalker.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dmitry Akindinov <dimak@stalker.com>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Mon, 27 Aug 2012, Dmitry Akindinov wrote:

> > 	OK, I don't know what kernel and patches includes
> > every distribution. Can you tell at least what shows uname -a?
> 
> Ah, sorry. That was
> 
> [root@fm1 ~]# uname -a
> Linux fm1.***.com 2.6.32-71.el6.x86_64 #1 SMP Fri May 20 03:51:51 BST 2011
> x86_64 x86_64 x86_64 GNU/Linux

	I downloaded kernel-2.6.32-71.el6.src.rpm and I see
that it does not contain the needed changes to support
backup to be real server for DR/TUN:

commit fc604767613b6d2036cdc35b660bc39451040a47
Author: Julian Anastasov <ja@ssi.bg>
Date:   Sun Oct 17 16:38:15 2010 +0300

    ipvs: changes for local real server

	and to support fwmark for SYNC:

commit fe5e7a1efb664df0280f10377813d7099fb7eb0f
Author: Hans Schillstrom <hans.schillstrom@ericsson.com>
Date:   Fri Nov 19 14:25:12 2010 +0100

    IPVS: Backup, Adding Version 1 receive capability

    Functionality improvements
     * flags  changed from 16 to 32 bits
     * fwmark added (32 bits)
     * timeout in sec. added (32 bits)
     * pe data added (Variable length)
     * IPv6 capabilities (3x16 bytes for addr.)
     * Version and type in every conn msg.

> Yes, exactly. And to avoid this "secondary load balancing", we
> do not load the rules into ipvs until it becomes the active balancer.
> 
> Looks like it's causing problems, so the alternative we are using now
> is to load the rules, but make them balance everything to a single
> server - the local one.

	It seems even this is not enough because when
the backup receives the sync message it creates SYNC
connection (after passing the initial SYN and ACK) but
this connection claims this backup is a real server
and is using DR method. Without the commit 
fc604767613b6d2036cdc35b660bc39451040a47
when next packets come ip_vs_dr_xmit tries to send them
to LOCAL_OUT (DR forwarding) instead of returning
NF_ACCEPT as for LOCALNODE. As result, packet does not
reach local stack as the previous SYN and ACK packets
and may be you see that packet loops in the stack cuasing
100% CPU usage as you said below that it disappears:

> Now, we see the client trying to send some data to the server,
> and we see the data packet hitting the active load balancer,
> and then - the inactive load balancer. And there we see the
> packet disappearing - the application does not see it, and since
> there is not "ack" sent back to the client, we see the client
> TCP stack resending that packet over and over, but all resent
> packets have the same fate - they disappear inside the inactive
> load balancer.
> 
> We can send the actual tcpdumps if needed.

	Not needed, I think, you need kernel update.

> > directs the SYN there. It can happen only for DR/TUN because
> > the daddr is VIP, that is why people overcome the problem
> > by checking that packet comes from some master and not
> > from uplink gateway MAC. For NAT there is no such double-step
> > scheduling because the backups' rules do not match the
> > internal real server IP in the daddr, they work only for VIP
> 
> No, this is not the case. The backup balancer did not have rules,

	Yes, I just explained this variant too.

> > 	Interesting, new master forwards to old master,
> > so it should send SYNC containing the old master as real
> > server, how can there be a problem, may be your kernel does
> > not support properly the local server function which is
> > fixed 2 years ago.
> 
> Hmm. I assume the kernel we use is pretty fresh.

	I see ip_vs_conn.c from Sep 1  2010 is the latest
file from IPVS.

> > 	May be SYNC message changes the destination in
> > backup as I already said above? Some tcpdump output will
> > be helpful in case you don't know how to dig into the
> > sources of your kernel.
> 
> There is no change in destination. The dropped packets are really dropped, not
> relayed somewhere. Also, if they were relayed, they could only be relayed to
> the active balancer, as ipvs config only has or had these two servers in it.
> And tcpdump on the active balancer  properly shows the packets sent to the
> backup balancer, but no packets coming back from that balancer.

	Yes, may be they loop in stack: DR via LOCAL_OUT,
then they appear again in LOCAL_IN for forwarding?

> > 	Very good, only that you need recent kernel for this,
> > 2010-Nov +, there are fixes even after that time.
> 
> Yes, it looks like we have the kernels built in May-2011.

	Yep.

> > table and you can switch between them at any time. Of
> > course, there is some performance price for traffic that
> > goes to the local stack of backups but they should get from
> > current master only traffic for their stack.
> 
> That's not what concerns us. IPVS on the backup balancer is now
> being filled by 2 sources: the "sync" process, which copies records
> from the active balancer, and the IPVS itself.
> 
> I.e. now (when we have rules in the backup balancer, too) -
> when a new connection arrives to the backup balancer,
> the balancer creates a connection record and places it into its
> connection table.
> A few moments later, the sync daemon receives a connection
> record for the same connection from the active load balancer,
> and it also wants to put that record into the connection table
> on the backup balancer.
> Our concern is a potential conflict here: that record is already
> in the table. If you say that there can be no conflict - it would
> be nice, but we do not know how ipvs is designed, so we
> cannot get rid of that concern on our own.

	May be we should stop any forwarding while we are
in backup mode. The problem is that we can be both in
master and backup mode and I'm not sure if this is used
at all. I guess master and backup use different syncid but
anyways, may be such setup works only for NAT.

> When a backup balancer is instructed to become an active one,
> our application automatically loads the ruleset with all other
> real servers into its ipvs rule set, and then sends arp broadcast
> for all VIPs, switching the traffic to the new active balancer.
> 
> The existing connections should survive, as the connection table
> contains all the records sync'ed from the old active balancer, right?

	Yes.

> The interesting question is how ipvs assigns the connection records
> received via the sync protocol: as we have seen, we had to put the
> virt server and the local real server rules into ipvs in order to stop
> the problem of the "backup" mode.
> Now, during the failover, we add the rules for other "real servers"
> AFTER the connection records for their connections were received
> from the then-active balancer. Will it cause the same type of problem?

	Not fatal but without rules we can not maintain
actual counters for active/inactive conns. After failover
the setup will start with zeroed counters that are
later modified only for new connections, all SYNCed conns are
not accounted and the first minutes after failover we can
see some imbalance.

Regards

--
Julian Anastasov <ja@ssi.bg>
