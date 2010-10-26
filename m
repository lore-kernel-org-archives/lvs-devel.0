From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [RFC PATCH 0/4] IPVS: Backup Adding Ipv6 and Persistence support
Date: Tue, 26 Oct 2010 13:00:08 +0200
Message-ID: <201010261300.09827.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, Daniel

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
Options controlled be Flags
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |                             init_seq                          |
      |                in_seq       delta                             |
      | __________________________  prev_delta ______________________ |
      |                             init_seq                          |
      |               out_seq       delta                             |
      |                             prev_delta                        |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
Optional dynamic length Persistence data, controled by type.
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      | pe_len        | pe_name_len   |  pe_data                      |
      |                              ...                              |
      | pe_name ....                                                  |
      |            padded for 32 bit alignment                        |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

New fields that might need some explanation,

Type:  is one of this four
-IPv4
-IPv6
-IPv4 with PE data
-IPv6 with PE data

Ver.  Version of specified type right now it's 0

fwmark:  Firewall mark from skb.

timeout: from ip_vs_conn struct.

PATCH STATUS:
 - Persistence data is not tested.

QUESTIONS:
In ip_vs_nfct.c
ip_vs_conn_fill_param()  fwmark is set to 0,
Do we need to digg for it there ?
(It is a callback from ct ..)

THANKS
The Persistence part is based on Simon Hormans Backup RFC


SUMMARY
 include/net/ip_vs.h                     |    7 +-
 net/netfilter/ipvs/ip_vs_conn.c         |    9 +-
 net/netfilter/ipvs/ip_vs_core.c         |   19 +-
 net/netfilter/ipvs/ip_vs_ctl.c          |    4 +-
 net/netfilter/ipvs/ip_vs_ftp.c          |    8 +-
 net/netfilter/ipvs/ip_vs_nfct.c         |    2 +-
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c |   13 +-
 net/netfilter/ipvs/ip_vs_sync.c         |  712 ++++++++++++++++++++++++-------
 8 files changed, 592 insertions(+), 182 deletions(-)

--
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
