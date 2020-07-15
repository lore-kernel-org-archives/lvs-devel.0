From: Jakub Kicinski <kuba@kernel.org>
Subject: Re: [PATCH] ipvs:clean code for ip_vs_sync.c
Date: Wed, 15 Jul 2020 15:03:36 -0700
Message-ID: <20200715150336.711be40a@kicinski-fedora-pc1c0hjn.dhcp.thefacebook.com>
References: <1594815519-37044-1-git-send-email-zhouxudong8@huawei.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1594850618;
        bh=fXB7l0f6ZWFmzfoL9BzAn5mG2HBQawkBRn3CF/kBjYE=;
        h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
        b=uJcPhYXeuRWwXwftXOPSc9GNSm7M35GZRjr5Gkz0iGPkHxJzLAzHXhf/HvzPiOakH
         42cvxsahDTIUU78y/zjnhoczujYNt+ua7sxXLFAQNbegGy+KI3L98xB1n6QfIqkN4Z
         0lb5D5ZxdW+N35l12UJl7pR/c9L49IB4Y0H0bJz0=
In-Reply-To: <1594815519-37044-1-git-send-email-zhouxudong8@huawei.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: zhouxudong199 <zhouxudong8@huawei.com>
Cc: wensong@linux-vs.org, horms@verge.net.au, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, rose.chen@huawei.com

On Wed, 15 Jul 2020 12:18:39 +0000 zhouxudong199 wrote:
> Signed-off-by:zhouxudong199 <zhouxudong8@huawei.com>

Thank you for the patch.

Please describe the changes you're making in the commit message, as far
as I can tell you're adding missing spaces?

Please read this: https://kernelnewbies.org/KernelJanitors
and make sure to CC kernel-janitors@vger.kernel.org

Please add a space after ipvs: in the subject and after Signed-off-by:

If you repost please make sure to mark the patch as v2.

> @@ -1232,7 +1232,7 @@ static void ip_vs_process_message(struct netns_ipvs *ipvs, __u8 *buffer,
>  		msg_end = buffer + sizeof(struct ip_vs_sync_mesg);
>  		nr_conns = m2->nr_conns;
>  
> -		for (i=0; i<nr_conns; i++) {
> +		for (i=0; i < nr_conns; i++) {

you should probably replace i=0 with i = 0.

>  			union ip_vs_sync_conn *s;
>  			unsigned int size;
>  			int retc;
