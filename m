From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: use true and false for boolean values
Date: Tue, 6 Mar 2018 09:02:08 +0100
Message-ID: <20180306080208.xxz27gffcd7z5fqi@verge.net.au>
References: <20180305213557.GA12365@embeddedor.com>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1520323332; bh=XFapBs6uZcSgvFrcpnJR3Auc9Vgy7LHVY6CvGLZv5O0=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=PoQW1CUiMCtLtx5jKwwyH4KGKiLg1Q/Wt8nfMZxl5J2veGIY8+0zlpn9cmU2v78iL
         pbvcejnrHxgN6pr/oDEGpHWEyP2c3w+2c+8vXuUAi9wKc8jJ6bsHCzsgJ/HG177DDv
         vpJS/FJ9Ql4hDn3BXwXRcAASFA1rJdAW42ljTVDE=
Content-Disposition: inline
In-Reply-To: <20180305213557.GA12365@embeddedor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

On Mon, Mar 05, 2018 at 03:35:57PM -0600, Gustavo A. R. Silva wrote:
> Assign true or false to boolean variables instead of an integer value.
> 
> This issue was detected with the help of Coccinelle.
> 
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

Signed-off-by: Simon Horman <horms@verge.net.au>

Pablo, could you take this one?
