From: Dmitry Akindinov <dimak@stalker.com>
Subject: Re: Multiple load balancers problem
Date: Mon, 27 Aug 2012 12:02:10 +0400
Message-ID: <503B2982.7010507@stalker.com>
References: <503880A4.6000801@stalker.com> <alpine.LFD.2.00.1208251118260.1864@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1208251118260.1864@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

Hello,

On 2012-08-25 15:53, Julian Anastasov wrote:
>
> 	Hello,
>
> On Sat, 25 Aug 2012, Dmitry Akindinov wrote:
>
>> Hello,
>>
>> We are currently stuck with the following ipvs problem:
>>
>> 1. The configuration includes a (potentially large) set of servers providing
>> various services - besides HTTP (POP, IMAP, LDAP, SMTP, XMPP, etc.) The test
>> setup includes just 2 servers, though.
>> 2. Each server runs a stock version of CentOS 6.0
>
> 	OK, I don't know what kernel and patches includes
> every distribution. Can you tell at least what shows uname -a?

Ah, sorry. That was

[root@fm1 ~]# uname -a
Linux fm1.***.com 2.6.32-71.el6.x86_64 #1 SMP Fri May 20 03:51:51 BST 
2011 x86_64 x86_64 x86_64 GNU/Linux


>> 3. The application software (CommuniGate Pro) controls the ipvs kernel module
>> using the ipvsadm commands.
>> 4. On each server, iptables are configured to:
>>    a) disable connection tracking for VIP address(es)
>>    b) mark all packets coming to the VIP address(es) with the mark value of
>> 100.
>> 5. On the currently active load balancer, the ipvsadm is used to configure
>> ipvs to load-balance packets with the marker 100:
>> -A -f 100 -s rr -p 1
>> -a -f 100 -r<server1>  -g
>> -a -f 100 -r<server2>  -g
>> ....
>> where the active balancer itself is one of the<serverN>
>> 6. All other servers (just 1 "other" server in our test config) are running
>> ipvs, but with an empty rule set.
>
> 	I think, running slaves without same rules is a mistake.
> When the slave receives sync message it has to assign it
> to some virtual server and even assign real server for
> this connection. But if this slave is also a real server
> the things are complicated. I now check the code and
> do not see where we prevent backup to schedule traffic
> received from current master. The master gives the traffic
> to backup because considers it a real server but this
> backup with rules decides to schedule it to different real server.

Yes, exactly. And to avoid this "secondary load balancing", we
do not load the rules into ipvs until it becomes the active balancer.

Looks like it's causing problems, so the alternative we are using now
is to load the rules, but make them balance everything to a single
server - the local one.

> This problem can not happen for NAT, only for DR/TUN,
> I see that you are using DR forwarding method. So,
> currently, IPVS users do not add ipvsadm rules in backup
> for DR/TUN for this reason?

Yes, please see above.

>> 7. The active load balancer runs the sync daemon started with ipvsadm
>> --start-daemon master
>> 7. All other servers run the sync daemon started with ipvsadm --start-daemon
>> backup.
>>
>> As a result, all servers have the duplicated ipvs connection tables. If the
>> active balancer fails, some other server assumes its role by arp-broadcasting
>> VIP and loading the ipvs rule set listed above.
>
> 	In initial email you said:
> "Now, we initiate a failover. During the failover, the ipvs table on the
> old "active" balancer is cleared,"
>
> 	Why do you clear the connection table? What if you
> decide after 10 seconds to return back control to the first
> master?

No, we do not clear the connection table, we clear the rule set,
to avoid the "double balancing" problem. Now, instead of clearing
the rule set completely, we simply remove from it all other servers,
leaving only the local one.


>> When a connection is being established to the VIP address, and the active load
>> balancer directs it to itself, everything works fine.
>
> 	I assume you are talking for box 2 (the new master)

Yes.

