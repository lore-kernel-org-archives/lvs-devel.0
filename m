From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: [patch] ipvs: prevent some underflows
Date: Thu, 11 Jun 2015 09:57:34 -0300
Message-ID: <20150611125734.GL4049@localhost.localdomain>
References: <20150605093315.GD24871@mwanda>
 <alpine.LFD.2.11.1506082137420.1552@ja.home.ssi.bg>
 <20150609122630.GA4060@localhost.localdomain>
 <alpine.LFD.2.11.1506110811030.1827@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1506110811030.1827@ja.home.ssi.bg>
Sender: kernel-janitors-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Dan Carpenter <dan.carpenter@oracle.com>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, kernel-janitors@vger.kernel.org

Hi,

On Thu, Jun 11, 2015 at 08:18:06AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Tue, 9 Jun 2015, Marcelo Ricardo Leitner wrote:
> 
> > On Mon, Jun 08, 2015 at 10:16:23PM +0300, Julian Anastasov wrote:
> > > 
> > > 	May be we should use min(dev->mtu, 1500) instead of
> > > dev->mtu to avoid sending too large packets for the common
> > > case.
> > 
> > That will put an upper limit on it, no? If the load balancers share a
> > big MTU, why not use it?
> 
> 	Yes, without any configuration (eg. sysctl value),
> such defaults should reduce the chance for incompatibilities.
> I.e. we should not send more than 1500 and should be able to
> receive at least 1500.

I'm not sure we should anticipate bad networking setups like that.
Probably ipvs wouldn't be the only one to suffer from such bad config.

Anyway, then we should include that sysctl together with that min(),
because otherwise it will be impossible to send packets larger than
1500 and this may be a regression to some users. Or maybe you don't
think that large packets are worth for the sync at all?

Thanks,
Marcelo

