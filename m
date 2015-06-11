From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch] ipvs: prevent some underflows
Date: Thu, 11 Jun 2015 16:17:15 +0300
Message-ID: <20150611131714.GJ28762@mwanda>
References: <20150605093315.GD24871@mwanda>
 <alpine.LFD.2.11.1506082137420.1552@ja.home.ssi.bg>
 <20150609122630.GA4060@localhost.localdomain>
 <alpine.LFD.2.11.1506110811030.1827@ja.home.ssi.bg>
 <20150611125734.GL4049@localhost.localdomain>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150611125734.GL4049@localhost.localdomain>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Cc: Julian Anastasov <ja@ssi.bg>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, kernel-janitors@vger.kernel.org

Is there any way I can bail out of this patch and someone else do it?
I'm a complete newbie here doing static checker fixes and this stuff is
too complicated for me to have an opinion about.

regards,
dan carpenter

