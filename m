From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/2] netfilter: ipvs: avoid unused variable warnings
Date: Thu, 28 Jan 2016 13:28:17 +0100
Message-ID: <121171795.jNF1vkL58j@wuerfel>
References: <1453902749-3422685-1-git-send-email-arnd@arndb.de> <alpine.LFD.2.11.1601272156590.2353@ja.home.ssi.bg> <20160127233953.GB5183@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160127233953.GB5183@verge.net.au>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>, Wensong Zhang <wensong@linux-vs.org>, linux-arm-kernel@lists.infradead.org, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

On Thursday 28 January 2016 08:39:53 Simon Horman wrote:
> On Wed, Jan 27, 2016 at 10:01:42PM +0200, Julian Anastasov wrote:
> > 
> >       Hello,
> > 
> > On Wed, 27 Jan 2016, Arnd Bergmann wrote:
> > 
> > > The proc_create() and remove_proc_entry() functions do not reference
> > > their arguments when CONFIG_PROC_FS is disabled, so we get a couple
> > > of warnings about unused variables in IPVS:
> > > 
> > > ipvs/ip_vs_app.c:608:14: warning: unused variable 'net' [-Wunused-variable]
> > > ipvs/ip_vs_ctl.c:3950:14: warning: unused variable 'net' [-Wunused-variable]
> > > ipvs/ip_vs_ctl.c:3994:14: warning: unused variable 'net' [-Wunused-variable]
> > > 
> > > This removes the local variables and instead looks them up separately
> > > for each use, which obviously avoids the warning.
> > > 
> > > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > > Fixes: 4c50a8ce2b63 ("netfilter: ipvs: avoid unused variable warning")
> > 
> >       Looks like your previous patch for ip_vs_app_net_cleanup
> > was delayed in ipvs-next tree. I guess, Simon should drop it and
> > use this one instead when net-next opens:
> > 
> > Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> Thanks, and sorry about not pushing the other patch to net-next.
> I have dropped it and queued up this one in its place.

Ah, I had not realized that the other patch was still in ipvs-next
and not merged in mainline. I did most of my testing on linux-next
(with the previous patch) and then validated the new one on
4.5-rc1, which led me to update it to contain the same hunk again.

Replacing the original patch works fine though, thanks for picking
it up!

	Arnd
