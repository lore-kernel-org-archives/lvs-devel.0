From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] ipvs: autoload ipvs on genl access
Date: Fri, 22 Oct 2021 14:10:30 +0200
Message-ID: <YXKqNos44XqQYXOi@salvia>
References: <20211021130255.4177-1-linux@weissschuh.net>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20211021130255.4177-1-linux@weissschuh.net>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="windows-1252"
To: Thomas =?utf-8?Q?Wei=C3=9Fschuh?= <linux@weissschuh.net>
Cc: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

On Thu, Oct 21, 2021 at 03:02:55PM +0200, Thomas Wei=C3=9Fschuh wrote:
> The kernel provides the functionality to automatically load modules
> providing genl families. Use this to remove the need for users to
> manually load the module.

Applied, thanks
