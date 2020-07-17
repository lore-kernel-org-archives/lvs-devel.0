From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: mmotm 2020-07-16-22-52 uploaded (net: IPVS)
Date: Fri, 17 Jul 2020 08:30:04 -0700
Message-ID: <88196a8a-2778-0324-8005-d63bfee86c4e@infradead.org>
References: <20200717055300.ObseZH9Vs%akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=merlin.20170209; h=Content-Transfer-Encoding:Content-Type:
        In-Reply-To:MIME-Version:Date:Message-ID:From:References:To:Subject:Sender:
        Reply-To:Cc:Content-ID:Content-Description;
        bh=u0q4qCWNv+qhE3ZrdRgzxfegk6XFeYyskQE8fOwRrRs=; b=SggPwLXPaF9DbxaOh0Zz/ED/P0
        6gGiwOd2aUZmcH8TeJ6sct16sXyqz48zefFf2DfupKuLBLJojH900LWWGxhSxVAy2sARrGwWcy8wH
        jDLrEdl0NXk2QgfW8TbtMaXRWrsYrwusbL1lGvgvaG0uMaYBAlRYr0VgwsFZoQpsQriF2SsFn5JtS
        Qf6FjTErWY8Xx4qdJXtxVBYT6WYwWUVkymSpHpVEN0866rVKg/kuR+D1v/X/J/VAiV6sdAKkvaRN0
        QPRYBbqsfp/7Ce1tybB0g4fTb5YX7hc4Tc9+Y0BSPB2k+DRRLzwDq2mk+ltrZ/j+2GOnZqW6Gsmi6
        wNHWnKEg==;
In-Reply-To: <20200717055300.ObseZH9Vs%akpm@linux-foundation.org>
Content-Language: en-US
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Andrew Morton <akpm@linux-foundation.org>, broonie@kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org, mhocko@suse.cz, mm-commits@vger.kernel.org, sfr@canb.auug.org.au, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org

On 7/16/20 10:53 PM, Andrew Morton wrote:
> The mm-of-the-moment snapshot 2020-07-16-22-52 has been uploaded to
> 
>    http://www.ozlabs.org/~akpm/mmotm/
> 
> mmotm-readme.txt says
> 
> README for mm-of-the-moment:
> 
> http://www.ozlabs.org/~akpm/mmotm/
> 
> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> more than once a week.
> 

(also in linux-next)

Many of these errors:

In file included from ../net/netfilter/ipvs/ip_vs_conn.c:37:0:
../include/net/ip_vs.h: In function ‘ip_vs_enqueue_expire_nodest_conns’:
../include/net/ip_vs.h:1536:61: error: parameter name omitted
 static inline void ip_vs_enqueue_expire_nodest_conns(struct netns_ipvs) {}
                                                             ^~~~~~~~~~


-- 
~Randy
Reported-by: Randy Dunlap <rdunlap@infradead.org>
