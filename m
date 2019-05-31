From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v4] ipvs: add checksum support for gue encapsulation
Date: Fri, 31 May 2019 18:22:27 +0200
Message-ID: <20190531162227.5mbbqqybn6jwausj@salvia>
References: <20190530001641.504-1-hengqing.hu@gmail.com>
 <alpine.LFD.2.21.1905301008470.4257@ja.home.ssi.bg>
 <20190531083741.dxsat27bnsy72wdv@verge.net.au>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20190531083741.dxsat27bnsy72wdv@verge.net.au>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>, Jacky Hu <hengqing.hu@gmail.com>, jacky.hu@walmart.com, jason.niesz@walmart.com, Wensong Zhang <wensong@linux-vs.org>, "David S. Miller" <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org

On Fri, May 31, 2019 at 10:37:41AM +0200, Simon Horman wrote:
> On Thu, May 30, 2019 at 10:10:15AM +0300, Julian Anastasov wrote:
> > 
> > 	Hello,
> > 
> > On Thu, 30 May 2019, Jacky Hu wrote:
> > 
> > > Add checksum support for gue encapsulation with the tun_flags parameter,
> > > which could be one of the values below:
> > > IP_VS_TUNNEL_ENCAP_FLAG_NOCSUM
> > > IP_VS_TUNNEL_ENCAP_FLAG_CSUM
> > > IP_VS_TUNNEL_ENCAP_FLAG_REMCSUM
> > > 
> > > Signed-off-by: Jacky Hu <hengqing.hu@gmail.com>
> > 
> > 	Looks good to me, thanks!
> > 
> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> 
> Likewise, thanks.
> 
> Pablo, pleas consider applying this to nf-next.

Applied, thanks Simon.
