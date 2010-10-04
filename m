From: Simon Horman <horms@verge.net.au>
Subject: [patch v4 00/12] IPVS: SIP Persistence Engine
Date: Mon, 04 Oct 2010 18:03:52 +0900
Message-ID: <20101004090352.966809749@akiko.akashicho.tokyo.vergenet.net>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Jan Engelhardt <jengelh@medozas.de>, Stephen Hemminger <shemminger@vyatta.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

This patch series adds load-balancing of UDP SIP based on Call-ID to
IPVS as well as a frame-work for extending IPVS to handle alternate
persistence requirements.

REVISIONS

This is v4 of the patch series which addresses the following concerns
raised by Julian Anastasov:
 - initialize compat structures to avoid crash in
   ip_vs_add_service for pe_name
 - fix ip_vs_conn_out_get_proto to properly check the
   ip_vs_conn_fill_param_proto result

These changes and changes from previous revisions of this patch series
are noted on a per-patch basis.

I have taken the liberty of including Acked-by: Julian Anastasov <ja@ssi.bg>
although the ack was provided before the two problems above were discovered.

OVERVIEW

The approach that I have taken is what I call persistence engines.
The basic idea being that you can provide a module to LVS that alters
the way that it handles connection templates, which are at the core
of persistence. In particular, an additional key can be added, and
any of the normal IP address, port and protocol information can either
be used or ignored.

In the case of the SIP persistence engine, the only persistence engine, all
the keys used by the default persistence behaviour are used and the callid
is added as an extra key. I originally intended to ignore the cip, but this
can optionally be done by setting the persistence mask (-M) to 0.0.0.0
while allowing the flexibility of other mask values.

It is envisaged that the SIP persistence engine will be used in conjunction
with one-packet scheduling. I'm interested to hear if that doesn't fit your
needs.


CONFIGURATION

A persistence engine is associated with a virtual service
(as are schedulers). I have added the --pe option to the
ivpsadm -A and -E commands to allow the persistence engine
of a virtual service to be added, changed, or deleted.

e.g. ipvsadm -A -u 10.4.3.192:5060 -p 60 -M 0.0.0.0 -o --pe sip

There are no other configuration parameters at this time.


RUNNING

When a connection template is created, if its virtual service
has a persistence engine, then the persistence engine can add
an extra key to the connection template. For the SIP module this
is the callid. More generically, it is known as "pe data". And
both the name of the persistence engine, "pe name", and "pe data"
can be viewed in /proc/net/ip_vs_conn and by passing the
--persistent-conn option to ipvsadm -Lc.

e.g.
# ipvsadm -Lcn --persistent-conn
UDP 00:38  UDP         10.4.3.0:0         10.4.3.192:5060    127.0.0.1:5060 sip 193373839

Here we see a single persistence template (cport is 0), which has been
handled by the sip persistence engine. The pe data (callid) is 193373839.

In the case where the persistence engine can't match a packet for some
reason, the connection will fall back to the normal persistence handling.
This seems reasonable, as that if the packet ought to be dropped, iptables
could be used.

A limited amount of debugging information has been added which
can be enabled using a value of 9 or greater in
/proc/sys/net/ipv4/vs/debug_level

CODE AVAILABILITY

The kernel patches (12) are available in git as the pe-3 branch of
git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-test-2.6.git

The ipvsadm patches (2) are available in git as the pe-3 branch of
git://github.com/horms/ipvsadm-test.git

There is no change to the ipvsadm patches since the v2 series
so I will not repost them.

