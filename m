From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch] ipvs: fwmark services don't have ports
Date: Mon, 7 Dec 2009 19:48:00 +1100
Message-ID: <20091207084800.GA9529@verge.net.au>
References: <20091207035505.GC419@verge.net.au>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091207035505.GC419@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: Deon van der Merwe <dvdm@truteq.co.za>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

On Mon, Dec 07, 2009 at 02:55:05PM +1100, Simon Horman wrote:
> Make sure that the port for fwmark services is always zero, it seems that
> in some cases ipvsadm provides bogus port values for fwmark services.  As
> observed by Deon van der Merwe, this manifests as a clients not being able
> to connect to the virtual service if persistence is set.
> 
> Tested-by: Deon van der Merwe <dvdm@truteq.co.za>
> Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> --- 
> 
> I believe that this fixes a bug and as such is suitable for -stable.
> However, Its taken a few release for anyone to bring this to our attention,
> so it doesn't seem to be causing much pain in the wild.
> 
> Discussion of this problem:
> http://archive.linuxvirtualserver.org/html/lvs-users/2009-11/msg00043.html

Sorry for the noise. Please hold on this.
There is still not consensus in the original thread.

