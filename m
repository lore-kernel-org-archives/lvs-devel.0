From: Jacky Hu <hengqing.hu@gmail.com>
Subject: Re: [PATCH v3] ipvs: allow tunneling with gue encapsulation
Date: Sat, 16 Mar 2019 20:15:07 +0800
Message-ID: <20190316121507.GA32042@i716>
References: <20190316072009.2247-1-hengqing.hu@gmail.com>
 <20190316090649.mm7fskvzx5hzp672@salvia>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=wX0+RhRVXnGfkIonRB0TJgpOIjfOJjR0TKpZGa+6gsk=;
        b=Ouwox/aCVl3nDyIay7jRKjIR4F2pNVyTM0Du021bc0OhKkid9AHNWeExDxDhiOvyil
         Mc6VwlVKDj3yZ5SBcaq9HLQXG7yjJjXo0oclsESvmm5ZMRlvmNe+SSAbq7IXytZtiGhA
         YFTnPFlnA4j9kklFczVeKc4adBhhpSR7cYNCi4D9Ikb4NsG5Bm7zCfeVF4DsfPbDPgSP
         pf7d/2uNfwdA5NNktrOnz6cigWAtnFdk8CTdaJGaCnshRDKjG3tEd0m86+5l2FupZ6Es
         bw6r1S62jI2WacTxwrP5QlfvQBl4DxSsztq1QSIOMexQ+3aH6qoBOm3NF4h47dxjF1wF
         qjiw==
Content-Disposition: inline
In-Reply-To: <20190316090649.mm7fskvzx5hzp672@salvia>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: jacky.hu@walmart.com, jason.niesz@walmart.com, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, "David S. Miller" <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org

Here is the report:
Added break statements for switch cases to avoid fall through.
It makes iptunnel_handle_offloads gets proper gso_type_mask.

Thanks!
