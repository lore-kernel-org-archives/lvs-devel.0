From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [patch] ipvs: prevent some underflows
Date: Tue, 16 Jun 2015 22:28:29 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1506162224510.1703@ja.home.ssi.bg>
References: <20150605093315.GD24871@mwanda> <alpine.LFD.2.11.1506082137420.1552@ja.home.ssi.bg> <20150609122630.GA4060@localhost.localdomain> <alpine.LFD.2.11.1506110811030.1827@ja.home.ssi.bg> <20150611125734.GL4049@localhost.localdomain>
Mime-Version: 1.0
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20150611125734.GL4049@localhost.localdomain>
Sender: kernel-janitors-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Cc: Dan Carpenter <dan.carpenter@oracle.com>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, kernel-janitors@vger.kernel.org


	Hello,

On Thu, 11 Jun 2015, Marcelo Ricardo Leitner wrote:

> > > On Mon, Jun 08, 2015 at 10:16:23PM +0300, Julian Anastasov wrote:
> > 
> > 	Yes, without any configuration (eg. sysctl value),
> > such defaults should reduce the chance for incompatibilities.
> > I.e. we should not send more than 1500 and should be able to
> > receive at least 1500.
> 
> I'm not sure we should anticipate bad networking setups like that.
> Probably ipvs wouldn't be the only one to suffer from such bad config.
> 
> Anyway, then we should include that sysctl together with that min(),
> because otherwise it will be impossible to send packets larger than
> 1500 and this may be a regression to some users. Or maybe you don't
> think that large packets are worth for the sync at all?

	Sorry for the delay. I'll try that in the
following days. There should be benefits from large
packets, so better to allow it.

Regards

--
Julian Anastasov <ja@ssi.bg>
