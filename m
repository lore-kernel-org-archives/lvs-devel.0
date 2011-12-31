From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] ipvs: try also real server with port 0 in backup server
Date: Sat, 31 Dec 2011 16:08:51 +0100
Message-ID: <20111231150851.GC17062@1984>
References: <1325222342-20240-1-git-send-email-horms@verge.net.au>
 <1325222342-20240-2-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1325222342-20240-2-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Patrick McHardy <kaber@trash.net>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Fri, Dec 30, 2011 at 02:19:02PM +0900, Simon Horman wrote:
> From: Julian Anastasov <ja@ssi.bg>
> 
> 	We should not forget to try for real server with port 0
> in the backup server when processing the sync message. We should
> do it in all cases because the backup server can use different
> forwarding method.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Simon Horman <horms@verge.net.au>

Applied, thanks!
