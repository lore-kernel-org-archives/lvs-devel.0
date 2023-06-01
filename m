From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] ipvs: dynamically limit the connection hash
 table
Date: Thu, 1 Jun 2023 21:18:05 +0200
Message-ID: <ZHju7cARozHokVFU@calendula>
References: <20230517123731.56733-1-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20230517123731.56733-1-ja@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, Abhijeet Rastogi <abhijeet.1989@gmail.com>

On Wed, May 17, 2023 at 03:37:31PM +0300, Julian Anastasov wrote:
> As we allow the hash table to be configured to rows above 2^20,
> we should limit it depending on the available memory to some
> sane values. Switch to kvmalloc allocation to better select
> the needed allocation type.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
>  net/netfilter/ipvs/ip_vs_conn.c | 26 +++++++++++++++++---------
>  1 file changed, 17 insertions(+), 9 deletions(-)
> 
>  NOTE: This patch needs to be applied on top of V3 (or above) of patch
>  "ipvs: increase ip_vs_conn_tab_bits range for 64BIT" from Abhijeet

Done, thanks for this note.

Applied to nf-next, thanks.
