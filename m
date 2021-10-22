From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: autoload ipvs on genl access
Date: Fri, 22 Oct 2021 13:26:31 +0200
Message-ID: <20211022112629.GA22404@vergenet.net>
References: <20211021130255.4177-1-linux@weissschuh.net>
 <c473dd-51ee-4358-4496-61c9c75f875@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <c473dd-51ee-4358-4496-61c9c75f875@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Julian Anastasov <ja@ssi.bg>
Cc: Thomas =?utf-8?Q?Wei=C3=9Fschuh?= <linux@weissschuh.net>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

On Thu, Oct 21, 2021 at 09:24:34PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 21 Oct 2021, Thomas Weißschuh wrote:
> 
> > The kernel provides the functionality to automatically load modules
> > providing genl families. Use this to remove the need for users to
> > manually load the module.
> > 
> > Signed-off-by: Thomas Weißschuh <linux@weissschuh.net>
> 
> 	Looks good to me for -next tree, thanks!
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>

Acked-by: Simon Horman <horms@verge.net.au>

