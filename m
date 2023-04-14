From: Abhijeet Rastogi <abhijeet.1989@gmail.com>
Subject: Re: [PATCH] ipvs: change ip_vs_conn_tab_bits range to [8,31]
Date: Thu, 13 Apr 2023 18:58:06 -0700
Message-ID: <CACXxYfxLU0jWmq0W7YxX=44XFCGvgMX2HwTFUUHCUMjO28g5BA@mail.gmail.com>
References: <20230412-increase_ipvs_conn_tab_bits-v1-1-60a4f9f4c8f2@gmail.com> <d2519ce3-e49b-a544-b79d-42905f4a2a9a@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20221208; t=1681437523; x=1684029523;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:from:to:cc:subject:date:message-id:reply-to;
        bh=Dl2518gfS/Q1UTQTLUFTF13BLaNUhIq99/jZxFoVTE8=;
        b=dbFOmnvXWendtqHNWAnIIVQIAq5jJpuLDcEXgMFqI9KaQWq7P5E/IYMfFyG4lMrryj
         GWiDAIG7yiXx2GbkQLiJcfm4WP7f+TG/jGVIdYV4/kv7atqDhOZwQiQEEhLBFxEJyNNJ
         Uf0nPRy0nNqI7zzcmYYtMATxZgrJhhcrCAWm0USCkRQvkzupQVv5xNqjv00vGBGzSE2Q
         zU2QSSe4VhBo9fed9Z8lkZpM4K/6vsxBRt2jyGtFITzTK1Z3nvQ0gj/IY2wt7L4ugiog
         xaGZQ+lkOAvAYeCxylJ7eET8v7HZVcFKyXIbKBsD9gkpBaDNBRcLaAtdYGlp12okckka
         JRkQ==
In-Reply-To: <d2519ce3-e49b-a544-b79d-42905f4a2a9a@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

Hi Simon, Andrea and Julian,

I really appreciate you taking the time to respond to my patch. Some follow up
questions that I'll appreciate a response for.

@Simon Horman
>In any case, I think this patch is an improvement on the current situation.

+1 to this. I wanted to add that, we're not changing the defaults
here, the default still stays at 2^12. If a kernel user changes the
default, they probably already know what the limitations are, so I
personally don't think it is a big concern.

@Andrea Claudi
>for the record, RHEL ships with CONFIG_IP_VS_TAB_BITS set to 12 as
default.

Sorry, I should have been clearer. RHEL ships with the same default,
yes, but it doesn't have the range check, at least, on the version I'm
using right now (3.10.0-1160.62.1.el7.x86_64).

On this version, I'm able to load with bit size 30, 31 gives me error
regarding allocating memory (64GB host) and anything beyond 31 is
mysteriously switched to a lower number. The following dmesg on my
host confirms that the bitsize 30 worked, which is not possible
without a patch on the current kernel version.

"[Fri Apr 14 01:14:51 2023] IPVS: Connection hash table configured (size=1073741
824, memory=16777216Kbytes)"

@Julian Anastasov,
>This is not a limit of number of connections. I prefer
not to allow value above 24 without adding checks for the
available memory,

Interesting that you brought up that number 24, that is exactly what
we use in production today. One IPVS node is able to handle spikes of
10M active connections without issues. This patch idea originated as
my company is migrating from the ancient RHEL version to a somewhat
newer CentOS (5.* kernel) and noticed that we were unable to load the
ip_vs kernel module with anything greater than 20 bits. Another
motivation for kernel upgrade is utilizing maglev to reduce table size
but that's out of context in this discussion.

My request is, can we increase the range from 20 to something larger?
If 31 seems a bit excessive, maybe, we can settle for something like
[8,30] or even lower. With conn_tab_bits=30, it allocates 16GB at
initialization time, it is not entirely absurd by today's standards.

I can revise my patch to a lower range as you guys see fit.

--
Cheers,
Abhijeet (https://abhi.host)
