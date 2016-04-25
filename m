From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 0/9] netlink: align attributes when needed (patchset #2)
Date: Mon, 25 Apr 2016 10:25:13 +0200
Message-ID: <1461572722-6029-1-git-send-email-nicolas.dichtel@6wind.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Cc: davem@davemloft.net, jhs@mojatatu.com, stephen@networkplumber.org, pshelar@nicira.com, aar@pengutronix.de, linux-wpan@vger.kernel.org, wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, johannes@sipsolutions.net, linux-wireless@vger.kernel.org


This is the continuation (series #2) of the work done to align netlink
attributes when these attributes contain some 64-bit fields.

In patch #3, I didn't modify the function ila_encap_nlsize(). I was waiting
feedback for this patch: http://patchwork.ozlabs.org/patch/613766/
If it's approved, there will be an update to switch nla_total_size() to
nla_total_size_64bit() after the merge of net in net-next.

 include/linux/nl802154.h         |  2 +
 include/uapi/linux/if_link.h     |  3 ++
 include/uapi/linux/ila.h         |  1 +
 include/uapi/linux/ip_vs.h       |  1 +
 include/uapi/linux/l2tp.h        |  1 +
 include/uapi/linux/nl80211.h     |  4 ++
 include/uapi/linux/openvswitch.h |  1 +
 include/uapi/linux/pkt_sched.h   |  3 ++
 net/bridge/br_netlink.c          | 62 +++++++++++++++------------
 net/core/rtnetlink.c             | 36 ++++++++--------
 net/ieee802154/nl-mac.c          | 17 +++++---
 net/ieee802154/nl802154.c        |  3 +-
 net/ipv6/ila/ila_lwt.c           |  3 +-
 net/ipv6/ila/ila_xlat.c          | 15 ++++---
 net/l2tp/l2tp_netlink.c          | 80 +++++++++++++++++++++--------------
 net/netfilter/ipvs/ip_vs_ctl.c   | 36 ++++++++++------
 net/openvswitch/datapath.c       |  3 +-
 net/sched/sch_htb.c              |  6 ++-
 net/sched/sch_netem.c            |  3 +-
 net/sched/sch_tbf.c              |  6 ++-
 net/wireless/nl80211.c           | 91 ++++++++++++++++++++++++----------------
 21 files changed, 233 insertions(+), 144 deletions(-)

Comments are welcomed,
Regards,
Nicolas
