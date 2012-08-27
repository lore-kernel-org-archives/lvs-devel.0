From: Dmitry Akindinov <dimak@stalker.com>
Subject: Re: Multiple load balancers problem
Date: Tue, 28 Aug 2012 00:24:38 +0400
Message-ID: <503BD786.9020604@stalker.com>
References: <503880A4.6000801@stalker.com> <alpine.LFD.2.00.1208251118260.1864@ja.ssi.bg> <503B2982.7010507@stalker.com> <alpine.LFD.2.00.1208271313420.1934@ja.ssi.bg> <503B8EF6.5040609@stalker.com> <alpine.LFD.2.00.1208271832460.24809@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1208271832460.24809@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

Hello,

On 2012-08-27 20:13, Julian Anastasov wrote:
>
> 	Hello,
>
> On Mon, 27 Aug 2012, Dmitry Akindinov wrote:
>
>> Hello,
>>
>> Sorry for top posting: doing this to avoid clutter below.
>>
>> Thank you for your assistance. Let me to summarize the current situation,
>> after all the changes and testing.
>>
>> 1. The test system consists of two servers, S1 and S2. Both running CentOS
>> 6.0:
>>
>>   [root@fm1 ~]# uname -a
>>   Linux fm1.***.com 2.6.32-71.el6.x86_64 #1 SMP Fri May 20 03:51:51 BST 2011
>>   x86_64 x86_64 x86_64 GNU/Linux
>>
>> We are now setting up new boxes (CentOS 6.3) to re-test with newer kernels
>
> 	The last bug fixes that can be needed for sync
> are from April 2012.
>
>> 2. Both systems have iptables configured to mark the traffic to VIP with the
>> "100" marker.
>>
>> 3. At the beginning of the test,
>> IPSV on S1 configuration is:
>> -A -f 100 -s rr -p 1
>> -a -f 100 -r S1:0 -g -w 100
>> -a -f 100 -r S2:0 -g -w 100
>>
>> IPSV on S2 configuration is:
>> -A -f 100 -s rr -p 1
>> -a -f 100 -r S1:0 -g -w 0
>> -a -f 100 -r S2:0 -g -w 100
>>
>> We establish test connections from client systems to the port 110 of VIP, the
>> S1 routes one connection to itself, the other one to S2. Both connections are
>> alive and well, the connection tables on both systems are the same due to ipsv
>> syncing daemons:
>>
>> ipsvadm -l -c -n:
>> IP  00:49  NONE        C1:0    0.0.0.100:0        S1:0
>> TCP 14:49  ESTABLISHED C1:54837 VIP:110   S1:110
>> TCP 14:43  ESTABLISHED C2:54648 VIP:110   S2:110
>> IP  00:43  NONE       C2:0   0.0.0.100:0         S2:0
>>
>> Now, we initiate a failover, so S2 becomes the active balancer.
>> The IPSV rules on S2 are updated, so they become the same as they were on S1:
>> -A -f 100 -s rr -p 1
>> -a -f 100 -r S1:0 -g -w 100
>> -a -f 100 -r S2:0 -g -w 100
>>
>> And S1 gets the same config as S2 used before the failover.
>>
>> All the connections that existed on S2 before failover continue to work.
>
> 	No loop? Because S2 will receive DR method in
> the SYNC messages for its stack. You see traffic flow
> or just that there is no reset?

Yes, after the failover, all connections that were open on the S2 (which 
now becomes the active balancer) do not reset and continue to function 
just fine (traffic flow in both directions).

We do understand (we think) your explanation about the sync table 
problem  - the connections to the actual balancer are marked in a 
special way, which causes problems when these connection table records 
are used on a new balancer.

It looks like updating the kernels is the only way, if (as you and Hans 
Schillstrom outlines) even the latest CentOS/RedHat kernels do not 
contain necessary patches. It's a pity, as the idea was to provide an 
"out of the box" solution for our customers, and asking them to update 
to some Linux kernel is not what they like to hear.

But thank you very much in any case, we will update the kernels on our 
test systems and will see if this (last?) problem disappears.


>> But the connections that existed on S1 are closed as soon as the client sends
>
> 	This is fixed by the mentioned change:
> "ipvs: changes for local real server"
>
> 	Before this change the SYNC messages indicate
> LOCALNODE as forwarding method. So, S2 thinks that the
> conns for S1 stack are LOCALNODE, S2 deliver them locally
> and they are reset.
>
>> any data to that connection. The tcpdump on S1 does not show any incoming
>> packets, and tcpdump on S2 shows that it's S2 itself (a new load balancer)
>> that closes these connections (the data the client has sent was "HELP\r\n" - 6
>> bytes):
>>
>> 07:54:59.214200 IP (tos 0x10, ttl 54, id 20406, offset 0, flags [DF], proto
>> TCP (6), length 58)
>>      C1.54837 > VIP.110: Flags [P.], cksum 0xba0d (correct), seq
>> 3572724860:3572724866, ack 1018696840, win 33304, options [nop,nop,TS val
>> 3371318384 ecr 1243703099], length 6
>> 07:54:59.214253 IP (tos 0x10, ttl 64, id 0, offset 0, flags [DF], proto TCP
>> (6), length 40)
>>      VIP.110 > C1.54837: Flags [R], cksum 0x5767 (correct), seq 1018696840, win
>> 0, length 0
>>
>> What can cause the new load balancer to reset (Flags [R.]) the existing
>> connections to the "old" balancer?
>
> 	The wrong forwarding type. That is why we now
> save the original forwarding type (DR), we sync it and
> finally when packet is transmitted if the destination is
> local address we deliver it to local stack. We do not
> send LOCALNODE type in messages to backups anymore, we
> removed this forwarding type.
>
>> New connections now work fine, being distributed by the new load balancer to
>> itself and to the old balancer.
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
>

-- 
Best regards,
Dmitry Akindinov


