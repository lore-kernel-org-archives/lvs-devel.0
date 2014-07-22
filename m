From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH 3/5] net/netfilter/ipvs/ip_vs_ctl.c: drop argument range
 check just before the check for equality
Date: Tue, 22 Jul 2014 10:42:14 +0300
Message-ID: <20140722074214.GL25880@mwanda>
References: <1405697638-23767-1-git-send-email-andrey.krieger.utkin@gmail.com>
 <alpine.LFD.2.11.1407182339160.2273@ja.home.ssi.bg>
 <CANZNk83dJCXAWrQ+i5rh=sdUuiiD5ZhzDua-rjJpBZCzzNGDJA@mail.gmail.com>
 <alpine.LFD.2.11.1407212253100.2358@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1407212253100.2358@ja.home.ssi.bg>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Andrey Utkin <andrey.krieger.utkin@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, coreteam@netfilter.org, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, dcb314@hotmail.com, David Miller <davem@davemloft.net>, kadlec@blackhole.kfki.hu, Patrick McHardy <kaber@trash.net>, pablo@netfilter.org, Simon Horman <horms@verge.net.au>, wensong@linux-vs.org

On Mon, Jul 21, 2014 at 11:01:56PM +0300, Julian Anastasov wrote:
> @@ -2333,13 +2339,12 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
>  	struct ip_vs_dest_user_kern udest;
>  	struct netns_ipvs *ipvs = net_ipvs(net);
>  
> +	BUILD_BUG_ON(sizeof(arg) > 256);

256 is off-by-one because u8 ranges from 0-255 so we are never able to
copy 256 bytes into the "arg" buffer.

> -	if (copylen > 128)
> +	if (*len < (int) copylen || *len < 0) {
> +		pr_err("get_ctl: len %d < %u\n", *len, copylen);

Don't let users flood dmesg.  Just return an error.  (This can be
triggered by non-root as well).

>  		return -EINVAL;
> +	}

regards,
dan carpenter
