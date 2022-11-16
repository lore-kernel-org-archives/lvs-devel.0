From: Jiri Wiesner <jwiesner@suse.de>
Subject: Re: [RFC PATCHv6 3/7] ipvs: use u64_stats_t for the per-cpu counters
Date: Wed, 16 Nov 2022 18:37:12 +0100
Message-ID: <20221116173712.GL3484@incl>
References: <20221031145647.156930-1-ja@ssi.bg>
 <20221031145647.156930-4-ja@ssi.bg>
 <20221112090001.GH3484@incl>
 <20221112090910.GI3484@incl>
 <a7bf3435-aa8f-31a5-b93b-f0ad58fdc3a4@ssi.bg>
 <20221115122602.GJ3484@incl>
 <2152a987-19ee-083-d6f8-5ad73d8f83c@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
        t=1668620233; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=d8S/siVMdegdETGjBApK2ZQn8AXjBXCAVGgYNlpCfdM=;
        b=XnjEFY6nvndbkp7fpjt3tfLmD36miAg97Zzgktu7cTkhjC4CPMUt5FCFfVa09RJUjYOV/+
        KXE5p4oBOgHdmMk92liDPJcAOji0pzyYM3kNg+ENUBps0hakw6OEPwvyDtqcWbQ5t7RIwg
        +rFQy4Gn2e64QDdrh/mM2YYbj4uVepk=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
        s=susede2_ed25519; t=1668620233;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=d8S/siVMdegdETGjBApK2ZQn8AXjBXCAVGgYNlpCfdM=;
        b=ObxtzHi4FCKFpTSx2jnR0aNH/0UHTF00jHZc5fkU4OALge4S3R7uq1geuPmgPw2xc7osDV
        avpbAjUasLMIhRBA==
Content-Disposition: inline
In-Reply-To: <2152a987-19ee-083-d6f8-5ad73d8f83c@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>, dust.li@linux.alibaba.com

On Tue, Nov 15, 2022 at 06:53:22PM +0200, Julian Anastasov wrote:
> 	Bad, same register RDX used. I guess, this is
> CONFIG_GENERIC_CPU=y kernel which is suitable for different
> CPUs.

Yes, it is. I use SUSE's distro config.

-- 
Jiri Wiesner
SUSE Labs
