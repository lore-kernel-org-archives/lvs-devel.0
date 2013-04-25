From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH ipvs-next] ipvs: Remove
 rcu_read_unlock();rcu_read_lock();
Date: Thu, 25 Apr 2013 11:15:25 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1304251038541.1752@ja.ssi.bg>
References: <1366852353-32561-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1366852353-32561-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>


	Hello,

On Thu, 25 Apr 2013, Simon Horman wrote:

> It is unclear to me that there is any utility in the following:
> 
> 	 rcu_read_unlock();
> 	 rcu_read_lock();

	I thought it is a good idea for fixed hash table
of IP_VS_TAB_BITS=20. May be if guarded by

	if (!((++idx) & 4095))

to reduce its rate to 256 (with idx++ removed from the for loop) ?

	Netfilter has no such logic for nf_conntrack because
it has limit of 16384 rows. Not sure how fatal is to try 1048576
empty rows under RCU lock for such rare operations as
connection listing. OTOH, ip_vs_conn_array() needs to
seek at some initial position, so it can skip many
entries if reading table with many conns, for example,
1048576 rows * 16 conns per row, we will need to
touch 16777216 conns under lock. Not sure what is the
best practice for such cases.

> So this patch removes the two instances of the above from ip_vs_conn.c.
> 
> This was introduced in 7cf2eb7bccbe0d7a8ab1d1382c4faa2b3abf817f ("ipvs: fix
> sparse warnings for ip_vs_conn listing") as part of cleaning up warnings
> flagged by sparse.
> 
> Compile and sparse tested only.
> 
> Cc: Julian Anastasov <ja@ssi.bg>
> Reported-by: Pablo Neira Ayuso <pablo@netfilter.org>
> Signed-off-by: Simon Horman <horms@verge.net.au>
> ---
>  net/netfilter/ipvs/ip_vs_conn.c | 4 ----
>  1 file changed, 4 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index a083bda..458dc68 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -975,8 +975,6 @@ static void *ip_vs_conn_array(struct seq_file *seq, loff_t pos)
>  				return cp;
>  			}
>  		}
> -		rcu_read_unlock();
> -		rcu_read_lock();
>  	}
>  
>  	return NULL;
> @@ -1015,8 +1013,6 @@ static void *ip_vs_conn_seq_next(struct seq_file *seq, void *v, loff_t *pos)
>  			iter->l = &ip_vs_conn_tab[idx];
>  			return cp;
>  		}
> -		rcu_read_unlock();
> -		rcu_read_lock();
>  	}
>  	iter->l = NULL;
>  	return NULL;
> -- 
> 1.8.2.1

Regards

--
Julian Anastasov <ja@ssi.bg>
