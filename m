From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: fix matching of fwmark templates during scheduling
Date: Mon, 13 Feb 2012 11:33:33 +0900
Message-ID: <20120213023331.GA30193@verge.net.au>
References: <1327628727-22482-1-git-send-email-horms@verge.net.au>
 <1327628727-22482-2-git-send-email-horms@verge.net.au>
 <20120209151507.GA5842@1984>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120209151507.GA5842@1984>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Patrick McHardy <kaber@trash.net>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, stable@vger.kernel.org

On Thu, Feb 09, 2012 at 04:15:07PM +0100, Pablo Neira Ayuso wrote:
> On Fri, Jan 27, 2012 at 10:45:27AM +0900, Simon Horman wrote:
> > From: Julian Anastasov <ja@ssi.bg>
> > 
> > 	Commit f11017ec2d1859c661f4e2b12c4a8d250e1f47cf (2.6.37)
> > moved the fwmark variable in subcontext that is invalidated before
> > reaching the ip_vs_ct_in_get call. As vaddr is provided as pointer
> > in the param structure make sure the fwmark variable is in
> > same context. As the fwmark templates can not be matched,
> > more and more template connections are created and the
> > controlled connections can not go to single real server.
> > 
> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> > Cc: stable@vger.kernel.org
> > Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> Applied, thanks. I'll pass it to davem.
> 
> I'll pass it to stable once this hits Linus tree.

Thanks
