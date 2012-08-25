From: Dmitry Akindinov <dimak@stalker.com>
Subject: Re: Multiple load balancers problem
Date: Sat, 25 Aug 2012 14:13:08 +0400
Message-ID: <5038A534.7020301@stalker.com>
References: <503880A4.6000801@stalker.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <503880A4.6000801@stalker.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: lvs-devel@vger.kernel.org

Hello,

A small addition below.

On 2012-08-25 11:37, Dmitry Akindinov wrote:
> Hello,
>
> We are currently stuck with the following ipvs problem:
>
> 1. The configuration includes a (potentially large) set of servers
> providing various services - besides HTTP (POP, IMAP, LDAP, SMTP, XMPP,
> etc.) The test setup includes just 2 servers, though.
> 2. Each server runs a stock version of CentOS 6.0
> 3. The application software (CommuniGate Pro) controls the ipvs kernel
> module using the ipvsadm commands.
> 4. On each server, iptables are configured to:
> a) disable connection tracking for VIP address(es)
> b) mark all packets coming to the VIP address(es) with the mark value of
> 100.
> 5. On the currently active load balancer, the ipvsadm is used to
> configure ipvs to load-balance packets with the marker 100:
> -A -f 100 -s rr -p 1
> -a -f 100 -r <server1> -g
> -a -f 100 -r <server2> -g
> ....
> where the active balancer itself is one of the <serverN>
> 6. All other servers (just 1 "other" server in our test config) are
> running ipvs, but with an empty rule set.
> 7. The active load balancer runs the sync daemon started with ipvsadm
> --start-daemon master
> 7. All other servers run the sync daemon started with ipvsadm
> --start-daemon backup.
>
> As a result, all servers have the duplicated ipvs connection tables. If
> the active balancer fails, some other server assumes its role by
> arp-broadcasting VIP and loading the ipvs rule set listed above.
>
> When a connection is being established to the VIP address, and the
> active load balancer directs it to itself, everything works fine.
> When a connection is being established to the VIP address, and the
> active load balancer directs it to some other server, the connection is
> established fine, and if the protocol is POP, IMAP, SMTP, the server
> prompt is sent to the client via VIP, and it is seen by client just fine.
> But when the client tries to send anything to the server, the packet
> (according to tcpdump) reaches the load balancer server, and from there
> it reaches the "other" server. Where the packet is dropped. The client
> resends that packet, it goes to the active balancer, then to the "other"
> server, and it is dropped again.
>
>
> Observations:
> *) if ipvs is switched off on that "other" server, everything works just
> fine (service ipvsadm stop)
>
> *) if ipvs is left running on that "other" server, but syncing daemon is
> switched off, everything works just fine.
> We are 95% sure that the problem appears only if the "other server" ipvs
> connection table gets a copy of this
> connection from the active balancer. If the copy is not there (the sync
> daemon was stopped when the connection
> was established, and restarted immediately after), everything works just
> fine.
>
> *) the problem exists for protocols like POP, IMAP, SMTP - where the
> server immediately sends some data (prompt) to the client, as soon as
> the connection is established.
> When the HTTP protocol is used, the problem does not exist, but only if
> the entire request is sent as one packet. If the HTTP connection is a
> "keep-alive" one, subsequent requests in the same connection do not
> reach the application either.
> I.e. it looks like the "idling" ipvs allows only one incoming data
> packet in, and only if there has been no outgoing packet on that
> connection yet.
>
> *) Sometimes (we still cannot reproduce this reliably) the ksoftirqd
> threads on the "other" server jump to 100% CPU
> utilization, and when it happens, it happens in reaction to one
> connection being established.

And when a new connection is being established, the second ksoftirqd 
thread using 100% CPU appears in the "top" output, and so on - till all 
ksoftirqd threads (8 in case of our 8-CPU test servers) are looping 
somewhere, consuming most of CPU cycles.

> Received suggestions:
> *) it was suggested that we use iptables to filter the packets to VIP
> that come from other servers in the farm (using their MAC addresses) and
> direct them directly to the local application, bypassing ipvs
> processing. We cannot do that, as servers in the farm can be added at
> any moment, and updating the list of MACs on all servers is not trivial.
> It may be easier to filter the packets that come from the router(s),
> which are less numerous and do not change that often.
> But it does not look like a good solution. If the ipvs table on
> "inactive" balancer drops packets, why would it stop dropping them when
> it becomes an "active" balancer? Just because there will be ipvs rules
> present?
>
> *) The suggestion to separate load balancer(s) and real servers won't
> work for us at all.
>
> *) We tried not to empty the ipvs table on the "other" server(s).
> Instead, we left it balancing - but with only one "real server" - this
> server itself. Now, the "active" load balancer dsitributes packets to
> itself and other servers, and when the packets hit the "other"
> server(s), they get to the ipvs again, where they are balanced again,
> but to the local server only.
>
> It looks like it does solve the problem. But now the ipvs connection
> table on the "other" server(s) is filled by both that server ipvs itself
> and by the sync-daemon. While the locally-generated connection table
> entries should be the same as corresponding entries received with the
> sync daemon, it does not look good when the same table is modified from
> two sources.
>
> Any comment, please? Should we use the last suggestion?
>
>


-- 
Best regards,
Dmitry Akindinov
