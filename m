From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net v2 0/2] fix glitch in IPVS /proc handlers
Date: Mon, 28 Jan 2019 11:17:13 +0100
Message-ID: <20190128101713.tuthooahqonvesyk@salvia>
References: <20180731160333.12215-1-mcroce@redhat.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20180731160333.12215-1-mcroce@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matteo Croce <mcroce@redhat.com>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>

On Tue, Jul 31, 2018 at 06:03:31PM +0200, Matteo Croce wrote:
> Fix a bug which shows negative values in IPVS /proc handlers.
> Also add an helper function to calculate a time delta

Series applied, thanks Matteo.
