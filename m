From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v7] ipvs: allow tunneling with gue encapsulation
Date: Mon, 8 Apr 2019 23:23:45 +0200
Message-ID: <20190408212345.s5t2mcghps6v7fsx@salvia>
References: <20190326103121.31083-1-hengqing.hu@gmail.com>
 <20190328095950.66xhna76xndokdp6@verge.net.au>
 <20190328114708.GA10198@i716>
 <20190328123909.5uqvokkcxh2sjvfl@verge.net.au>
 <20190328134726.GA2246@i716>
 <20190329094142.klmglehcsgdakpr6@verge.net.au>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20190329094142.klmglehcsgdakpr6@verge.net.au>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Jacky Hu <hengqing.hu@gmail.com>, jacky.hu@walmart.com, jason.niesz@walmart.com, "David S. Miller" <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org

On Fri, Mar 29, 2019 at 10:41:42AM +0100, Simon Horman wrote:
> Thanks for answering all my questions. I now am happy with this patch.
> Please do consider the follow-up work on csum support.
> 
> Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> Pablo, please consider applying to nf-next.

Applied, thanks Simon.
