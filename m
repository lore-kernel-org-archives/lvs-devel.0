From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 10/15] ipv4: Cache net in ip_build_and_send_pkt
 and ip_queue_xmit
Date: Tue, 06 Oct 2015 14:40:37 -0700
Message-ID: <1444167637.9555.13.camel@edumazet-glaptop2.roam.corp.google.com>
References: <878u7fesrg.fsf_-_@x220.int.ebiederm.org>
	 <1444157595-28816-10-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :content-type:mime-version:content-transfer-encoding;
        bh=T4rOP8zyWefBuStDY/hLuRtUHiD5s8QLixoRKE5it6A=;
        b=p1MMWltdotbR4zcTRdEnMaXGxjzwB/LtUkzZLr0ljWQDNbqf/2DohsoHlD5/AXdi9E
         AqhGZwWQnQUG6P0haK9zJ/X7Adqob8FkGBzKSVV5HeoiLbensh7qVUSIFtkRfrYjed88
         4Cu5ZKW9W18sIvp42e4/I490/HggO5ozade6cYqjEYEC+yVRtHk0HzXQHiX5Sp66m5EU
         c+bmFHVbfJ/91SrtpFqjaS8pFn+kpk00eDJS6eqtZXIpFVgD5Qy+Vvx83ZvxlCt6Cjue
         S72s20G+zpRjjUN+IyZ8i3EFhHOPcqchJSUhqhIk6EUcLHGbOUQb2TagX6f0sfCDTEu1
         UcBg==
In-Reply-To: <1444157595-28816-10-git-send-email-ebiederm@xmission.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: David Miller <davem@davemloft.net>, netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org

On Tue, 2015-10-06 at 13:53 -0500, Eric W. Biederman wrote:
> Compute net and store it in a variable in the functions
> ip_build_and_send_pkt and ip_queue_xmit so that it does not need to be
> recomputed next time it is needed.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>  net/ipv4/ip_output.c | 10 ++++++----
>  1 file changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index 10366ee03bec..a7012f2fa68a 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -139,6 +139,7 @@ int ip_build_and_send_pkt(struct sk_buff *skb, const struct sock *sk,
>  {
>  	struct inet_sock *inet = inet_sk(sk);
>  	struct rtable *rt = skb_rtable(skb);
> +	struct net *net = sock_net(sk);
>  	struct iphdr *iph;
>  
>  	/* Build the IP header. */
> @@ -157,7 +158,7 @@ int ip_build_and_send_pkt(struct sk_buff *skb, const struct sock *sk,
>  		iph->id = 0;
>  	} else {
>  		iph->frag_off = 0;
> -		__ip_select_ident(sock_net(sk), iph, 1);
> +		__ip_select_ident(net, iph, 1);
>  	}
>  

Note that under normal SYNACK processing, we do not read sock_net(sk)
here.

This patch would slow down the SYNACK path under stress, unless compiler
is smart enough to not care of what you wrote.

Generally speaking, I do not see why storing 'struct net' pointer into a
variable in the stack is very different from sk->sk_net access (sk being
a register in most cases)

Note that I am about to submit following patch, so that you understand
the context : the listener socket is cold in cpu cache at the time we
transmit a SYNACK. It is better to get net from the request_sock which
is very hot at this point.

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 55ed3266b05f..93277bde8dd9 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -3026,7 +3026,7 @@ struct sk_buff *tcp_make_synack(const struct sock *sk, struct dst_entry *dst,
 	th->window = htons(min(req->rcv_wnd, 65535U));
 	tcp_options_write((__be32 *)(th + 1), NULL, &opts);
 	th->doff = (tcp_header_size >> 2);
-	TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_OUTSEGS);
+	TCP_INC_STATS_BH(sock_net(req_to_sk(req)), TCP_MIB_OUTSEGS);
 
 #ifdef CONFIG_TCP_MD5SIG
 	/* Okay, we have all we need - do the md5 hash if needed */
@@ -3519,9 +3519,11 @@ int tcp_rtx_synack(const struct sock *sk, struct request_sock *req)
 
 	tcp_rsk(req)->txhash = net_tx_rndhash();
 	res = af_ops->send_synack(sk, NULL, &fl, req, 0, NULL, true);
-	if (!res) {
-		TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_RETRANSSEGS);
-		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPSYNRETRANS);
+	if (likely(!res)) {
+		struct net *net = sock_net(req_to_sk(req));
+
+		TCP_INC_STATS_BH(net, TCP_MIB_RETRANSSEGS);
+		NET_INC_STATS_BH(net, LINUX_MIB_TCPSYNRETRANS);
 	}
 	return res;
 }


