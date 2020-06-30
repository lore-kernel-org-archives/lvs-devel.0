From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next] ipvs: register hooks only with services
Date: Tue, 30 Jun 2020 17:23:48 +0200
Message-ID: <20200630152348.GB12560@vergenet.net>
References: <20200621154030.10998-1-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20200621154030.10998-1-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, netfilter-devel@vger.kernel.org

On Sun, Jun 21, 2020 at 06:40:30PM +0300, Julian Anastasov wrote:
> Keep the IPVS hooks registered in Netfilter only
> while there are configured virtual services. This
> saves CPU cycles while IPVS is loaded but not used.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Thanks Julian, this looks good to me.

Reviewed-by: Simon Horman <horms@verge.net.au>

Pablo, could you consider this for nf-next?
