From: Patrick Schaaf <netdev@bof.de>
Subject: coloring LVS-NAT connections internally using TOS/DSCP - reliable?
Date: Sun, 10 Nov 2013 11:56:51 +0100
Message-ID: <3806745.XY2Vn3PIF7@rofl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: lvs-devel@vger.kernel.org

Dear LVS developers.

(resending to lvs-devel because of lack of reaction on lvs-users...)

I came across an idea today, which even appears to work, that could
potentially reduce the number of ipvs realserver entries in an LVS-NAT
scenario where multiple ports need to be passed through to the realservers.

Right now I have a separate (fwmark) virtualserver for port 80, and several
SSL ports that need different certificates on the realservers. The usual
mangle/PREROUTING marking selects which one to use.

Now the idea is to reduce the LVS setup itself to the port 80 server entry,
always select the same fwmark for that, but use rules in mangle/PREROUTING
like -j TOS --set-tos 0x1c/0xfc, with different TOS values.

All SSL connections then arrive at the realservers with dport 80, but there
I have nat/PREROUTING rules matching the TOS values, using -j REDIRECT
--to-port 44X to internally let the connection flow to the right SSL port.

This appears to work quite nicely in a prototype setup. The TOS value
arrives intact in the SYN packet on the realserver, all is well.

My question would be: we run this on kernel 2.6.32 right now. That's a
little bit ancient, and will eventually be upgraded. Was there anything
changed in LVS kernel code since then that would make this TOS/DSCP marking
scheme fail due to the TOS value not being forwarded to the realservers?

best regards
  Patrick
