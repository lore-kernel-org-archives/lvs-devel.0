From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] netfilter: ip_vs_sync: fix bogus maybe-uninitialized
 warning
Date: Fri, 28 Oct 2016 13:40:23 +0200
Message-ID: <20161028114020.GA4041@verge.net.au>
References: <20161024153454.2766113-1-arnd@arndb.de>
 <alpine.LFD.2.11.1610242226310.2276@ja.home.ssi.bg>
 <20161028093422.GA29559@salvia>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1477654828; bh=NsPuju+aN6CGieoZmxWC2HH36eJt4Z3qC7OqaTbZGaM=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=kLoOzpZ1Jcg7dJVYSv6B33aiuKBus6+uLrCgiqCpCTJ2g/ZWbUPgPDq06wYvrwjSo
         YT4dwCYg21wcz0wNmEmHLV9nui4asXstpMMYbTeb/+9E27upJaTJJTjwtwLS0BPtbO
         Ze4yRqgKCjNsT94FW+WI37k/agqL7hQ8irN1kfng=
Content-Disposition: inline
In-Reply-To: <20161028093422.GA29559@salvia>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Julian Anastasov <ja@ssi.bg>, Arnd Bergmann <arnd@arndb.de>, Wensong Zhang <wensong@linux-vs.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, Quentin Armitage <quentin@armitage.org.uk>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

On Fri, Oct 28, 2016 at 11:34:22AM +0200, Pablo Neira Ayuso wrote:
> On Mon, Oct 24, 2016 at 10:47:54PM +0300, Julian Anastasov wrote:
> > 
> > 	Hello,
> > 
> > On Mon, 24 Oct 2016, Arnd Bergmann wrote:
> > 
> > > Building the ip_vs_sync code with CONFIG_OPTIMIZE_INLINING on x86
> > > confuses the compiler to the point where it produces a rather
> > > dubious warning message:
> > > 
> > > net/netfilter/ipvs/ip_vs_sync.c:1073:33: error: ‘opt.init_seq’ may be used uninitialized in this function [-Werror=maybe-uninitialized]
> > >   struct ip_vs_sync_conn_options opt;
> > >                                  ^~~
> > > net/netfilter/ipvs/ip_vs_sync.c:1073:33: error: ‘opt.delta’ may be used uninitialized in this function [-Werror=maybe-uninitialized]
> > > net/netfilter/ipvs/ip_vs_sync.c:1073:33: error: ‘opt.previous_delta’ may be used uninitialized in this function [-Werror=maybe-uninitialized]
> > > net/netfilter/ipvs/ip_vs_sync.c:1073:33: error: ‘*((void *)&opt+12).init_seq’ may be used uninitialized in this function [-Werror=maybe-uninitialized]
> > > net/netfilter/ipvs/ip_vs_sync.c:1073:33: error: ‘*((void *)&opt+12).delta’ may be used uninitialized in this function [-Werror=maybe-uninitialized]
> > > net/netfilter/ipvs/ip_vs_sync.c:1073:33: error: ‘*((void *)&opt+12).previous_delta’ may be used uninitialized in this function [-Werror=maybe-uninitialized]
> > > 
> > > The problem appears to be a combination of a number of factors, including
> > > the __builtin_bswap32 compiler builtin being slightly odd, having a large
> > > amount of code inlined into a single function, and the way that some
> > > functions only get partially inlined here.
> > > 
> > > I've spent way too much time trying to work out a way to improve the
> > > code, but the best I've come up with is to add an explicit memset
> > > right before the ip_vs_seq structure is first initialized here. When
> > > the compiler works correctly, this has absolutely no effect, but in the
> > > case that produces the warning, the warning disappears.
> > > 
> > > In the process of analysing this warning, I also noticed that
> > > we use memcpy to copy the larger ip_vs_sync_conn_options structure
> > > over two members of the ip_vs_conn structure. This works because
> > > the layout is identical, but seems error-prone, so I'm changing
> > > this in the process to directly copy the two members. This change
> > > seemed to have no effect on the object code or the warning, but
> > > it deals with the same data, so I kept the two changes together.
> > > 
> > > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > 
> > 	OK,
> > 
> > Acked-by: Julian Anastasov <ja@ssi.bg>
> > 
> > 	I guess, Simon will take the patch for ipvs-next.
> 
> @Simon: If you have no more pending updates, I can save you one pull
> request for this small fix by placing this.

Thanks Pablo, please do.

Signed-off-by: Simon Horman <horms@verge.net.au>

