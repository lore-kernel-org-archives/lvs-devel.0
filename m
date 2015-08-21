From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net] ipvs: call rtnl_lock early
Date: Fri, 21 Aug 2015 09:09:56 -0700
Message-ID: <20150821160956.GB24370@verge.net.au>
References: <1437911854-29447-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1437911854-29447-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

On Sun, Jul 26, 2015 at 02:57:34PM +0300, Julian Anastasov wrote:
> When the sync damon is started we need to hold rtnl
> lock while calling ip_mc_join_group. Currently, we have
> a wrong locking order because the correct one is
> rtnl_lock->__ip_vs_mutex. It is implied from the usage
> of __ip_vs_mutex in ip_vs_dst_event() which is called
> under rtnl lock during NETDEV_* notifications.
> 
> Fix the problem by calling rtnl_lock early only for the
> start_sync_thread call. As a bonus this fixes the usage
> __dev_get_by_name which was not called under rtnl lock.
> 
> This patch actually extends and depends on commit 54ff9ef36bdf
> ("ipv4, ipv6: kill ip_mc_{join, leave}_group and
> ipv6_sock_mc_{join, drop}").
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Thanks, I have queued this up.
