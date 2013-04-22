From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch] ipvs: off by one in set_sctp_state()
Date: Mon, 22 Apr 2013 12:30:16 +0300
Message-ID: <20130422093016.GB8936@mwanda>
References: <20130420112455.GA30198@elgon.mountain>
 <alpine.LFD.2.00.1304201504510.1593@ja.ssi.bg>
 <20130422041151.GM15680@verge.net.au>
 <alpine.LFD.2.00.1304220843560.1626@ja.ssi.bg>
 <51750016.5080600@gmail.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <51750016.5080600@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Moahn Reddy <mohanreddykv@gmail.com>
Cc: Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, coreteam@netfilter.org

On Mon, Apr 22, 2013 at 02:47:10PM +0530, Moahn Reddy wrote:
> Hi,
> 
> I see there is no problem in the code regarding the state change.
> And the thing why I took 255 in the sctp_events array is that as per
> the sctp specification, the 255 message is reserved, so I thought 0
> to 254 messages are enough.

The issue is can chunk_type in set_sctp_state() be 255?  How is
this prevented in the code?

regards,
dan carpenter

