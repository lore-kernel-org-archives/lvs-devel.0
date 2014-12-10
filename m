From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch v2] ipvs: uninitialized data with IP_VS_IPV6
Date: Wed, 10 Dec 2014 17:47:21 +0900
Message-ID: <20141210084721.GA15585@verge.net.au>
References: <20141206134924.GA17278@mwanda>
 <alpine.LFD.2.11.1412072032420.1885@ja.home.ssi.bg>
 <20141209005215.GH8897@verge.net.au>
 <20141209064947.GH4912@mwanda>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141209064947.GH4912@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Julian Anastasov <ja@ssi.bg>, Wensong Zhang <wensong@linux-vs.org>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, kernel-janitors@vger.kernel.org

On Tue, Dec 09, 2014 at 09:49:47AM +0300, Dan Carpenter wrote:
> On Tue, Dec 09, 2014 at 09:52:15AM +0900, Simon Horman wrote:
> > On Sun, Dec 07, 2014 at 08:39:35PM +0200, Julian Anastasov wrote:
> > > 
> > > 	Hello,
> > > 
> > > On Sat, 6 Dec 2014, Dan Carpenter wrote:
> > > 
> > > > The app_tcp_pkt_out() function expects "*diff" to be set and ends up
> > > > using uninitialized data if CONFIG_IP_VS_IPV6 is turned on.
> > > > 
> > > > The same issue is there in app_tcp_pkt_in().  Thanks to Julian Anastasov
> > > > for noticing that.
> > > > 
> > > > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> > > > ---
> > > > v2: fix app_tcp_pkt_in() as well.  This is an old bug.
> > > 
> > > 	Thanks! It will not break seqs for IPv6 control
> > > connection, only that we do not support FTP yet :( I have
> > > the doubt whether this should be classified as bugfix :)
> > > I guess, it is a net-next material, right?
> > 
> > Agreed, I have queued it up in ipvs-next.
> > I'll send a pull request to Pablo if Dan doesn't object
> > to it going there.
> 
> No objections from me.

Thanks, I have sent a pull-request.