>> When a connection is being established to the VIP address, and the active load
>> balancer directs it to some other server, the connection is established fine,
>> and if the protocol is POP, IMAP, SMTP, the server prompt is sent to the
>> client via VIP, and it is seen by client just fine.
>
> 	You mean, new connection does 3-way handshake via
> the new master to other real servers and succeeds, or already
> established connection before the failover work after failover?
> Is packet directed to old master?

We have only tested new connections so far. We will now test how 
existing connections survive during failover, and we will report if 
there are problems there.

>> But when the client tries to send anything to the server, the packet
>> (according to tcpdump) reaches the load balancer server, and from there it
>> reaches the "other" server. Where the packet is dropped. The client resends
>> that packet, it goes to the active balancer, then to the "other" server, and
>> it is dropped again.
>
> 	Why this real server drops the packet? What is
> different in this packet? Are you talking about connections
> created before failover, that they can not continue to work after
> failover? May be problem happens for DR. Can you show
> tcpdump in old master that 3-way traffic is received and also
> that it is replied by it, not by some real server.

We ran tcpdump on both systems - the active balancer
and the inactive one. We saw all incoming packets properly
coming to the active balancer (so, no arp problems), and
we saw the active balancer directing some connections to the
inactive one: both the active and inactive balancers are the only
real servers in the ipvs config of the active balancer.

When we look at the connections directed by the active balancer
to the inactive one, we see the incoming packets reaching the
inactive balancer, and we see the inactive balancer (the application
on that server) receiving the connection. We see the application
sending the prompt message out, and we see (tcpdump) that
this packet goes out, directly to the client (to the router).

Now, we see the client trying to send some data to the server,
and we see the data packet hitting the active load balancer,
and then - the inactive load balancer. And there we see the
packet disappearing - the application does not see it, and since
there is not "ack" sent back to the client, we see the client
TCP stack resending that packet over and over, but all resent
packets have the same fate - they disappear inside the inactive
load balancer.

We can send the actual tcpdumps if needed.

> 	Problem can happen only if master sends new traffic to
> backup (its real server). For example:
>
> - master schedules SYN to real server which is backup with same rules
> - SYNC conn is not sent before IPVS conn enters ESTABLISHED state,
> so backup does not know for such connection, it looks like new one
> - backup has rules, it decides to use real server 3 and
> directs the SYN there. It can happen only for DR/TUN because
> the daddr is VIP, that is why people overcome the problem
> by checking that packet comes from some master and not
> from uplink gateway MAC. For NAT there is no such double-step
> scheduling because the backups' rules do not match the
> internal real server IP in the daddr, they work only for VIP

No, this is not the case. The backup balancer did not have rules,
so it could not schedule the packet to some server 3. Also, the
"sync" exchange, which happens when there is no connection table record
yet, works just fine. Packets are dropped only after/when the connection
record appears in the inactive load balancer (via sync'ing with
the active balancer).

> - more traffic comes, backup directs it to real server 3
> - the first SYNC message for this connection comes from
> master but the SYNC message claims the backup is a real
> server for this connection. Looking at current code,
> ip_vs_proc_conn ignores the fact that master wants the
> backup as real server for this connection, backup will
> continue to use real server 3. For now, I don't see where
> this can fail except if persistence comes in the game
> or if failover happens to another backup which will use
> real server 3. The result is that the backup acts as
> balancer even if it is just a backup without master function.

Again, it was not the case. It looks like (as you have specified 
initially), that if there is a connection record (received from the 
active balancer), the inactive (backup) balancer must assign it to some 
local ipvs rule.
In our case, the rule set on the backup balancer was empty, and that
drove ipvs there mad, and somehow resulted in it dropping the packets
belonging to this "orphan" connection.

When we added 2 rules to "inactive/backup" ipvs, one for the virt server 
and one for the only real server - the local server, the problem has 
disappeared.

>> Observations:
>> *) if ipvs is switched off on that "other" server, everything works just fine
>> (service ipvsadm stop)
>
> 	So, someone stops the SYN traffic in backup?

