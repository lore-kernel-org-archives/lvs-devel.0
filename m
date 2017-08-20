From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net 0/2] netfilter: ipvs: some fixes in
 sctp_conn_schedule
Date: Sun, 20 Aug 2017 10:28:15 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1708201025340.2431@ja.home.ssi.bg>
References: <cover.1503207076.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <cover.1503207076.git.lucien.xin@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Xin Long <lucien.xin@gmail.com>
Cc: netfilter-devel@vger.kernel.org, pablo@netfilter.org, Alex Gartrell <agartrell@fb.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, horms@verge.net.au, wensong@linux-vs.org


	Hello,

On Sun, 20 Aug 2017, Xin Long wrote:

> Patch 1/2 fixes the regression introduced by commit 5e26b1b3abce.
> Patch 2/2 makes ipvs not create conn for sctp ABORT packet.
> 
> Xin Long (2):
>   netfilter: ipvs: fix the issue that sctp_conn_schedule drops non-INIT
>     packet
>   netfilter: ipvs: do not create conn for ABORT packet in
>     sctp_conn_schedule
> 
>  net/netfilter/ipvs/ip_vs_proto_sctp.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)

	Patchset looks ok to me,

Acked-by: Julian Anastasov <ja@ssi.bg>

