From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH nf 2/3] netfilter: ipvs: allow rescheduling after RST
Date: Thu, 18 Feb 2016 16:17:17 +0300
Message-ID: <56C5C45D.9050807@cogentembedded.com>
References: <1455756061-21834-1-git-send-email-horms@verge.net.au>
 <1455756061-21834-3-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cogentembedded-com.20150623.gappssmtp.com; s=20150623;
        h=subject:to:references:cc:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-type:content-transfer-encoding;
        bh=Ya8JHnVsNaujn51wC4CN3f7hMFUVDgzmNPe+ZW38hpg=;
        b=ye1dRJzZtbQwuPPuIYRM5eNm9ImpTcofGqbFSvOHCXr6563wXBglg+DMgBrHscQMVk
         u9/a8aBAyMhl6IPBGAFb5G7swtKVSJjofNJr0AastTZRHz0bnzDeiOc4VBKXi/fxa6Fq
         +5temOXwKvsekHJpMCsKENjwsI2PNyfC452tB7/E1K+40CexOapku+OV+ZtnUzSC5C0b
         Kfz2AiLD8vObM/WtMjOzwWvfIQuftGSUZQfKF9xU3sAUQ7Tuho3R77qwHsbpqwxlJNdQ
         NC3/6OtgL6huDk8m15de4Su5kjg4kPBC0YVY4FOHjYQJna+koxItj++UY4tAmTE6ql2i
         8D3A==
In-Reply-To: <1455756061-21834-3-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

Hello.

On 2/18/2016 3:41 AM, Simon Horman wrote:

> From: Julian Anastasov <ja@ssi.bg>
>
> "RFC 5961, 4.2. Mitigation" describes a mechanism to request
> client to confirm with RST the restart of TCP connection
> before resending its SYN. As result, IPVS can see SYNs for
> existing connection in CLOSE state. Add check to allow
> rescheduling in this state.
>
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Simon Horman <horms@verge.net.au>
> ---
>   net/netfilter/ipvs/ip_vs_core.c | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index 4da560005b0e..0c1d3fef9a7c 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -1089,6 +1089,7 @@ static inline bool is_new_conn_expected(const struct ip_vs_conn *cp,
>   	switch (cp->protocol) {
>   	case IPPROTO_TCP:
>   		return (cp->state == IP_VS_TCP_S_TIME_WAIT) ||
> +			cp->state == IP_VS_TCP_S_CLOSE ||

    I would have been consistent and enclosed this expression into parens as 
well. BTW, the indentation is not correct anyway.

>   			((conn_reuse_mode & 2) &&
>   			 (cp->state == IP_VS_TCP_S_FIN_WAIT) &&
>   			 (cp->flags & IP_VS_CONN_F_NOOUTPUT));

MBR, Sergei

