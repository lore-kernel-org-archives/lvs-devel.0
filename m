From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 2/2] ipvs: Fix reuse connection if real server is dead
Date: Thu, 23 May 2013 13:34:35 +0200
Message-ID: <20130523113435.GA30773@localhost>
References: <1369202209-18570-1-git-send-email-horms@verge.net.au>
 <1369202209-18570-3-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1369202209-18570-3-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Grzegorz Lyczba <grzegorz.lyczba@gmail.com>

Hi Simon,

On Wed, May 22, 2013 at 02:56:49PM +0900, Simon Horman wrote:
> From: Grzegorz Lyczba <grzegorz.lyczba@gmail.com>
> 
> Expire cached connection for new TCP/SCTP connection if real server is down

We can get this fix into 3.10-rc.

Please, address the comestic cleanups proposed by Sergei and resubmit
against the nf tree.

Thanks.
