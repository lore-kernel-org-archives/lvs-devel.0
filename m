From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v7] ipvs: inspect reply packets from DR/TUN real
 servers
Date: Mon, 5 Oct 2020 23:17:26 +0300 (EEST)
Message-ID: <alpine.LFD.2.23.451.2010052316090.13695@ja.home.ssi.bg>
References: <alpine.LFD.2.23.451.2010041409460.5398@ja.home.ssi.bg> <20201005064943.88541-1-bigclouds@163.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20201005064943.88541-1-bigclouds@163.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "longguang.yue" <bigclouds@163.com>
Cc: lvs-devel@vger.kernel.org, yuelongguang@gmail.com


	Hello,

On Mon, 5 Oct 2020, longguang.yue wrote:

> Just like for MASQ, inspect the reply packets coming from DR/TUN
> real servers and alter the connection's state and timeout
> according to the protocol.
> 
> It's ipvs's duty to do traffic statistic if packets get hit,
> no matter what mode it is.
> 
> Signed-off-by: longguang.yue <bigclouds@163.com>
> 
> ---
> v1: support DR/TUN mode statistic
> v2: ip_vs_conn_out_get handles DR/TUN mode's conn
> v3: fix checkpatch
> v4, v5: restructure and optimise this feature
> v6: rewrite subject and patch description
> v7: adjust changelogs and order of some local vars

	Thanks! Fixed the patch format and posted it as v8.

> Signed-off-by: longguang.yue <bigclouds@163.com>
> ---
>  net/netfilter/ipvs/ip_vs_conn.c | 18 +++++++++++++++---
>  net/netfilter/ipvs/ip_vs_core.c | 17 ++++++-----------
>  2 files changed, 21 insertions(+), 14 deletions(-)

Regards

--
Julian Anastasov <ja@ssi.bg>

