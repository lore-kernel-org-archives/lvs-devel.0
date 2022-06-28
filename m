From: "Gustavo A. R. Silva" <gustavoars@kernel.org>
Subject: Re: [PATCH][next] treewide: uapi: Replace zero-length arrays with
 flexible-array members
Date: Tue, 28 Jun 2022 16:18:23 +0200
Message-ID: <20220628141823.GB25163@embeddedor>
References: <20220627180432.GA136081@embeddedor>
 <20220627125343.44e24c41@hermes.local>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <linux-fsdevel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1656425908;
        bh=gNqsfpabtVurh3KrN/HDHkVIuq5HYEGkFj0dq9pxBp0=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=LKmDxdeiZbNhcfCtRCGKrWsyjlCMGrWNe6JPI6+0Ud4+CdurjXwUmrO+N85g9uStN
         ZMyX+h6jcWDShk2bKHv4I1CwjG76KgIokSJRaPNHE+tAExMRqCJhyYb+qk23PpSnt8
         UZagMIRlLLl0N2746CMcacDFBvR451lE95WpeBq0GW4QDuaouxlRRNIVOVHDclrQ6f
         3R9oBNaPqtGDm4Fzozu0TEhclsuvbNSWpoAarBMEoFPJEcd4AO2pVjb65zJgdF1PVp
         ef3Ggil+1czhmYD/i4aHezmCjBjk3ri61YXhTXJoT9Ami17Y24U2vq1uockAAm5n3K
         LL1PsE5NQ0Syg==
Content-Disposition: inline
In-Reply-To: <20220627125343.44e24c41@hermes.local>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Stephen Hemminger <stephen@networkplumber.org>
Cc: Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, x86@kernel.org, dm-devel@redhat.com, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-s390@vger.kernel.org, kvm@vger.kernel.org, intel-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, netdev@vger.kernel.org, bpf@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-can@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux1394-devel@lists.sourceforge.net, io-uring@vger.kernel.org, lvs-devel@vger.kernel.org, linux-mtd@lists.infradead.org, kasan-dev@googlegroups.com, linux-mmc@vger.kernel.org, nvdimm@lists.linux.dev, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-perf-users@vger.kernel.org, linux-raid@vger.kernel.org, linux-sctp@vger.kernel.org, linux-stm32@st-md-mailman

On Mon, Jun 27, 2022 at 12:53:43PM -0700, Stephen Hemminger wrote:
> Thanks this fixes warning with gcc-12 in iproute2.
> In function ‘xfrm_algo_parse’,
>     inlined from ‘xfrm_state_modify.constprop’ at xfrm_state.c:573:5:
> xfrm_state.c:162:32: warning: writing 1 byte into a region of size 0 [-Wstringop-overflow=]
>   162 |                         buf[j] = val;
>       |                         ~~~~~~~^~~~~

Great! This gives me hope. :)

Thanks
--
Gustavo
