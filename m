From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 6/8] net/netfilter/ipvs/ip_vs_ftp.c: Use standardized
 format in sprintf
Date: Mon, 11 Jan 2010 11:54:14 +0100
Message-ID: <4B4B0356.9080006@trash.net>
References: <cover.1262726222.git.joe@perches.com> <da25f48ee7959e83a18e3705c223c8619e508bf4.1262726222.git.joe@perches.com> <20100106023416.GB18557@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100106023416.GB18557@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: Joe Perches <joe@perches.com>, linux-kernel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, coreteam@netfilter.org

Simon Horman wrote:
> On Tue, Jan 05, 2010 at 05:20:18PM -0800, Joe Perches wrote:
>> Use the same format string as net/ipv4/netfilter/nf_nat_ftp.c
>> to encode an ipv4 address and port.
>>
>> Both uses should be a single common function.
>>
>> Signed-off-by: Joe Perches <joe@perches.com>
> 
> Acked-by: Simon Horman <horms@verge.net.au>

Applied, thanks.
