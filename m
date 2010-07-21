From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [patch v2.6 4/4] libxt_ipvs: user-space lib for netfilter matcher
 xt_ipvs
Date: Wed, 21 Jul 2010 15:28:16 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1007211526490.25445@obet.zrqbmnf.qr>
References: <20100711090342.035149543@vergenet.net> <20100711090500.421568837@vergenet.net> <20100721012146.GC22966@verge.net.au> <alpine.LSU.2.01.1007210834570.10568@obet.zrqbmnf.qr> <20100721132159.GN6418@verge.net.au>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100721132159.GN6418@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org, Malcolm Turnbull <malcolm@loadbalancer.org>, Wensong Zhang <wensong@linux-vs.org>, Julius Volz <julius.volz@gmail.com>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, Hannes Eder <heder@google.com>


On Wednesday 2010-07-21 15:21, Simon Horman wrote:
>> On Wednesday 2010-07-21 03:21, Simon Horman wrote:
>> >> +
>> >> +#define XT_IPVS_IPVS_PROPERTY	(1 << 0) /* all other options imply this one */
>> >> +#define XT_IPVS_PROTO		(1 << 1)
>> >> +#define XT_IPVS_VADDR		(1 << 2)
>> >> +#define XT_IPVS_VPORT		(1 << 3)
>> >> +#define XT_IPVS_DIR		(1 << 4)
>> >> +#define XT_IPVS_METHOD		(1 << 5)
>> >> +#define XT_IPVS_VPORTCTL	(1 << 6)
>> >> +#define XT_IPVS_MASK		((1 << 7) - 1)
>> >> +#define XT_IPVS_ONCE_MASK	(XT_IPVS_MASK & ~XT_IPVS_IPVS_PROPERTY)
>> 
>> Can't these just be an enum?
>
>More than one option can be used at once - they form a mini bitmap -
>so no, I don't think we can use an enum.

An enum does not dictate that you cannot combine values of it with itself.

	enum { A = 1 << 0, B = 1 << 0, };
	unsigned int flags = A | B;

is perfectly fine, which is what other modules do.
