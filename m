From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH nf-next] netfilter: ipvs: Remove useless ipvsh param of
 frag_safe_skb_hp
Date: Wed, 22 Nov 2017 19:14:28 +0100
Message-ID: <20171122181428.qaqyodgflfmhtm25@verge.net.au>
References: <1510585098-27428-1-git-send-email-gfree.wind@vip.163.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1511374496; bh=D+ZppiBwHYM043hj7WrpX2lWST266qloAb49Tx0JQ2M=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=hFy0HhrvE9vBw/xBZOYaNu4513y4kb3l9Iy3hdxc6l/bOem3wvCrcI9jqqcimC/WV
         BPphKWg2jHCuP/FrAuHsqisSH1ZSmX1alG6+yO3uIY1pYW0vVg7cbUh/lpDiqu5R/t
         A0Rp8PpvKYrrnGfo50mp2dMk3g6NJCX5dAD49wiY=
Content-Disposition: inline
In-Reply-To: <1510585098-27428-1-git-send-email-gfree.wind@vip.163.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: gfree.wind@vip.163.com
Cc: wensong@linux-vs.org, ja@ssi.bg, pablo@netfilter.org, kadlec@blackhole.kfki.hu, fw@strlen.de, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org

On Mon, Nov 13, 2017 at 10:58:18PM +0800, gfree.wind@vip.163.com wrote:
> From: Gao Feng <gfree.wind@vip.163.com>
> 
> The param of frag_safe_skb_hp, ipvsh, isn't used now. So remove it and
> update the callers' codes too.
> 
> Signed-off-by: Gao Feng <gfree.wind@vip.163.com>
> ---
>  Simon advise me send the patch to netfilter group

Acked-by: Simon Horman <horms+renesas@verge.net.au>

Pablo, can you take this through the nf-next tree?
