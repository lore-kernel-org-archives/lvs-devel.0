From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH nf-next 1/1] ipvs: Remove useless ipvsh param of
 frag_safe_skb_hp
Date: Mon, 13 Nov 2017 09:00:59 +0100
Message-ID: <20171113080058.tss2jzrkursfho67@verge.net.au>
References: <1509007951-8243-1-git-send-email-gfree.wind@vip.163.com>
 <alpine.LFD.2.20.1710281338250.1835@ja.home.ssi.bg>
 <20171102144742.v6ifgldhwqczqmjt@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1510560061; bh=tBX1CAfQ+mifknySPyzTiZosx1VKXEWTF/rkFaP9kZM=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=AlEwPNOd/pZZt8LGWxf4Sn52MyBRQxQ8hoBfycVqnX1JipIU9XI3EZIRHpdGBE9mE
         hQnkY/1wFvodc7OtfbKML/xZK6ucyJDVhe0nSxjI5tRyYfLPAFHcRmng8bG8C1NldG
         NAPnfgIjAVMjAAx8YH/aLlDr6wbV6qPx3yOv694Y=
Content-Disposition: inline
In-Reply-To: <20171102144742.v6ifgldhwqczqmjt@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Gao Feng <gfree.wind@vip.163.com>, Wensong Zhang <wensong@linux-vs.org>, lvs-devel@vger.kernel.org

On Thu, Nov 02, 2017 at 03:47:43PM +0100, Simon Horman wrote:
> On Sat, Oct 28, 2017 at 01:39:43PM +0300, Julian Anastasov wrote:
> > 
> > 	Hello,
> > 
> > On Thu, 26 Oct 2017, gfree.wind@vip.163.com wrote:
> > 
> > > From: Gao Feng <gfree.wind@vip.163.com>
> > > 
> > > The param of frag_safe_skb_hp, ipvsh, isn't used now. So remove it and
> > > change the callers' codes.
> > > 
> > > Signed-off-by: Gao Feng <gfree.wind@vip.163.com>
> > 
> > 	Looks good to me. Simon, please apply to ipvs-next tree.
> > 
> > Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> Pablo, can you take this one?

I think I would rather it go via Pablo's tree and in turn net-next
as that is the normal route for IPVS patches.
