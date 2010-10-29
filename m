From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [v2 PATCH 0/4] IPVS: Backup Adding Ipv6 and Persistence support
Date: Fri, 29 Oct 2010 14:15:34 +0200
Message-ID: <201010291415.35299.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: LVS-Devel <lvs-devel@vger.kernel.org>
Cc: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "daniel.lezcano@free.fr" <daniel.lezcano@free.fr>

This patch series adds/(updates) the following functionality
in the synchronization between master and backup daemons.

 - Ipv6
 - Persistence Engine
 - Firewall marks transfered
 - Timeouts transfered.
 - Flag field increased to 32 bits.

A new message format is also introduced, not understood by old backup daemons.
For compatibility reasons receiving the old version (version 0) is still possible.
Old (version 0) backups will just drop new (Version 1) messages.

Update scenario:
 Update the Machine with Bakup daemon first.

Message structure:
A new 32 bit word is added to the header,
where the old count_Conns is set to 0 so old Backup daemons just will drop the packet.
Added is version (1) and there is also a spare 16 bit field at the end.
This is a reworked version based upon Simon Hormans work.

 Version 1:
       0                   1                   2                   3
       0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |      0        |    Syncid     |            Size               |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |  Count Conns  |   Version     | Spare set to Zero             |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |                                                               |
      |                    IPVS Sync Connection (1)                   |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |                            .                                  |
      ~                            .                                  ~
      |                            .                                  |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |                                                               |
      |                    IPVS Sync Connection (n)                   |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

 Version 0 Header
       0                   1                   2                   3
       0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |  Count Conns  |    SyncID     |            Size               |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |                    IPVS Sync Connection (1)                   |


The Sync. Conn. message format is also changed to allow future enhancements
and versioning.

     Connection Message format

       0                   1                   2                   3
       0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |    Type       |    Protocol   | Ver.  |        Size           |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |                         Flags                                 |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |            State              |         cport                 |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |            vport              |         dport                 |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |                             fwmark                            |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |                             timeout                           |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |                              ...                              |
      |                        IP-Addresses  (IPv4 or IPv6)           |
      |                              ...                              |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
Options
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      | Option Type   | Option Length |   Option data                 |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+                               |
      |                              ...                              |
      |               +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |               | Option Type   | Option Length | Option data   |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+               +
      |                           Option data                         |
      |                             ...                             - |
      |          Last Opt. data should be padded for 32 bit alignment |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

New fields that might need some explanation,

Type:
  Bit    7        6        . . .      2         1           0
    +-------------------------------------+-------------+-------+
    |                     Spare           | Packed IPv6 |  IPv6 |
    +-------------------------------------+-------------+-------+

#define STYPE_INET6	 1
#define STYPE_INET6_PACK 2

Ver.  Version of specified type right now it's 0

fwmark:  Firewall mark from skb.

timeout: from ip_vs_conn struct, converted to sec.


Optional Data will be added at the end without any kind of alignment
each Param data will have a header of two bytes

Option header
 Bit    7        6        . . .    0    7                      0
   +----------+----------------------+---------------------------+
   | Optional |      Option type     |    Option length          |
   +----------+----------------------+---------------------------+
   |  Option data ...                                            |
   |  ...                                                        |
   +----------+----------------------+---------------------------+
Bit 7 (msb) Optional Param, conn. entry could be keept
Bit 6-0 Option Type defined below

#define IPVS_OPT_SEQ_DATA 	1
#define IPVS_OPT_PE_DATA	2
#define IPVS_OPT_PE_NAME	3

Option Length, 1-255 bytes 0 is an illegal value.

PATCH STATUS:
 - Persistence data is not tested.


THANKS
The Persistence part is based on Simon Hormans Backup RFC
Julian for the comments and the Review of the RFC

*v2
 Simlified fwmark handling patch 1/4
 New handling of optional data patch 2/4
 Seconds in timeout
 Basically all changes is based on Julians and Simons comments on the RFC
 For details see individual patches.


SUMMARY
 include/linux/ip_vs.h           |    8 +
 include/net/ip_vs.h             |    6 +-
 net/netfilter/ipvs/ip_vs_conn.c |    5 +-
 net/netfilter/ipvs/ip_vs_core.c |    8 +-
 net/netfilter/ipvs/ip_vs_ctl.c  |    4 +-
 net/netfilter/ipvs/ip_vs_ftp.c  |    5 +-
 net/netfilter/ipvs/ip_vs_sync.c |  612 +++++++++++++++++++++++++++++++--------
 7 files changed, 508 insertions(+), 140 deletions(-)

--
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
