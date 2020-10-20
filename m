From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v5] ipvs: adjust the debug info in function set_tcp_state
Date: Tue, 20 Oct 2020 17:22:46 +0200
Message-ID: <20201020152246.GA19962@salvia>
References: <alpine.LFD.2.23.451.2009271625160.35554@ja.home.ssi.bg>
 <20200928024938.97121-1-bigclouds@163.com>
 <alpine.LFD.2.23.451.2009300803110.6056@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.23.451.2009300803110.6056@ja.home.ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: "longguang.yue" <bigclouds@163.com>, yuelongguang@gmail.com, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, "open list:IPVS" <netdev@vger.kernel.org>, "open list:IPVS" <lvs-devel@vger.kernel.org>, "open list:NETFILTER" <netfilter-devel@vger.kernel.org>, "open list:NETFILTER" <coreteam@netfilter.org>, open list <linux-kernel@vger.kernel.org>

On Wed, Sep 30, 2020 at 08:08:02AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 28 Sep 2020, longguang.yue wrote:
> 
> > Outputting client,virtual,dst addresses info when tcp state changes,
> > which makes the connection debug more clear
> > 
> > Signed-off-by: longguang.yue <bigclouds@163.com>
> 
> 	OK, v5 can be used instead of fixing v4.
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>

Applied, thanks.
