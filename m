From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] IPVS: Allow boot time change of hash size.
Date: Tue, 05 Jan 2010 05:56:29 +0100
Message-ID: <4B42C67D.6010905@trash.net>
References: <20100105002018.GJ2554@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20100105002018.GJ2554@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, "Catalin(ux) M. BOIE" <catab@embedromix.ro>, Mark Bergsma <mark@wikimedia.org>, Joseph Mack NA3T <jmack@wm7d.net>, Graeme Fowler <graeme@graemef.net>, David Miller <davem@davemloft.net>

Simon Horman wrote:
> From: Catalin(ux) M. BOIE <catab@embedromix.ro>
> 
> IPVS: Allow boot time change of hash size.
> 
> I was very frustrated about the fact that I have to recompile the kernel
> to change the hash size. So, I created this patch.
> 
> If IPVS is built-in you can append ip_vs.conn_tab_bits=?? to kernel
> command line, or, if you built IPVS as modules, you can add
> options ip_vs conn_tab_bits=??.
> 
> To keep everything backward compatible, you still can select the size at
> compile time, and that will be used as default.
> 
> [ horms@verge.net.au: trivial up-port and minor style fixes ]
> Signed-off-by: Catalin(ux) M. BOIE <catab@embedromix.ro>
> Cc: Mark Bergsma <mark@wikimedia.org>
> Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> ---
> 
> Patrick, please consider applying this. I'd like to do something dynamic.
> But this change is an obvious win in the mean time.

Applied to nf-next-2.6.git, thanks.
