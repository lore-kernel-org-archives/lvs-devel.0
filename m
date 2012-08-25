From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Multiple load balancers problem
Date: Sat, 25 Aug 2012 14:53:41 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1208251118260.1864@ja.ssi.bg>
References: <503880A4.6000801@stalker.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <503880A4.6000801@stalker.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dmitry Akindinov <dimak@stalker.com>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Sat, 25 Aug 2012, Dmitry Akindinov wrote:

> Hello,
> 
> We are currently stuck with the following ipvs problem:
> 
> 1. The configuration includes a (potentially large) set of servers providing
> various services - besides HTTP (POP, IMAP, LDAP, SMTP, XMPP, etc.) The test
> setup includes just 2 servers, though.
> 2. Each server runs a stock version of CentOS 6.0

	OK, I don't know what kernel and patches includes
every distribution. Can you tell at least what shows uname -a?

> 3. The application software (CommuniGate Pro) controls the ipvs kernel module
> using the ipvsadm commands.
> 4. On each server, iptables are configured to:
>   a) disable connection tracking for VIP address(es)
>   b) mark all packets coming to the VIP address(es) with the mark value of
> 100.
> 5. On the currently active load balancer, the ipvsadm is used to configure
> ipvs to load-balance packets with the marker 100:
> -A -f 100 -s rr -p 1
> -a -f 100 -r <server1> -g
> -a -f 100 -r <server2> -g
> ....
> where the active balancer itself is one of the <serverN>
> 6. All other servers (just 1 "other" server in our test config) are running
> ipvs, but with an empty rule set.

	I think, running slaves without same rules is a mistake.
When the slave receives sync message it has to assign it
to some virtual server and even assign real server for
this connection. But if this slave is also a real server
the things are complicated. I now check the code and
do not see where we prevent backup to schedule traffic
received from current master. The master gives the traffic
to backup because considers it a real server but this
backup with rules decides to schedule it to different real server.
This problem can not happen for NAT, only for DR/TUN,
I see that you are using DR forwarding method. So,
currently, IPVS users do not add ipvsadm rules in backup
for DR/TUN for this reason?

> 7. The active load balancer runs the sync daemon started with ipvsadm
> --start-daemon master
> 7. All other servers run the sync daemon started with ipvsadm --start-daemon
> backup.
> 
> As a result, all servers have the duplicated ipvs connection tables. If the
> active balancer fails, some other server assumes its role by arp-broadcasting
> VIP and loading the ipvs rule set listed above.

	In initial email you said:
"Now, we initiate a failover. During the failover, the ipvs table on the
old "active" balancer is cleared,"

	Why do you clear the connection table? What if you
decide after 10 seconds to return back control to the first
master?

> When a connection is being established to the VIP address, and the active load
> balancer directs it to itself, everything works fine.

	I assume you are talking for box 2 (the new master)

> When a connection is being established to the VIP address, and the active load
> balancer directs it to some other server, the connection is established fine,
> and if the protocol is POP, IMAP, SMTP, the server prompt is sent to the
> client via VIP, and it is seen by client just fine.

	You mean, new connection does 3-way handshake via
the new master to other real servers and succeeds, or already
established connection before the failover work after failover?
Is packet directed to old master?

> But when the client tries to send anything to the server, the packet
> (according to tcpdump) reaches the load balancer server, and from there it
> reaches the "other" server. Where the packet is dropped. The client resends
> that packet, it goes to the active balancer, then to the "other" server, and
> it is dropped again.

	Why this real server drops the packet? What is
different in this packet? Are you talking about connections
created before failover, that they can not continue to work after
failover? May be problem happens for DR. Can you show
tcpdump in old master that 3-way traffic is received and also
that it is replied by it, not by some real server.

	Problem can happen only if master sends new traffic to
backup (its real server). For example:

- master schedules SYN to real server which is backup with same rules
- SYNC conn is not sent before IPVS conn enters ESTABLISHED state,
so backup does not know for such connection, it looks like new one
- backup has rules, it decides to use real server 3 and
directs the SYN there. It can happen only for DR/TUN because
the daddr is VIP, that is why people overcome the problem
by checking that packet comes from some master and not
from uplink gateway MAC. For NAT there is no such double-step
scheduling because the backups' rules do not match the
internal real server IP in the daddr, they work only for VIP
- more traffic comes, backup directs it to real server 3
- the first SYNC message for this connection comes from
master but the SYNC message claims the backup is a real
server for this connection. Looking at current code,
ip_vs_proc_conn ignores the fact that master wants the
backup as real server for this connection, backup will
continue to use real server 3. For now, I don't see where
this can fail except if persistence comes in the game
or if failover happens to another backup which will use
real server 3. The result is that the backup acts as
balancer even if it is just a backup without master function.

