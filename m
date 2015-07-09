From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] net-ipvs: Delete an unnecessary check before the
 function call "module_put"
Date: Thu, 9 Jul 2015 10:41:02 +0900
Message-ID: <20150709014102.GB14843@verge.net.au>
References: <530CD2C4.4050903@users.sourceforge.net>
 <alpine.DEB.2.10.1402251840450.7035@hadrien>
 <530CF8FF.8080600@users.sourceforge.net>
 <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6>
 <530DD06F.4090703@users.sourceforge.net>
 <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
 <5317A59D.4@users.sourceforge.net>
 <546BA253.6030100@users.sourceforge.net>
 <20141119134040.GA12270@salvia>
 <55955471.9000501@users.sourceforge.net>
Mime-Version: 1.0
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <55955471.9000501@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: SF Markus Elfring <elfring@users.sourceforge.net>
Cc: "David S. Miller" <davem@davemloft.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Wensong Zhang <wensong@linux-vs.org>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, LKML <linux-kernel@vger.kernel.org>, "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>, Julia Lawall <julia.lawall@lip6.fr>

On Thu, Jul 02, 2015 at 05:10:41PM +0200, SF Markus Elfring wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Thu, 2 Jul 2015 17:00:14 +0200
> 
> The module_put() function tests whether its argument is NULL and then
> returns immediately. Thus the test around the call is not needed.
> 
> This issue was detected by using the Coccinelle software.

Thanks, applied to ipvs-next for v4.3.
