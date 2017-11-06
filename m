From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 13/14] netfilter/ipvs: Use %pS printk format for direct
 addresses
Date: Mon, 6 Nov 2017 14:46:08 +0100
Message-ID: <20171106134608.GA6081@salvia>
References: <1504729681-3504-1-git-send-email-deller@gmx.de>
 <1504729681-3504-14-git-send-email-deller@gmx.de>
 <20171009055224.GB31804@verge.net.au>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171009055224.GB31804@verge.net.au>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Helge Deller <deller@gmx.de>, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Petr Mladek <pmladek@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Wensong Zhang <wensong@linux-vs.org>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org

On Mon, Oct 09, 2017 at 07:52:24AM +0200, Simon Horman wrote:
> On Wed, Sep 06, 2017 at 10:28:00PM +0200, Helge Deller wrote:
> > The debug and error printk functions in ipvs uses wrongly the %pF instead of
> > the %pS printk format specifier for printing symbols for the address returned
> > by _builtin_return_address(0). Fix it for the ia64, ppc64 and parisc64
> > architectures.
> > 
> > Signed-off-by: Helge Deller <deller@gmx.de>
> > Cc: Wensong Zhang <wensong@linux-vs.org>
> > Cc: netdev@vger.kernel.org
> > Cc: lvs-devel@vger.kernel.org
> > Cc: netfilter-devel@vger.kernel.org
> 
> Sorry for the delay in processing this.
> 
> Acked-by: Simon Horman <horms@verge.net.au>
> 
> Pablo, could you take this through the nf-next tree directly?

Applied, thanks.