> Observations:
> *) if ipvs is switched off on that "other" server, everything works just fine
> (service ipvsadm stop)

	So, someone stops the SYN traffic in backup?

> *) if ipvs is left running on that "other" server, but syncing daemon is
> switched off, everything works just fine.

	Without rules in this backup?

> We are 95% sure that the problem appears only if the "other server" ipvs
> connection table gets a copy of this
> connection from the active balancer. If the copy is not there (the sync daemon
> was stopped when the connection
> was established, and restarted immediately after), everything works just fine.

	Interesting, new master forwards to old master,
so it should send SYNC containing the old master as real
server, how can there be a problem, may be your kernel does
not support properly the local server function which is
fixed 2 years ago.

> *) the problem exists for protocols like POP, IMAP, SMTP - where the server
> immediately sends some data (prompt) to the client, as soon as the connection
> is established.

	The SYNC packets always go after the traffic, so
not sure why SYN will work while there will be difference for
other traffic. May be your kernel version reacts differently
when first SYNC message claims server 3 is the real server,
not backup 1 and the double-scheduling is broken after
3-way handshake.

> When the HTTP protocol is used, the problem does not exist, but only if the
> entire request is sent as one packet. If the HTTP connection is a "keep-alive"
> one, subsequent requests in the same connection do not reach the application
> either.
> I.e. it looks like the "idling" ipvs allows only one incoming data packet in,
> and only if there has been no outgoing packet on that connection yet.

	May be SYNC message changes the destination in
backup as I already said above? Some tcpdump output will
be helpful in case you don't know how to dig into the
sources of your kernel.

> *) Sometimes (we still cannot reproduce this reliably) the  ksoftirqd threads
> on the "other" server jump to 100% CPU
> utilization, and when it happens, it happens in reaction to one connection
> being established.

	This sounds as a problem fixed 2 years ago:

http://marc.info/?t=128428786100001&r=1&w=2

	At that time even fwmark was not supported for
sync purposes.

	Note that many changes happened in this 2 year
period, some for fwmark support for IPVS sync, some for
the 100% loops. Without knowing the kernel version
I'm not willing to flood you with changes that you
should check if they are present in your kernel if
it contains additional patches.

> Received suggestions:
> *) it was suggested that we use iptables to filter the packets to VIP that
> come from other servers in the farm (using their MAC addresses) and direct
> them directly to the local application, bypassing ipvs processing. We cannot
> do that, as servers in the farm can be added at any moment, and updating the
> list of MACs on all servers is not trivial. It may be easier to filter the
> packets that come from the router(s), which are less numerous and do not
> change that often.
> But it does not look like a good solution. If the ipvs table on "inactive"
> balancer drops packets, why would it stop dropping them when it becomes an
> "active" balancer? Just because there will be ipvs rules present?
> 
> *) The suggestion to separate load balancer(s) and real servers won't work for
> us at all.
> 
> *) We tried not to empty the ipvs table on the "other" server(s). Instead, we
> left it balancing - but with only one "real server" - this server itself. Now,
> the "active" load balancer dsitributes packets to itself and other servers,
> and when the packets hit the "other" server(s), they get to the ipvs again,
> where they are balanced again, but to the local server only.

	Very good, only that you need recent kernel for this,
2010-Nov +, there are fixes even after that time.

> It looks like it does solve the problem. But now the ipvs connection table on
> the "other" server(s) is filled by both that server ipvs itself and by the
> sync-daemon. While the locally-generated connection table entries should be
> the same as corresponding entries received with the sync daemon, it does not
> look good when the same table is modified from two sources.

	Sync happens only in one direction at a time, from
current master to current backup (it can be more than one).
The benefit is that all servers used for sync have same
table and you can switch between them at any time. Of
course, there is some performance price for traffic that
goes to the local stack of backups but they should get from
current master only traffic for their stack.

> Any comment, please? Should we use the last suggestion?

	I think, with fresh kernel your setup should be
supported. After showing the kernel version we can decide
for further steps. I'm not sure if we need to change kernel
not to schedule new connections for the BACKUP && !MASTER
configuration. By this way backup can have same rules
as backup which can work for DR/TUN. Without such change
we can not do role change without breaking connections
because the SYNC protocol declares real server 1 as
server while some backup overrides this decision and
uses real server 3, decision not known by other
potential masters.

> -- 
> Best regards,
> Dmitry Akindinov
> --

Regards

--
Julian Anastasov <ja@ssi.bg>
