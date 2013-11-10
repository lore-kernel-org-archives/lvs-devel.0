From: Patrick Schaaf <netdev@bof.de>
Subject: fwmark based ipvs with state transfer / failover: sufficient to mark --syn?
Date: Sun, 10 Nov 2013 18:16:08 +0100
Message-ID: <1499037.fTyOdEoQK4@rofl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: lvs-devel@vger.kernel.org

Dear LVS developers,

(sorry if this seems silly - I prefer asking around over getting bitten some 
time down the road...)

we run ipvs in LVS-NAT mode on two loadbalancers in an active/standby setup, 
with ipvssync threads (and conntrackd) syncing state between the balancers.
This is running kernel 2.6.36 at the moment.

Most of the ipvs services we run are fwmark based. Until now, we mark all 
relevant packets. Now I had the idea, that it would be sufficient to only mark 
--syn packets - potentially saving a number of iptables rule checks for the 
more frequent case of non-syn packets.

This seems to work for initial tests, but I am a bit worried whether it would 
still work in a failover case, thus my question:

Upon takeover on the standby balancer, will new, UNmarked frames of existing 
connections, be properly matched up to previously synced state, so that these 
connections continue to work? In other words, is the IP header information 
(IP/port four-tuple) sufficient for connection pickup, and independant of the 
fwmark value on the packets?

best regards
  Patrick
