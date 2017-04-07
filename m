From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] net: netfilter: Use seq_puts()/seq_putc() where possible
Date: Fri, 7 Apr 2017 17:30:22 +0200
Message-ID: <20170407153022.GB1466@salvia>
References: <20170328215517.GA18237@singhal-Inspiron-5558>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170328215517.GA18237@singhal-Inspiron-5558>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: simran singhal <singhalsimran0@gmail.com>
Cc: wensong@linux-vs.org, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org, outreachy-kernel@googlegroups.com

On Wed, Mar 29, 2017 at 03:25:17AM +0530, simran singhal wrote:
> For string without format specifiers, use seq_puts(). For
> seq_printf("\n"), use seq_putc('\n').

Applied, thanks.
