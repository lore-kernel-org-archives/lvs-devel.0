From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] ip_vs_sh: fix build
Date: Wed, 29 May 2013 17:51:57 +0200
Message-ID: <20130529155157.GA23067@localhost>
References: <51A611CF02000078000D99A6@nat28.tlf.novell.com>
 <20130529145906.GA9929@verge.net.au>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130529145906.GA9929@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Jan Beulich <JBeulich@suse.com>, wensong@linux-vs.org, ja@ssi.bg, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

On Wed, May 29, 2013 at 11:59:06PM +0900, Simon Horman wrote:
> On Wed, May 29, 2013 at 01:33:51PM +0100, Jan Beulich wrote:
> > kfree_rcu() requires offsetof(..., rcu_head) < 4096, which can get
> > violated with a sufficiently high CONFIG_IP_VS_SH_TAB_BITS.
> > 
> > Signed-off-by: Jan Beulich <jbeulich@suse.com>
> 
> Thanks Jan.
> 
> Pablo, could you take this one directly into your tree?
> 
> Signed-off-by: Simon Horman <horms@verge.net.au>

Applied, thanks Simon.
