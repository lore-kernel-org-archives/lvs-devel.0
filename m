From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 3/3] ipvs: fix get_curr_sync_buff
Date: Tue, 14 Dec 2010 01:32:36 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1012140113140.2634@ja.ssi.bg>
References: <adb973b711975ac5a24c69818fd0439d88f4c68c.1292153764.git.wangtinggong@gmail.com> <3236859ec32d32324ce6e1f8a4456d2d1a84ed7b.1292153764.git.wangtinggong@gmail.com> <f190cc57967c7435bc405fd4a192d15605652461.1292153764.git.wangtinggong@gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <f190cc57967c7435bc405fd4a192d15605652461.1292153764.git.wangtinggong@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Tinggong Wang <wangtinggong@gmail.com>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org


 	Hello,

On Sun, 12 Dec 2010, Tinggong Wang wrote:

> use time_after get the current buffer created more than the specified time.
>
> time_before in get_curr_sync_buff(2 * HZ) will get the buffer created newly.
> if curr_sb has been created more than 2*HZ then it will still sit in master.
> so use time_after instead.
>
> Signed-off-by: Tinggong Wang <wangtinggong@gmail.com>
> ---
> net/netfilter/ipvs/ip_vs_sync.c |    3 +--
> 1 files changed, 1 insertions(+), 2 deletions(-)
>
> diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> index 2b6b0cb..555b0dd 100644
> --- a/net/netfilter/ipvs/ip_vs_sync.c
> +++ b/net/netfilter/ipvs/ip_vs_sync.c
> @@ -221,8 +221,7 @@ get_curr_sync_buff(unsigned long time)
> 	struct ip_vs_sync_buff *sb;
>
> 	spin_lock_bh(&curr_sb_lock);
> -	if (curr_sb && (time == 0 ||
> -			time_before(jiffies - curr_sb->firstuse, time))) {
> +	if (curr_sb && time_after(jiffies - curr_sb->firstuse, time)) {

 	This breaks the time=0 case when jiffies matches firstuse.

 	May be the fix should be as follows?:

 	if (curr_sb && time_after_eq(jiffies - curr_sb->firstuse, time)) {

 	i.e. passed >= limit (2 or 0).

> 		sb = curr_sb;
> 		curr_sb = NULL;
> 	} else
> -- 
> 1.7.2.3

Regards

--
Julian Anastasov <ja@ssi.bg>
