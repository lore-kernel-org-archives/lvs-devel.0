From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch net] ipvs: fix active FTP
Date: Thu, 9 Sep 2010 09:27:48 +0900
Message-ID: <20100909002743.GA5783@verge.net.au>
References: <20100906040228.GA21473@verge.net.au>
 <20100908.104033.39195899.davem@davemloft.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100908.104033.39195899.davem@davemloft.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, kaber@trash.net, wensong@linux-vs.org, ja@ssi.bg

On Wed, Sep 08, 2010 at 10:40:33AM -0700, David Miller wrote:
> From: Simon Horman <horms@verge.net.au>
> Date: Mon, 6 Sep 2010 13:02:29 +0900
> 
> > From: Julian Anastasov <ja@ssi.bg>
> > 
> > - Do not create expectation when forwarding the PORT
> >   command to avoid blocking the connection. The problem is that
> >   nf_conntrack_ftp.c:help() tries to create the same expectation later in
> >   POST_ROUTING and drops the packet with "dropping packet" message after
> >   failure in nf_ct_expect_related.
> > 
> > - Change ip_vs_update_conntrack to alter the conntrack
> >   for related connections from real server. If we do not alter the reply in
> >   this direction the next packet from client sent to vport 20 comes as NEW
> >   connection. We alter it but may be some collision happens for both
> >   conntracks and the second conntrack gets destroyed immediately. The
> >   connection stucks too.
> > 
> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> > Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> Applied, thanks.
> 
> > This change is also applicable to net-next, although there is some diff
> > noise. Do you want me to resolve that and post a net-next version
> > separately? (The same applies to "ipvs: avoid oops for passive FTP" which
> > you merged into net last week.)
> 
> No need, the next time I merge net-2.6 into net-next-2.6 it will be
> taken care of transparently.

Great, thanks.
