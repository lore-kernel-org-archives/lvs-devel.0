From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [*v4 PATCH 0/3] IPVS: Backup Adding Ipv6 and Persistence support
Date: Mon, 15 Nov 2010 19:31:26 +0100
Message-ID: <201011151931.26789.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: Simon Horms <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, LVS-Devel <lvs-devel@vger.kernel.org>
Cc: Daniel Lezcano <daniel.lezcano@free.fr>

This patch series adds/(updates) the following functionality
in the synchronization between master and backup daemons.

 - IPv6
 - Persistence Engine
 - Firewall marks transferred
 - Time-outs transferred.
 - Flag field increased to 32 bits.

Note:
It depends on Patch 1-9 in staging branch.
"IPVS: Backup, Prepare for transferring firewall marks (fwmark) to the backup daemon."
to ...
"IPVS: skb defrag in L7 helpers"

A new message format is also introduced, not understood by old backup daemons.
For compatibility reasons receiving the old version (version 0) is still possible.
Old (version 0) backups will just drop new (Version 1) messages.
It's also possible to send sync msg in version 0 format, by sysctl
#sysclt -w net.ipv4.vs.sync_version=0


Update scenario:
 Update the Machine with Bakup daemon first.

Message structure:
A new 32 bit word is added to the header,
where the old count_Conns is set to 0 so old Backup daemons just will drop the packet.
Added is version (1) and there is also a spare 16 bit field at the end.
This is a reworked version based upon Simon Hormans work.


Version 1:
  Note, first byte should be Zero, so ver 0 receivers will drop the packet.

       0                   1                   2                   3
       0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |      0        |    SyncID     |            Size               |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |  Count Conns  |    Version    |    Reserved, set to Zero      |
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


Note: Msg. Size is the real block size include padding

The Sync. Conn. message format is also changed to allow future enhancements
and versions.

     Sync Connection format (sync_conn)

       0                   1                   2                   3
       0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |    Type       |    Protocol   | Ver.  |        Size           |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |                             Flags                             |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |            State              |         cport                 |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |            vport              |         dport                 |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |                             fwmark                            |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |                             timeout  (in sec.)                |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |                              ...                              |
      |                        IP-Addresses  (v4 or v6)               |
      |                              ...                              |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  Optional Parameters.
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      | Param. Type    | Param. Length |   Param. data                |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+                               |
      |                              ...                              |
      |                               +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |                               | Param Type    | Param. Length |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |                           Param  data                         |
      |         Last Param data should be padded for 32 bit alignment |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

New fields that might need some explanation,

Type:
  Bit    7        6        . . .              1           0
    +--------------------------------------------------+-------+
    |                      Spare                       |  IPv6 |
    +--------------------------------------------------+-------+

Bit 0 = 1 This sync_conn contains IPv6 addresses.


Ver.  Version of specified type right now it's 0

Size;    not including ev. padding

fwmark:  Firewall mark from skb.

timeout: from ip_vs_conn struct, converted to sec.


Optional Parameters will be added at the end without any kind of alignment
each Param will have a header of two bytes

Param. header
 Bit    7        6        . . .    0    7                      0
   +----------+----------------------+---------------------------+
   | Optional |  Parameter Type      |  Parameter length         |
   +----------+----------------------+---------------------------+
   |  Data ...                                                   |
   |  ...                                                        |
   +----------+----------------------+---------------------------+
Bit 7 (msb) Optional Param, conn. entry could be keept, if not type
            is unknown.
Bit 6-0 Option Type defined below

#define IPVS_OPT_SEQ_DATA       1
#define IPVS_OPT_PE_DATA        2
#define IPVS_OPT_PE_NAME        3

Option Length, 1-255 bytes 0 is an illegal value.

PATCH STATUS:
 - Persistence data for IPv6 is not tested.


THANKS
To Julian and Simon for the review and alternative solutions.

*v4
 Corrections and enhancements acording to Julians review
 See individual patches.
 Change of principle, length for individual sync_conn
 does not contain padding.

*v3
 New: Ability to send ver. 0 sync messages.
 Optional data, renamed to Optional parameter
 Corrections, see comments in each patch,
 
*v2
 Simplified fwmark handling patch 1/4
 New handling of optional data patch 2/4
 Seconds in timeout
 Basically all changes is based on Julians and Simons comments on the RFC
 For details see individual patches.
--
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
