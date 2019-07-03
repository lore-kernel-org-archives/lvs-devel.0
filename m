From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: linux-next: Tree for Jul 3 (netfilter/ipvs/)
Date: Wed, 3 Jul 2019 21:09:53 +0200
Message-ID: <20190703190953.jybqfokxbgtuijyu@salvia>
References: <20190703214900.45e94ae4@canb.auug.org.au>
 <406d9741-68ad-f465-1248-64eef05b1350@infradead.org>
 <alpine.LFD.2.21.1907032126220.3226@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.21.1907032126220.3226@ja.home.ssi.bg>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Randy Dunlap <rdunlap@infradead.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Linux Next Mailing List <linux-next@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, lvs-devel@vger.kernel.org

On Wed, Jul 03, 2019 at 09:29:26PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Wed, 3 Jul 2019, Randy Dunlap wrote:
> 
> > On 7/3/19 4:49 AM, Stephen Rothwell wrote:
> > > Hi all,
> > > 
> > > Changes since 20190702:
> > > 
> > 
> > on i386:
> 
> 	Oh, well. net/gre.h was included by CONFIG_NF_CONNTRACK, so
> it is failing when CONFIG_NF_CONNTRACK is not used.
> 
> 	Pablo, should I post v2 or just a fix?

I let you choose.
