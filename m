From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch v2.8 3/4] IPVS: make FTP work with full NAT support
Date: Fri, 23 Jul 2010 12:49:39 +0200
Message-ID: <4C4973C3.5060409@trash.net>
References: <20100722073547.504156161@vergenet.net> <20100722075012.950341908@vergenet.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100722075012.950341908@vergenet.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org, Malcolm Turnbull <malcolm@loadbalancer.org>, Mark Brooks <mark@loadbalancer.org>, Wensong Zhang <wensong@linux-vs.org>, Julius Volz <julius.volz@gmail.com>, "David S. Miller" <davem@davemloft.net>, Hannes Eder <heder@google.com>, Jan Engelhardt <jengelh@medozas.de>

Am 22.07.2010 09:35, schrieb Simon Horman:
> From:	Hannes Eder <heder@google.com>
> 
> Use nf_conntrack/nf_nat code to do the packet mangling and the TCP
> sequence adjusting.  The function 'ip_vs_skb_replace' is now dead
> code, so it is removed.
> 
> To SNAT FTP, use something like:
> 
> % iptables -t nat -A POSTROUTING -m ipvs --vaddr 192.168.100.30/32 \
>> --vport 21 -j SNAT --to-source 192.168.10.10
> 
> and for the data connections in passive mode:
> 
> % iptables -t nat -A POSTROUTING -m ipvs --vaddr 192.168.100.30/32 \
>> --vportctl 21 -j SNAT --to-source 192.168.10.10
> 
> using '-m state --state RELATED' would also works.
> 
> Make sure the kernel modules ip_vs_ftp, nf_conntrack_ftp, and
> nf_nat_ftp are loaded.
> 

Applied, thanks.
