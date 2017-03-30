From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2] net: netfilter: remove unused variable
Date: Thu, 30 Mar 2017 16:36:41 +0200
Message-ID: <20170330143641.GA999@salvia>
References: <20170329145752.GA2756@arushi-HP-Pavilion-Notebook>
 <20170330125509.GD2980@verge.net.au>
 <CA+XqjF_pbKoYC+UM9ad2wOvBo6gNnEEWnrUjJHfuDcFx3jEEzQ@mail.gmail.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+XqjF_pbKoYC+UM9ad2wOvBo6gNnEEWnrUjJHfuDcFx3jEEzQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arushi Singhal <arushisinghal19971997@gmail.com>
Cc: Simon Horman <horms@verge.net.au>, outreachy-kernel@googlegroups.com, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, LKML <linux-kernel@vger.kernel.org>

On Thu, Mar 30, 2017 at 07:38:08PM +0530, Arushi Singhal wrote:
> On Thu, Mar 30, 2017 at 6:25 PM, Simon Horman <horms@verge.net.au> wrote:
> 
> > On Wed, Mar 29, 2017 at 08:27:52PM +0530, Arushi Singhal wrote:
> > > This patch uses the following coccinelle script to remove
> > > a variable that was simply used to store the return
> > > value of a function call before returning it:
> > >
> > > @@
> > > identifier len,f;
> > > @@
> > >
> > > -int len;
> > >  ... when != len
> > >      when strict
> > > -len =
> > > +return
> > >         f(...);
> > > -return len;
> > >
> > > Signed-off-by: Arushi Singhal <arushisinghal19971997@gmail.com>
> >
> > Applied with patch prefix updated to "ipvs:".
> >
> Hi
> Thanks
> How can I see my accepted patches of netfilter.

You can use links from patchwork:

http://patchwork.ozlabs.org/project/netfilter-devel/
