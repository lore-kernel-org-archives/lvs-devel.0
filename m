From: CGEL <cgel.zte@gmail.com>
Subject: Re: [PATCH net-next] net: Enable some sysctls for the userns root
 with privilege
Date: Tue, 7 Dec 2021 07:18:28 +0000
Message-ID: <61af0ac4.1c69fb81.6badc.a755@mx.google.com>
References: <20211203032815.339186-1-xu.xin16@zte.com.cn>
 <20211206164520.51f8a2d8@kicinski-fedora-pc1c0hjn.dhcp.thefacebook.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=message-id:date:from:to:cc:subject:references:mime-version
         :content-disposition:in-reply-to;
        bh=B94UdsKCgTQF2XUw0WU+IEnqd9VGysceGby9DPepO0o=;
        b=BATXrCzS7rGpAfjh2CD0ElTU1L1wRJnHogCEmwFxybv1NU9OHUXfZhLrFy6pZXeUYp
         Bx0PpUlqnP4PJyW5ilxzGJKt04AvaCWzyt73Ij7DWlP1/lsKVzN74/KG3yndh00oJAUX
         zELVXrcaVlHru+zq3wm/+syHa2g/HmdYFAIx+Zk6Ehvhf0h1DDYU91TC7+LKoua64aTL
         r6UJGNseAOGUyGGKL1EpHU/Fj/u+qYTW6/6mIJEDUXfFd1+z5Lq3xxybgFS9OuZc/baj
         ZrPqT9XOrvrZzcVh/w+xwPi27qDC3E6d0z6DM04edQDdULFXzOJU9BwUeAX8Z5bpl7Z/
         /+9w==
Content-Disposition: inline
In-Reply-To: <20211206164520.51f8a2d8@kicinski-fedora-pc1c0hjn.dhcp.thefacebook.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jakub Kicinski <kuba@kernel.org>
Cc: davem@davemloft.net, alex.aring@gmail.com, stefan@datenfreihafen.org, yoshfuji@linux-ipv6.org, dsahern@kernel.org, horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, kadlec@netfilter.org, fw@strlen.de, steffen.klassert@secunet.com, herbert@gondor.apana.org.au, daniel@iogearbox.net, roopa@nvidia.com, yajun.deng@linux.dev, chinagar@codeaurora.org, xu.xin16@zte.com.cn, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-wpan@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, Eric Biederman <ebiederm@xmission.com>

On Mon, Dec 06, 2021 at 04:45:20PM -0800, Jakub Kicinski wrote:
> On Fri,  3 Dec 2021 03:28:15 +0000 cgel.zte@gmail.com wrote:
> > From: xu xin <xu.xin16@zte.com.cn>
> > 
> > Enabled sysctls include the followings: 
> > 1. net/ipv4/neigh/<if>/* 
> > 2. net/ipv6/neigh/<if>/* 
> > 3. net/ieee802154/6lowpan/* 
> > 4. net/ipv6/route/* 
> > 5. net/ipv4/vs/* 
> > 6. net/unix/* 
> > 7. net/core/xfrm_*
> > 
> > In practical work, some userns with root privilege have needs to adjust
> > these sysctls in their own netns, but limited just because they are not
> > init user_ns, even if they are given root privilege by docker -privilege.
> 
> You need to justify why removing these checks is safe. It sounds like
> you're only describing why having the permissions is problematic, which 
> is fair but not sufficient to just remove them.
> 
Hi, Jakub
My patch is a little radical. I just saw Eric's previous reply to
Alexander(https://lore.kernel.org/all/87pmsqyuqy.fsf@disp2133/).
These were disabled because out of an abundance of caution.

My original intention is to enable part of syscyls about neighbor which
I think was safe, but I will try to figure out which of these sysctls
are safe to be enabled.
> > Reported-by: xu xin <xu.xin16@zte.com.cn>
> > Tested-by: xu xin <xu.xin16@zte.com.cn>
> 
> These tags are superfluous for the author of the patch.
> 
Ok. thank you to correct me.
> > Signed-off-by: xu xin <xu.xin16@zte.com.cn>
> > ---
> >  net/core/neighbour.c                | 4 ----
> >  net/ieee802154/6lowpan/reassembly.c | 4 ----
> >  net/ipv6/route.c                    | 4 ----
> >  net/netfilter/ipvs/ip_vs_ctl.c      | 4 ----
> >  net/netfilter/ipvs/ip_vs_lblc.c     | 4 ----
> >  net/netfilter/ipvs/ip_vs_lblcr.c    | 3 ---
> >  net/unix/sysctl_net_unix.c          | 4 ----
> >  net/xfrm/xfrm_sysctl.c              | 4 ----
> >  8 files changed, 31 deletions(-)
