From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next] netfilter:ipvs: use kmemdup
Date: Mon, 7 Mar 2011 14:04:56 +0900
Message-ID: <20110307050456.GA2811@verge.net.au>
References: <4D743ED6.5010608@cn.fujitsu.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4D743ED6.5010608@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Shan Wei <shanwei@cn.fujitsu.com>
Cc: Wensong Zhang <wensong@linux-vs.org>, ja@ssi.bg, Patrick McHardy <kaber@trash.net>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org

On Mon, Mar 07, 2011 at 10:11:34AM +0800, Shan Wei wrote:
> The semantic patch that makes this output is available
> in scripts/coccinelle/api/memdup.cocci.
> 
> More information about semantic patching is available at
> http://coccinelle.lip6.fr/

Thanks, applied.
