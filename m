From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCHv5 net-next] ipvs: remove dependency on ip6_tables
Date: Mon, 31 Aug 2020 23:18:20 +0200
Message-ID: <20200831211820.GB24186@salvia>
References: <alpine.LFD.2.23.451.2008291233110.3043@ja.home.ssi.bg>
 <20200829135953.20228-1-iam@lach.pw>
 <alpine.LFD.2.23.451.2008312005270.4425@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.23.451.2008312005270.4425@ja.home.ssi.bg>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Yaroslav Bolyukin <iam@lach.pw>, "David S. Miller" <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Jakub Kicinski <kuba@kernel.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org

On Mon, Aug 31, 2020 at 08:12:05PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Sat, 29 Aug 2020, Yaroslav Bolyukin wrote:
> 
> > This dependency was added because ipv6_find_hdr was in iptables specific
> > code but is no longer required
> > 
> > Fixes: f8f626754ebe ("ipv6: Move ipv6_find_hdr() out of Netfilter code.")
> > Fixes: 63dca2c0b0e7 ("ipvs: Fix faulty IPv6 extension header handling in IPVS").
> > Signed-off-by: Yaroslav Bolyukin <iam@lach.pw>
> 
> 	Looks good to me, thanks! May be maintainers will
> remove the extra dot after the Fixes line.

Applied, thanks. I have also removed the extra dot.
