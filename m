From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [patch] ipvs: prevent some underflows
Date: Thu, 11 Jun 2015 08:18:06 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1506110811030.1827@ja.home.ssi.bg>
References: <20150605093315.GD24871@mwanda> <alpine.LFD.2.11.1506082137420.1552@ja.home.ssi.bg> <20150609122630.GA4060@localhost.localdomain>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20150609122630.GA4060@localhost.localdomain>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Cc: Dan Carpenter <dan.carpenter@oracle.com>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, kernel-janitors@vger.kernel.org


	Hello,

On Tue, 9 Jun 2015, Marcelo Ricardo Leitner wrote:

> On Mon, Jun 08, 2015 at 10:16:23PM +0300, Julian Anastasov wrote:
> > 
> > 	May be we should use min(dev->mtu, 1500) instead of
> > dev->mtu to avoid sending too large packets for the common
> > case.
> 
> That will put an upper limit on it, no? If the load balancers share a
> big MTU, why not use it?

	Yes, without any configuration (eg. sysctl value),
such defaults should reduce the chance for incompatibilities.
I.e. we should not send more than 1500 and should be able to
receive at least 1500.

Regards

--
Julian Anastasov <ja@ssi.bg>
