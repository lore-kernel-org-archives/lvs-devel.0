From: Andrea Claudi <aclaudi@redhat.com>
Subject: Re: [PATCH] ipvs: change ip_vs_conn_tab_bits range to [8,31]
Date: Tue, 18 Apr 2023 13:58:46 +0200
Message-ID: <ZD6F9l2yE0i42YE5@renaissance-vector>
References: <20230412-increase_ipvs_conn_tab_bits-v1-1-60a4f9f4c8f2@gmail.com>
 <d2519ce3-e49b-a544-b79d-42905f4a2a9a@ssi.bg>
 <CACXxYfxLU0jWmq0W7YxX=44XFCGvgMX2HwTFUUHCUMjO28g5BA@mail.gmail.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1681819133;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=ic+G8JxkY030ztDDxrSVr0gIWS+MILOdZNy5BfZjtHQ=;
        b=GRokVicCAK5z3JYvEz1SaiJmczut8JZ4kCvrVdQz46bWtN3LyCV0MvTo/UL8QPWaWl2/mS
        olStiqtLIENXN96jgEO0eOILmEWJ7y5O1LyhGKxyDiWvl0NW1aQheQYjMl1SWksJeewSpc
        0u87/uSfQlvOJaTwTjhwtbH11RodILM=
Content-Disposition: inline
In-Reply-To: <CACXxYfxLU0jWmq0W7YxX=44XFCGvgMX2HwTFUUHCUMjO28g5BA@mail.gmail.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Abhijeet Rastogi <abhijeet.1989@gmail.com>
Cc: Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

On Thu, Apr 13, 2023 at 06:58:06PM -0700, Abhijeet Rastogi wrote:
> Hi Simon, Andrea and Julian,
> 
> I really appreciate you taking the time to respond to my patch. Some follow up
> questions that I'll appreciate a response for.
> 
> @Simon Horman
> >In any case, I think this patch is an improvement on the current situation.
> 
> +1 to this. I wanted to add that, we're not changing the defaults
> here, the default still stays at 2^12. If a kernel user changes the
> default, they probably already know what the limitations are, so I
> personally don't think it is a big concern.
> 
> @Andrea Claudi
> >for the record, RHEL ships with CONFIG_IP_VS_TAB_BITS set to 12 as
> default.
> 
> Sorry, I should have been clearer. RHEL ships with the same default,
> yes, but it doesn't have the range check, at least, on the version I'm
> using right now (3.10.0-1160.62.1.el7.x86_64).
> 
> On this version, I'm able to load with bit size 30, 31 gives me error
> regarding allocating memory (64GB host) and anything beyond 31 is
> mysteriously switched to a lower number. The following dmesg on my
> host confirms that the bitsize 30 worked, which is not possible
> without a patch on the current kernel version.
> 
> "[Fri Apr 14 01:14:51 2023] IPVS: Connection hash table configured (size=1073741
> 824, memory=16777216Kbytes)"

I see. This makes sense to me as RHEL 7 does not include the range
check, while RHEL 8 and RHEL 9 both includes it.

The reason why any number beyond 31 results in a lower number is to be
searched in gcc implementation. IIRC shifting an int by more than 31 or
less than 0 results in an undefined behaviour, according to the C
standard.

> 
> @Julian Anastasov,
> >This is not a limit of number of connections. I prefer
> not to allow value above 24 without adding checks for the
> available memory,
> 
> Interesting that you brought up that number 24, that is exactly what
> we use in production today. One IPVS node is able to handle spikes of
> 10M active connections without issues. This patch idea originated as
> my company is migrating from the ancient RHEL version to a somewhat
> newer CentOS (5.* kernel) and noticed that we were unable to load the
> ip_vs kernel module with anything greater than 20 bits. Another
> motivation for kernel upgrade is utilizing maglev to reduce table size
> but that's out of context in this discussion.
> 
> My request is, can we increase the range from 20 to something larger?
> If 31 seems a bit excessive, maybe, we can settle for something like
> [8,30] or even lower. With conn_tab_bits=30, it allocates 16GB at
> initialization time, it is not entirely absurd by today's standards.
> 
> I can revise my patch to a lower range as you guys see fit.
> 
> --
> Cheers,
> Abhijeet (https://abhi.host)
> 

