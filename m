From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net] ipvs: clear skb->tstamp in forwarding path
Date: Mon, 12 Oct 2020 02:00:58 +0200
Message-ID: <20201012000058.GA9184@salvia>
References: <20201009182425.9050-1-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20201009182425.9050-1-ja@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, Evgeny B <abt-admin@mail.ru>, Eric Dumazet <eric.dumazet@gmail.com>

On Fri, Oct 09, 2020 at 09:24:25PM +0300, Julian Anastasov wrote:
> fq qdisc requires tstamp to be cleared in forwarding path

Applied, thanks.