SYN negotiations worked fine. The problem started AFTER the SYN exchange
was over. Here is a theory (most likely, a wrong one ;-) ):

  during SYN exchange, a connection record does not exist (as you've
  mentioned), so SYN exchange works fine.
  after SYN exchange, a connection record is created on the active
  balancer and sent to the backup balancer where is entered into its
  table.
  when the application on the backup balancer sends the prompt out, the
  client receives it, and sends back the ACK packet.
  The ACK packet goes to the active balancer, and from there - to the
  backup one.
  Upon receiving this FIRST packet for the newly created connection
  record, ipvs marks that record somehow, but lets this packet throw,
  the local TCP stack gets it, so it does not resend the application
  prompt.
  Now, when the client sends its data, it comes to the backup balancer
  via the active balancer.
  The ipvs module sees that this packet is directed to the connection
  record it already has, and that connection record is "marked" somehow
  by the first packet and this mark forces ipvs to drop this and the
  following data packets.

  If the TCP protocol used does not include a server prompt (HTTP, for
  example), then the fist data packet the client sends does reach the
  application. But it also marks the connection record somehow, so all
  subsequent packets are dropped.

As soon as we have added the records to ipvs on the backup balancer,
the problem has disappeared.

>> *) if ipvs is left running on that "other" server, but syncing daemon is
>> switched off, everything works just fine.
>
> 	Without rules in this backup?

Yes. When there is no syncing, the backup balancer works just fine -
i.e. it does not do anything and does not interfere with the traffic in 
any way.

>> We are 95% sure that the problem appears only if the "other server" ipvs
>> connection table gets a copy of this
>> connection from the active balancer. If the copy is not there (the sync daemon
>> was stopped when the connection
>> was established, and restarted immediately after), everything works just fine.
>
> 	Interesting, new master forwards to old master,
> so it should send SYNC containing the old master as real
> server, how can there be a problem, may be your kernel does
> not support properly the local server function which is
> fixed 2 years ago.

Hmm. I assume the kernel we use is pretty fresh.

>> *) the problem exists for protocols like POP, IMAP, SMTP - where the server
>> immediately sends some data (prompt) to the client, as soon as the connection
>> is established.
>
> 	The SYNC packets always go after the traffic, so
> not sure why SYN will work while there will be difference for
> other traffic. May be your kernel version reacts differently
> when first SYNC message claims server 3 is the real server,
> not backup 1 and the double-scheduling is broken after
> 3-way handshake.

There is no 3rd server anywhere in the config. Please see our theory
above.

>> When the HTTP protocol is used, the problem does not exist, but only if the
>> entire request is sent as one packet. If the HTTP connection is a "keep-alive"
>> one, subsequent requests in the same connection do not reach the application
>> either.
>> I.e. it looks like the "idling" ipvs allows only one incoming data packet in,
>> and only if there has been no outgoing packet on that connection yet.
>
> 	May be SYNC message changes the destination in
> backup as I already said above? Some tcpdump output will
> be helpful in case you don't know how to dig into the
> sources of your kernel.

There is no change in destination. The dropped packets are really 
dropped, not relayed somewhere. Also, if they were relayed, they could 
only be relayed to the active balancer, as ipvs config only has or had 
these two servers in it.
And tcpdump on the active balancer  properly shows the packets sent to 
the backup balancer, but no packets coming back from that balancer.

>> *) Sometimes (we still cannot reproduce this reliably) the  ksoftirqd threads
>> on the "other" server jump to 100% CPU
>> utilization, and when it happens, it happens in reaction to one connection
>> being established.
>
> 	This sounds as a problem fixed 2 years ago:
>
> http://marc.info/?t=128428786100001&r=1&w=2

Yes, our kernel may be susceptible to this problem

