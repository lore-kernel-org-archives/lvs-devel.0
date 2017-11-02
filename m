From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH nf-next 1/1] ipvs: Remove useless ipvsh param of
 frag_safe_skb_hp
Date: Thu, 2 Nov 2017 15:47:43 +0100
Message-ID: <20171102144742.v6ifgldhwqczqmjt@verge.net.au>
References: <1509007951-8243-1-git-send-email-gfree.wind@vip.163.com>
 <alpine.LFD.2.20.1710281338250.1835@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1509634065; bh=jnPP2WRcBj4IT+MzZRqT8sDVSnb19TfFN5cjCLUXtkg=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=Z0aKJEANu37keIGRoyVdI1b2eIIyZj5iUFifRUPoymNF4YbAhqj6TXX5cXeC1dffx
         Y3dWZX/F9QP/upvSdXToEJ/b5kSLN0yCnNjeRzhXVk0usGIcK0UH9Rsi0uwDNBIWwS
         BII/QkEFtpF1PGJUzw52LUNy+3ryGirUnh4xIklM=
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.20.1710281338250.1835@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Gao Feng <gfree.wind@vip.163.com>, Wensong Zhang <wensong@linux-vs.org>, lvs-devel@vger.kernel.org

On Sat, Oct 28, 2017 at 01:39:43PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 26 Oct 2017, gfree.wind@vip.163.com wrote:
> 
> > From: Gao Feng <gfree.wind@vip.163.com>
> > 
> > The param of frag_safe_skb_hp, ipvsh, isn't used now. So remove it and
> > change the callers' codes.
> > 
> > Signed-off-by: Gao Feng <gfree.wind@vip.163.com>
> 
> 	Looks good to me. Simon, please apply to ipvs-next tree.
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>

Signed-off-by: Simon Horman <horms@verge.net.au>

Pablo, can you take this one?

