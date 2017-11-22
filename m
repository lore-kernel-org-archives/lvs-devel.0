From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH nf-next 1/1] ipvs: Remove useless ipvsh param of
 frag_safe_skb_hp
Date: Wed, 22 Nov 2017 19:12:47 +0100
Message-ID: <20171122181246.7sviegi56xz2zydc@verge.net.au>
References: <1509007951-8243-1-git-send-email-gfree.wind@vip.163.com>
 <alpine.LFD.2.20.1710281338250.1835@ja.home.ssi.bg>
 <20171102144742.v6ifgldhwqczqmjt@verge.net.au>
 <20171113080058.tss2jzrkursfho67@verge.net.au>
 <20171113083308.zmebtb2u5jct2tub@verge.net.au>
 <alpine.LFD.2.20.1711131104340.2022@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1511374395; bh=WUpe/UKOANGa9b1r7P0nfqyIc7S4kS5byTDZXZLZnO4=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=JKco/39Flu9P31NgMXQ3rMrMRllX5XkIWENhH/qP1drWyXBftOKvVSxkbe37kUMiz
         jfkgqDLGi+DD8WEOfcpjRu602i8dfrK66Q7OulZEjSr3/JcTkOJBurMNGAy62njS5j
         BKq+grgHqMB/syskNcSoLtGBTlrYqvaM3kYGo1Cw=
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.20.1711131104340.2022@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Gao Feng <gfree.wind@vip.163.com>, Wensong Zhang <wensong@linux-vs.org>, lvs-devel@vger.kernel.org

On Mon, Nov 13, 2017 at 11:09:03AM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 13 Nov 2017, Simon Horman wrote:
> 
> > On Mon, Nov 13, 2017 at 09:00:59AM +0100, Simon Horman wrote:
> > > On Thu, Nov 02, 2017 at 03:47:43PM +0100, Simon Horman wrote:
> > > > On Sat, Oct 28, 2017 at 01:39:43PM +0300, Julian Anastasov wrote:
> > > > > 
> > > > > 	Hello,
> > > > > 
> > > > > On Thu, 26 Oct 2017, gfree.wind@vip.163.com wrote:
> > > > > 
> > > > > > From: Gao Feng <gfree.wind@vip.163.com>
> > > > > > 
> > > > > > The param of frag_safe_skb_hp, ipvsh, isn't used now. So remove it and
> > > > > > change the callers' codes.
> > > > > > 
> > > > > > Signed-off-by: Gao Feng <gfree.wind@vip.163.com>
> > > > > 
> > > > > 	Looks good to me. Simon, please apply to ipvs-next tree.
> > > > > 
> > > > > Acked-by: Julian Anastasov <ja@ssi.bg>
> > > > 
> > > > Signed-off-by: Simon Horman <horms@verge.net.au>
> > > > 
> > > > Pablo, can you take this one?
> > > 
> > > I think I would rather it go via Pablo's tree and in turn net-next
> > > as that is the normal route for IPVS patches.
> > 
> > I seem to have responded to the wrong email here.
> 
> 	Recently we see only few small patches for -next, so
> you can write to Pablo to take them directly.

Yes, agreed.
