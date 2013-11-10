From: Julian Anastasov <ja@ssi.bg>
Subject: Re: fwmark based ipvs with state transfer / failover: sufficient to
 mark --syn?
Date: Sun, 10 Nov 2013 20:10:11 +0200 (EET)
Message-ID: <alpine.LFD.2.03.1311101925020.1377@ssi.bg>
References: <1499037.fTyOdEoQK4@rofl>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1499037.fTyOdEoQK4@rofl>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick Schaaf <netdev@bof.de>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Sun, 10 Nov 2013, Patrick Schaaf wrote:

> Dear LVS developers,
> 
> (sorry if this seems silly - I prefer asking around over getting bitten some 
> time down the road...)
> 
> we run ipvs in LVS-NAT mode on two loadbalancers in an active/standby setup, 
> with ipvssync threads (and conntrackd) syncing state between the balancers.
> This is running kernel 2.6.36 at the moment.
> 
> Most of the ipvs services we run are fwmark based. Until now, we mark all 
> relevant packets. Now I had the idea, that it would be sufficient to only mark 
> --syn packets - potentially saving a number of iptables rule checks for the 
> more frequent case of non-syn packets.

	IIRC, fwmark is used by IPVS only for scheduling, it happens
only when no existing connection is found. So, it looks safe
to mark only SYN packets. Only for FTP we create connection
on SYN+ACK. If you worry you can use CONNMARK to copy fwmark
from netfilter conntrack to every non-SYN packet, it has a
save+restore feature.

> This seems to work for initial tests, but I am a bit worried whether it would 
> still work in a failover case, thus my question:
> 
> Upon takeover on the standby balancer, will new, UNmarked frames of existing 
> connections, be properly matched up to previously synced state, so that these 
> connections continue to work? In other words, is the IP header information 
> (IP/port four-tuple) sufficient for connection pickup, and independant of the 
> fwmark value on the packets?

	The fwmark was not present in the sync messages.
This was changed with version 1 of the IPVS sync protocol,
may be in 2.6.39. It allows to find the right real server
from the parameters in the sync message when creating
connection in backup server. Once the connection is created
and its real server is assigned, the fwmark is not used anymore.

	May be you'll be also interested to check some
recent changes that avoid the sync protocol:

http://www.spinics.net/lists/lvs-devel/msg03067.html

	They are based on using SH scheduler and a new
sloppy_tcp flag that allows backup server to create conns
from non-SYN packets. I don't know if they are suitable
for your setup, for example, the SH scheduler requires
equal IPVS rules (order of dests in virtual server) in
master and backup to guarantee a working failover.

commit c6c96c188336b2b95d5f14facd101f1e4165a9d3
Author: Alexander Frolkin <avf@eldamar.org.uk>
Date:   Thu Jun 13 08:56:15 2013 +0100

    ipvs: sloppy TCP and SCTP
    
    This adds support for sloppy TCP and SCTP modes to IPVS.
    
    When enabled (sysctls net.ipv4.vs.sloppy_tcp and
    net.ipv4.vs.sloppy_sctp), allows IPVS to create connection state on any
    packet, not just a TCP SYN (or SCTP INIT).
    
    This allows connections to fail over from one IPVS director to another
    mid-flight.

commit eba3b5a78799d21dea05118b294524958f0ab592
Author: Alexander Frolkin <avf@eldamar.org.uk>
Date:   Wed Jun 19 10:54:25 2013 +0100

    ipvs: SH fallback and L4 hashing

commit 4d0c875dcc4923476f364e83912d134da2df224c
Author: Julian Anastasov <ja@ssi.bg>
Date:   Mon Jun 24 22:44:41 2013 +0300

    ipvs: add sync_persist_mode flag
    
    Add sync_persist_mode flag to reduce sync traffic
    by syncing only persistent templates.

Regards

--
Julian Anastasov <ja@ssi.bg>
