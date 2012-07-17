From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 3/3] ipvs: fix oops in ip_vs_dst_event on rmmod
Date: Tue, 17 Jul 2012 12:08:47 +0200
Message-ID: <20120717100847.GB3812@1984>
References: <1341965963-7275-1-git-send-email-horms@verge.net.au>
 <1341965963-7275-4-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1341965963-7275-4-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Jesper Dangaard Brouer <brouer@redhat.com>

On Wed, Jul 11, 2012 at 09:19:23AM +0900, Simon Horman wrote:
> From: Julian Anastasov <ja@ssi.bg>
> 
> 	After commit 39f618b4fd95ae243d940ec64c961009c74e3333 (3.4)
> "ipvs: reset ipvs pointer in netns" we can oops in
> ip_vs_dst_event on rmmod ip_vs because ip_vs_control_cleanup
> is called after the ipvs_core_ops subsys is unregistered and
> net->ipvs is NULL. Fix it by exiting early from ip_vs_dst_event
> if ipvs is NULL. It is safe because all services and dests
> for the net are already freed.

Applied, thanks.
