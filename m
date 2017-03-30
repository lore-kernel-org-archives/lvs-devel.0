From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2] net: netfilter: remove unused variable
Date: Thu, 30 Mar 2017 14:55:09 +0200
Message-ID: <20170330125509.GD2980@verge.net.au>
References: <20170329145752.GA2756@arushi-HP-Pavilion-Notebook>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1490878513; bh=sVL3/hu2EPv1rSFNKzCr2TF4U5DMrJHopkrGKknH8C4=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=Ux7WP1itEw3ziPN77Q5T6GjMCPcgluG8uprezsYCYOMnA2yeBHNo78LK59uDrqVqx
         aqgcw1TckgCCbGUGrEHz4oQ1QZDexTz4Kfa1Vy2CFl5lzqYO8okp4JUpsJxicctAMQ
         6X3XT3lEKKfMQ7r/Bi7D8YrNQi1hfgkhl85Pa5Yo=
Content-Disposition: inline
In-Reply-To: <20170329145752.GA2756@arushi-HP-Pavilion-Notebook>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arushi Singhal <arushisinghal19971997@gmail.com>
Cc: outreachy-kernel@googlegroups.com, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

On Wed, Mar 29, 2017 at 08:27:52PM +0530, Arushi Singhal wrote:
> This patch uses the following coccinelle script to remove
> a variable that was simply used to store the return
> value of a function call before returning it:
> 
> @@
> identifier len,f;
> @@
> 
> -int len;
>  ... when != len
>      when strict
> -len =
> +return
>         f(...);
> -return len;
> 
> Signed-off-by: Arushi Singhal <arushisinghal19971997@gmail.com>

Applied with patch prefix updated to "ipvs:".
