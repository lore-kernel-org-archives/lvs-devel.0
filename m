From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch v2.8 2/4] IPVS: make friends with nf_conntrack
Date: Fri, 23 Jul 2010 12:47:28 +0200
Message-ID: <4C497340.1010305@trash.net>
References: <20100722073547.504156161@vergenet.net> <20100722075012.658190199@vergenet.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100722075012.658190199@vergenet.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org, Malcolm Turnbull <malcolm@loadbalancer.org>, Mark Brooks <mark@loadbalancer.org>, Wensong Zhang <wensong@linux-vs.org>, Julius Volz <julius.volz@gmail.com>, "David S. Miller" <davem@davemloft.net>, Hannes Eder <heder@google.com>, Jan Engelhardt <jengelh@medozas.de>

Am 22.07.2010 09:35, schrieb Simon Horman:
> Update the nf_conntrack tuple in reply direction, as we will see
> traffic from the real server (RIP) to the client (CIP).  Once this is
> done we can use netfilters SNAT in POSTROUTING, especially with
> xt_ipvs, to do source NAT, e.g.:
> 
> % iptables -t nat -A POSTROUTING -m ipvs --vaddr 192.168.100.30/32 --vport 80 \
>> > -j SNAT --to-source 192.168.10.10

Applied, thanks.
