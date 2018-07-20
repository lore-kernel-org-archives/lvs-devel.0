From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipvs: don't show negative times in ip_vs_conn
Date: Fri, 20 Jul 2018 09:19:25 -0700
Message-ID: <ff823fec-0c37-80f9-9bcf-515357c5209a@gmail.com>
References: <20180720151957.24791-1-mcroce@redhat.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=4i3vJ7Ys+8jOdLzxUQQPkB0PFec6+Kf8W8IJkVfnYtY=;
        b=IbPBG8wnlr4Eb6PMq4eaUunwjytFeSxp5MAdfJyYTSgtV+91bf+UFmwKPJGlsn3ria
         zyE/gaLhdnguDd5I+NraaBk+Pu0X6peXS6Bd6JSahCJi6hir2rC+w7XyePJBLyEb1A+5
         421HIVEtdLNoai/uQjzDcetve0/rPcP50BGSrBK/Gyl4kt1nu6tMNJfjXPE/uYF5ZnUw
         OXwTbEyvb5zXsXga/nRw4uXovyaRefjGKiem0ePiFklMEOQMsYnxLwng5azOkWL2JR35
         L2dgkrKENtCbC8RWGeQUsrLNGRT2IItbXFTTYrktyMu7VWhdMdBzA4X5XUcxz2dP4dbA
         pKBQ==
In-Reply-To: <20180720151957.24791-1-mcroce@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Matteo Croce <mcroce@redhat.com>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org



On 07/20/2018 08:19 AM, Matteo Croce wrote:
> Since commit 500462a9de65 ("timers: Switch to a non-cascading wheel"),
> timers duration can last even 12.5% more than the scheduled interval.
>
> Signed-off-by: Matteo Croce <mcroce@redhat.com>
> ---
>  net/netfilter/ipvs/ip_vs_conn.c | 22 ++++++++++++++--------
>  1 file changed, 14 insertions(+), 8 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index 99e0aa350dc5..c78c48a6d53f 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -1066,6 +1066,12 @@ static void ip_vs_conn_seq_stop(struct seq_file *seq, void *v)
>  	rcu_read_unlock();
>  }
>  
> +static unsigned int time_left(unsigned long time)
> +{
> +	return time_is_after_jiffies(time) ?
> +		jiffies_to_msecs(time - jiffies) / 1000 : 0;
> +}


I would suggest adding jiffies_delta_to_msecs(), because we will need elsewhere,
like in inet_sk_diag_fill()


diff --git a/include/linux/jiffies.h b/include/linux/jiffies.h
index a27cf66523279c1a5d4aaa0d0087f1e9d48d170f..fa928242567db30769839ac8738be5dc58e372ab 100644
--- a/include/linux/jiffies.h
+++ b/include/linux/jiffies.h
@@ -447,6 +447,11 @@ static inline clock_t jiffies_delta_to_clock_t(long delta)
        return jiffies_to_clock_t(max(0L, delta));
 }
 
+static inline unsigned int jiffies_delta_to_msecs(long delta)
+{
+       return jiffies_to_msecs(max(0L, delta));
+}
+
 extern unsigned long clock_t_to_jiffies(unsigned long x);
 extern u64 jiffies_64_to_clock_t(u64 x);
 extern u64 nsec_to_clock_t(u64 x);

