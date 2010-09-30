From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch v2] ipvs: IPv6 tunnel mode
Date: Thu, 30 Sep 2010 10:22:40 +0900
Message-ID: <20100930012239.GA18392@verge.net.au>
References: <20100927135913.GA21785@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100927135913.GA21785@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, Julian Anastasov <ja@ssi.bg>, Julius Volz <juliusv@google.com>, Wensong Zhang <wensong@linux-vs.org>, Patrick McHardy <kaber@trash.net>

On Mon, Sep 27, 2010 at 10:59:14PM +0900, Simon Horman wrote:
> From: Julian Anastasov <ja@ssi.bg>
> 
> Tunnel mode for IPv6 doesn't work.

Patrick, can you please drop this patch for now.
Hans has found some problems with it.

http://archive.linuxvirtualserver.org/html/lvs-devel/2010-09/msg00073.html
