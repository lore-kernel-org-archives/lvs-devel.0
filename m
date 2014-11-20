From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/1] netfilter: Deletion of unnecessary checks before two
 function calls
Date: Thu, 20 Nov 2014 13:16:08 +0100
Message-ID: <20141120121608.GA10093@salvia>
References: <530CD2C4.4050903@users.sourceforge.net>
 <alpine.DEB.2.10.1402251840450.7035@hadrien>
 <530CF8FF.8080600@users.sourceforge.net>
 <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6>
 <530DD06F.4090703@users.sourceforge.net>
 <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
 <5317A59D.4@users.sourceforge.net>
 <546BA253.6030100@users.sourceforge.net>
 <alpine.LFD.2.11.1411200024280.6497@ja.home.ssi.bg>
 <20141120011359.GJ5065@verge.net.au>
Mime-Version: 1.0
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141120011359.GJ5065@verge.net.au>
Sender: kernel-janitors-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>, SF Markus Elfring <elfring@users.sourceforge.net>, "David S. Miller" <davem@davemloft.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Patrick McHardy <kaber@trash.net>, Wensong Zhang <wensong@linux-vs.org>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, Coccinelle <cocci@systeme.lip6.fr>

On Thu, Nov 20, 2014 at 10:13:59AM +0900, Simon Horman wrote:
> On Thu, Nov 20, 2014 at 12:26:56AM +0200, Julian Anastasov wrote:
> > 
> > 	Hello,
> > 
> > On Tue, 18 Nov 2014, SF Markus Elfring wrote:
> > 
> > > From: Markus Elfring <elfring@users.sourceforge.net>
> > > Date: Tue, 18 Nov 2014 20:37:05 +0100
> > > 
> > > The functions free_percpu() and module_put() test whether their argument
> > > is NULL and then return immediately. Thus the test around the call is
> > > not needed.
> > > 
> > > This issue was detected by using the Coccinelle software.
> > > 
> > > Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> > 
> > 	Pablo, the IPVS parts look ok to me,
> > 
> > Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> Acked-by: Simon Horman <horms@verge.net.au>

Applied, thanks.