> 	At that time even fwmark was not supported for
> sync purposes.
>
> 	Note that many changes happened in this 2 year
> period, some for fwmark support for IPVS sync, some for
> the 100% loops. Without knowing the kernel version
> I'm not willing to flood you with changes that you
> should check if they are present in your kernel if
> it contains additional patches.
>
>> Received suggestions:
>> *) it was suggested that we use iptables to filter the packets to VIP that
>> come from other servers in the farm (using their MAC addresses) and direct
>> them directly to the local application, bypassing ipvs processing. We cannot
>> do that, as servers in the farm can be added at any moment, and updating the
>> list of MACs on all servers is not trivial. It may be easier to filter the
>> packets that come from the router(s), which are less numerous and do not
>> change that often.
>> But it does not look like a good solution. If the ipvs table on "inactive"
>> balancer drops packets, why would it stop dropping them when it becomes an
>> "active" balancer? Just because there will be ipvs rules present?
>>
>> *) The suggestion to separate load balancer(s) and real servers won't work for
>> us at all.
>>
>> *) We tried not to empty the ipvs table on the "other" server(s). Instead, we
>> left it balancing - but with only one "real server" - this server itself. Now,
>> the "active" load balancer dsitributes packets to itself and other servers,
>> and when the packets hit the "other" server(s), they get to the ipvs again,
>> where they are balanced again, but to the local server only.
>
> 	Very good, only that you need recent kernel for this,
> 2010-Nov +, there are fixes even after that time.

Yes, it looks like we have the kernels built in May-2011.

>> It looks like it does solve the problem. But now the ipvs connection table on
>> the "other" server(s) is filled by both that server ipvs itself and by the
>> sync-daemon. While the locally-generated connection table entries should be
>> the same as corresponding entries received with the sync daemon, it does not
>> look good when the same table is modified from two sources.
>
> 	Sync happens only in one direction at a time, from
> current master to current backup (it can be more than one).
> The benefit is that all servers used for sync have same
> table and you can switch between them at any time. Of
> course, there is some performance price for traffic that
> goes to the local stack of backups but they should get from
> current master only traffic for their stack.

That's not what concerns us. IPVS on the backup balancer is now
being filled by 2 sources: the "sync" process, which copies records
from the active balancer, and the IPVS itself.

I.e. now (when we have rules in the backup balancer, too) -
when a new connection arrives to the backup balancer,
the balancer creates a connection record and places it into its
connection table.
A few moments later, the sync daemon receives a connection
record for the same connection from the active load balancer,
and it also wants to put that record into the connection table
on the backup balancer.
Our concern is a potential conflict here: that record is already
in the table. If you say that there can be no conflict - it would
be nice, but we do not know how ipvs is designed, so we
cannot get rid of that concern on our own.


>> Any comment, please? Should we use the last suggestion?
>
> 	I think, with fresh kernel your setup should be
> supported. After showing the kernel version we can decide
> for further steps. I'm not sure if we need to change kernel
> not to schedule new connections for the BACKUP&&  !MASTER
> configuration. By this way backup can have same rules
> as backup which can work for DR/TUN. Without such change
> we can not do role change without breaking connections
> because the SYNC protocol declares real server 1 as
> server while some backup overrides this decision and
> uses real server 3, decision not known by other
> potential masters.

We now keep the IPVS rule set on backup balancer(s) with
just 2 records: a virt server and one real server - the local one.
All connections the backup balancers get (from the active one)
are directed to their local applications, so they are properly
"balanced".

When a backup balancer is instructed to become an active one,
our application automatically loads the ruleset with all other
real servers into its ipvs rule set, and then sends arp broadcast
for all VIPs, switching the traffic to the new active balancer.

The existing connections should survive, as the connection table
contains all the records sync'ed from the old active balancer, right?

The interesting question is how ipvs assigns the connection records
received via the sync protocol: as we have seen, we had to put the
virt server and the local real server rules into ipvs in order to stop
the problem of the "backup" mode.
Now, during the failover, we add the rules for other "real servers"
AFTER the connection records for their connections were received
from the then-active balancer. Will it cause the same type of problem?

We will test failovers now, and we will report.

-- 
Best regards,
Dmitry Akindinov -- Stalker Labs.
