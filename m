From: Jacky Hu <hengqing.hu@gmail.com>
Subject: Re: [PATCH v4] ipvs: allow tunneling with gue encapsulation
Date: Mon, 18 Mar 2019 20:50:18 +0800
Message-ID: <20190318125018.GA4499@i716>
References: <20190317155200.16586-1-hengqing.hu@gmail.com>
 <201903181001.7czsRhlB%lkp@intel.com>
 <20190318032256.GA21124@i716>
 <alpine.LFD.2.21.1903181000070.2986@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Ns4e4/Rd6bF0R6chwH0zebqELDJAs3QtT0Rc73v8mYQ=;
        b=casgW2NG+y33l87eA1BfNyHh2BRhInT44+A8Ot3dVI+RxsiWAtVWZnleaa5JSxATg5
         /lAiwADktoQg4fXJ/aHCs4xioHTOtyoFc+8BvenUkz+x78Jms9m5vKEaYeOZWsHluusd
         ixrfp6Ok2vWZQZO5V3Ifdl/WGZ9hsgK+WaSfb/ltdfmPqgj7aMkYtDQD1vH6HvVJLo1Y
         9c2gfLXFxE9bSI/+Jw/DMy4ch5HMHii8MRwufGANY05P6JJrS+xStBLc9qBSvysZ9zEP
         aDmPVHh9NAl5bupLj+x16zXFWr5fc4d21FAy+8CVxmta+KLnlMa4K/zyJmm4tBPFVeEp
         m5WQ==
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.21.1903181000070.2986@ja.home.ssi.bg>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org, jacky.hu@walmart.com, jason.niesz@walmart.com, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, "David S. Miller" <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org

Hello,

On Mon, Mar 18, 2019 at 10:14:20AM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 18 Mar 2019, Jacky Hu wrote:
> 
> > On Mon, Mar 18, 2019 at 10:10:20AM +0800, kbuild test robot wrote:
> > > Hi Jacky,
> > > 
> > > Thank you for the patch! Perhaps something to improve:
> > > 
> > > [auto build test WARNING on ipvs-next/master]
> > > [also build test WARNING on v5.1-rc1 next-20190306]
> > > [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> > > 
> > > url:    https://github.com/0day-ci/linux/commits/Jacky-Hu/ipvs-allow-tunneling-with-gue-encapsulation/20190318-070156
> > > base:   https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git master
> > > reproduce:
> > >         # apt-get install sparse
> > >         make ARCH=x86_64 allmodconfig
> > >         make C=1 CF='-fdiagnostic-prefix -D__CHECK_ENDIAN__'
> > > 
> > > 
> > > sparse warnings: (new ones prefixed by >>)
> > > 
> > >    net/netfilter/ipvs/ip_vs_ctl.c:835:42: sparse: incorrect type in argument 2 (different base types) @@    expected int [signed] i @@    got restricted __be1int [signed] i @@
> > >    net/netfilter/ipvs/ip_vs_ctl.c:835:42:    expected int [signed] i
> > >    net/netfilter/ipvs/ip_vs_ctl.c:835:42:    got restricted __be16 [usertype] tun_port
> > >    net/netfilter/ipvs/ip_vs_ctl.c:1197:44: sparse: expression using sizeof(void)
> > > >> net/netfilter/ipvs/ip_vs_ctl.c:3207:37: sparse: incorrect type in argument 3 (different base types) @@    expected restricted __be16 [usertype] value @@    got e] value @@
> > >    net/netfilter/ipvs/ip_vs_ctl.c:3207:37:    expected restricted __be16 [usertype] value
> > >    net/netfilter/ipvs/ip_vs_ctl.c:3207:37:    got int
> > >    net/netfilter/ipvs/ip_vs_ctl.c:1313:27: sparse: dereference of noderef expression
> > > 
> > > vim +3207 net/netfilter/ipvs/ip_vs_ctl.c
> > > 
> 
> > > > 3207				 atomic_read(&dest->tun_port)) ||
> > 
> >     Should I change the type of tun_port from __be16 to u16?
> >     Looks like kbuild bugs a lot on this.
> 
> 	In struct ip_vs_dest you should use __be16 for tun_port and
> __u16 for tun_type and avoid any atomic_t usage. To test it with sparse:
> 
> make C=2 CF="-D__CHECK_ENDIAN__" net/netfilter/ipvs/
> 
> 	And this is the only problem in v4 of the patch. Then may be
> you should wait when net-next opens again before submitting v5.
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
I have made the required changes locally, also updated ipvsadm accordingly,
once it opens, I'll submit them.

Thanks.
Best Regards,
Jacky
