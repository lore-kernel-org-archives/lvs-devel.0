From: Dmitry Akindinov <dimak@stalker.com>
Subject: Re: Multiple load balancers problem
Date: Mon, 27 Aug 2012 19:15:02 +0400
Message-ID: <503B8EF6.5040609@stalker.com>
References: <503880A4.6000801@stalker.com> <alpine.LFD.2.00.1208251118260.1864@ja.ssi.bg> <503B2982.7010507@stalker.com> <alpine.LFD.2.00.1208271313420.1934@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1208271313420.1934@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

Hello,

Sorry for top posting: doing this to avoid clutter below.

Thank you for your assistance. Let me to summarize the current 
situation, after all the changes and testing.

1. The test system consists of two servers, S1 and S2. Both running 
CentOS 6.0:

  [root@fm1 ~]# uname -a
  Linux fm1.***.com 2.6.32-71.el6.x86_64 #1 SMP Fri May 20 03:51:51 BST 2011
  x86_64 x86_64 x86_64 GNU/Linux

We are now setting up new boxes (CentOS 6.3) to re-test with newer kernels

2. Both systems have iptables configured to mark the traffic to VIP with 
the "100" marker.

3. At the beginning of the test,
IPSV on S1 configuration is:
-A -f 100 -s rr -p 1
-a -f 100 -r S1:0 -g -w 100
-a -f 100 -r S2:0 -g -w 100

IPSV on S2 configuration is:
-A -f 100 -s rr -p 1
-a -f 100 -r S1:0 -g -w 0
-a -f 100 -r S2:0 -g -w 100

We establish test connections from client systems to the port 110 of 
VIP, the S1 routes one connection to itself, the other one to S2. Both 
connections are alive and well, the connection tables on both systems 
are the same due to ipsv syncing daemons:

ipsvadm -l -c -n:
IP  00:49  NONE        C1:0    0.0.0.100:0        S1:0
TCP 14:49  ESTABLISHED C1:54837 VIP:110   S1:110
TCP 14:43  ESTABLISHED C2:54648 VIP:110   S2:110
IP  00:43  NONE       C2:0   0.0.0.100:0         S2:0

Now, we initiate a failover, so S2 becomes the active balancer.
The IPSV rules on S2 are updated, so they become the same as they were 
on S1:
-A -f 100 -s rr -p 1
-a -f 100 -r S1:0 -g -w 100
-a -f 100 -r S2:0 -g -w 100

And S1 gets the same config as S2 used before the failover.

All the connections that existed on S2 before failover continue to work.

But the connections that existed on S1 are closed as soon as the client 
sends any data to that connection. The tcpdump on S1 does not show any 
incoming packets, and tcpdump on S2 shows that it's S2 itself (a new 
load balancer) that closes these connections (the data the client has 
sent was "HELP\r\n" - 6 bytes):

07:54:59.214200 IP (tos 0x10, ttl 54, id 20406, offset 0, flags [DF], 
proto TCP (6), length 58)
     C1.54837 > VIP.110: Flags [P.], cksum 0xba0d (correct), seq 
3572724860:3572724866, ack 1018696840, win 33304, options [nop,nop,TS 
val 3371318384 ecr 1243703099], length 6
07:54:59.214253 IP (tos 0x10, ttl 64, id 0, offset 0, flags [DF], proto 
TCP (6), length 40)
     VIP.110 > C1.54837: Flags [R], cksum 0x5767 (correct), seq 
1018696840, win 0, length 0

What can cause the new load balancer to reset (Flags [R.]) the existing 
connections to the "old" balancer?

New connections now work fine, being distributed by the new load 
balancer to itself and to the old balancer.


