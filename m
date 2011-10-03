From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 2/2] IPVS netns shutdown/startup dead-lock (Take II)
Date: Mon, 3 Oct 2011 23:55:02 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1110032350500.1868@ja.ssi.bg>
References: <1317639399-4522-1-git-send-email-hans.schillstrom@ericsson.com> <1317639399-4522-2-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1317639399-4522-2-git-send-email-hans.schillstrom@ericsson.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: horms@verge.net.au, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, hans@schillstrom.com


	Hello,

On Mon, 3 Oct 2011, Hans Schillstrom wrote:

> From: Hans Schillstrom <hans@schillstrom.com>
> 
> ip_vs_mutext is used by both netns shutdown code and startup
> and both implicit uses sk_lock-AF_INET mutex.
> 
> cleanup CPU-1         startup CPU-2
> ip_vs_dst_event()     ip_vs_genl_set_cmd()
>  sk_lock-AF_INET     __ip_vs_mutex
>                      sk_lock-AF_INET
> __ip_vs_mutex
> * DEAD LOCK *
> 
> A new mutex placed in ip_vs netns struct called sync_mutex is added.
> 
> Comments from Julian and Simon added.
> This patch has been running for more than 3 month now and it seems to work.

	May be IP_VS_SO_GET_DAEMON in do_ip_vs_get_ctl
must be protected by sync_mutex in a similar way.

Regards

--
Julian Anastasov <ja@ssi.bg>