On 2012-08-27 15:17, Julian Anastasov wrote:
>
> 	Hello,
>
> On Mon, 27 Aug 2012, Dmitry Akindinov wrote:
>
>>> 	OK, I don't know what kernel and patches includes
>>> every distribution. Can you tell at least what shows uname -a?
>>
>> Ah, sorry. That was
>>
>> [root@fm1 ~]# uname -a
>> Linux fm1.***.com 2.6.32-71.el6.x86_64 #1 SMP Fri May 20 03:51:51 BST 2011
>> x86_64 x86_64 x86_64 GNU/Linux
>
> 	I downloaded kernel-2.6.32-71.el6.src.rpm and I see
> that it does not contain the needed changes to support
> backup to be real server for DR/TUN:
>
> commit fc604767613b6d2036cdc35b660bc39451040a47
> Author: Julian Anastasov<ja@ssi.bg>
> Date:   Sun Oct 17 16:38:15 2010 +0300
>
>      ipvs: changes for local real server
>
> 	and to support fwmark for SYNC:
>
> commit fe5e7a1efb664df0280f10377813d7099fb7eb0f
> Author: Hans Schillstrom<hans.schillstrom@ericsson.com>
> Date:   Fri Nov 19 14:25:12 2010 +0100
>
>      IPVS: Backup, Adding Version 1 receive capability
>
>      Functionality improvements
>       * flags  changed from 16 to 32 bits
>       * fwmark added (32 bits)
>       * timeout in sec. added (32 bits)
>       * pe data added (Variable length)
>       * IPv6 capabilities (3x16 bytes for addr.)
>       * Version and type in every conn msg.
>
>> Yes, exactly. And to avoid this "secondary load balancing", we
>> do not load the rules into ipvs until it becomes the active balancer.
>>
>> Looks like it's causing problems, so the alternative we are using now
>> is to load the rules, but make them balance everything to a single
>> server - the local one.
>
> 	It seems even this is not enough because when
> the backup receives the sync message it creates SYNC
> connection (after passing the initial SYN and ACK) but
> this connection claims this backup is a real server
> and is using DR method. Without the commit
> fc604767613b6d2036cdc35b660bc39451040a47
> when next packets come ip_vs_dr_xmit tries to send them
> to LOCAL_OUT (DR forwarding) instead of returning
> NF_ACCEPT as for LOCALNODE. As result, packet does not
> reach local stack as the previous SYN and ACK packets
> and may be you see that packet loops in the stack cuasing
> 100% CPU usage as you said below that it disappears:
>
>> Now, we see the client trying to send some data to the server,
>> and we see the data packet hitting the active load balancer,
>> and then - the inactive load balancer. And there we see the
>> packet disappearing - the application does not see it, and since
>> there is not "ack" sent back to the client, we see the client
>> TCP stack resending that packet over and over, but all resent
>> packets have the same fate - they disappear inside the inactive
>> load balancer.
>>
>> We can send the actual tcpdumps if needed.
>
> 	Not needed, I think, you need kernel update.
>
>>> directs the SYN there. It can happen only for DR/TUN because
>>> the daddr is VIP, that is why people overcome the problem
>>> by checking that packet comes from some master and not
>>> from uplink gateway MAC. For NAT there is no such double-step
>>> scheduling because the backups' rules do not match the
>>> internal real server IP in the daddr, they work only for VIP
>>
>> No, this is not the case. The backup balancer did not have rules,
>
> 	Yes, I just explained this variant too.
>
>>> 	Interesting, new master forwards to old master,
>>> so it should send SYNC containing the old master as real
>>> server, how can there be a problem, may be your kernel does
>>> not support properly the local server function which is
>>> fixed 2 years ago.
>>
>> Hmm. I assume the kernel we use is pretty fresh.
>
> 	I see ip_vs_conn.c from Sep 1  2010 is the latest
> file from IPVS.
>
>>> 	May be SYNC message changes the destination in
>>> backup as I already said above? Some tcpdump output will
>>> be helpful in case you don't know how to dig into the
>>> sources of your kernel.
>>
>> There is no change in destination. The dropped packets are really dropped, not
>> relayed somewhere. Also, if they were relayed, they could only be relayed to
>> the active balancer, as ipvs config only has or had these two servers in it.
>> And tcpdump on the active balancer  properly shows the packets sent to the
>> backup balancer, but no packets coming back from that balancer.
>
> 	Yes, may be they loop in stack: DR via LOCAL_OUT,
> then they appear again in LOCAL_IN for forwarding?
>
>>> 	Very good, only that you need recent kernel for this,
>>> 2010-Nov +, there are fixes even after that time.
>>
>> Yes, it looks like we have the kernels built in May-2011.
>
> 	Yep.
>
>>> table and you can switch between them at any time. Of
>>> course, there is some performance price for traffic that
>>> goes to the local stack of backups but they should get from
>>> current master only traffic for their stack.
>>
>> That's not what concerns us. IPVS on the backup balancer is now
>> being filled by 2 sources: the "sync" process, which copies records
>> from the active balancer, and the IPVS itself.
>>
>> I.e. now (when we have rules in the backup balancer, too) -
>> when a new connection arrives to the backup balancer,
>> the balancer creates a connection record and places it into its
>> connection table.
>> A few moments later, the sync daemon receives a connection
>> record for the same connection from the active load balancer,
>> and it also wants to put that record into the connection table
>> on the backup balancer.
>> Our concern is a potential conflict here: that record is already
>> in the table. If you say that there can be no conflict - it would
>> be nice, but we do not know how ipvs is designed, so we
>> cannot get rid of that concern on our own.
>
> 	May be we should stop any forwarding while we are
> in backup mode. The problem is that we can be both in
> master and backup mode and I'm not sure if this is used
> at all. I guess master and backup use different syncid but
> anyways, may be such setup works only for NAT.
>
>> When a backup balancer is instructed to become an active one,
>> our application automatically loads the ruleset with all other
>> real servers into its ipvs rule set, and then sends arp broadcast
>> for all VIPs, switching the traffic to the new active balancer.
>>
>> The existing connections should survive, as the connection table
>> contains all the records sync'ed from the old active balancer, right?
>
> 	Yes.
>
>> The interesting question is how ipvs assigns the connection records
>> received via the sync protocol: as we have seen, we had to put the
>> virt server and the local real server rules into ipvs in order to stop
>> the problem of the "backup" mode.
>> Now, during the failover, we add the rules for other "real servers"
>> AFTER the connection records for their connections were received
>> from the then-active balancer. Will it cause the same type of problem?
>
> 	Not fatal but without rules we can not maintain
> actual counters for active/inactive conns. After failover
> the setup will start with zeroed counters that are
> later modified only for new connections, all SYNCed conns are
> not accounted and the first minutes after failover we can
> see some imbalance.
>
> Regards
>
> --
> Julian Anastasov<ja@ssi.bg>

-- 
Best regards,
Dmitry Akindinov -- Stalker Labs.
