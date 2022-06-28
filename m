From: Jason Gunthorpe <jgg@ziepe.ca>
Subject: Re: [PATCH][next] treewide: uapi: Replace zero-length arrays with
 flexible-array members
Date: Tue, 28 Jun 2022 15:44:04 -0300
Message-ID: <20220628184404.GS23621@ziepe.ca>
References: <20220627180432.GA136081@embeddedor>
 <6bc1e94c-ce1d-a074-7d0c-8dbe6ce22637@iogearbox.net>
 <20220628004052.GM23621@ziepe.ca>
 <202206281009.4332AA33@keescook>
Mime-Version: 1.0
Return-path: <linux-mips-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=srd0vxfduo9pXREXizXvQ1Gwi/kEACFP1rdXcY0Aglg=;
        b=QDfPPT0fYl+zbzIvYII9znFGb4s02ZWc7rdJXgoVlQii3pb6MPHXUbo2NQcshGpobE
         dWlWXPBgu4AcM4BoWih7Z1Nr6ImLeGEz2FZoCblM4qyf8MsycIzs6ej4nXX7nwNpGP6Q
         WS2wAoLm7tunOmWFHsCTXENR5aJ2dwangh3Hiy+KajaZLCQ31/GJ39i5LG+HlW0f/4Yp
         DzCT3gMR3JvAVHruRt3NJZXTCo87e7XIf3RRiCTD40KLgGYQ8Oy9U016RK3fPhyNykEI
         VcI+7whSObzV9gDqoR9iwpi6V1hWpQPbHnX1dl7fE5ec/owdsM9r7W03JXKpNXxaLmSi
         lJng==
Content-Disposition: inline
In-Reply-To: <202206281009.4332AA33@keescook>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kees Cook <keescook@chromium.org>
Cc: Daniel Borkmann <daniel@iogearbox.net>, "Gustavo A. R. Silva" <gustavoars@kernel.org>, linux-kernel@vger.kernel.org, x86@kernel.org, dm-devel@redhat.com, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-s390@vger.kernel.org, kvm@vger.kernel.org, intel-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, netdev@vger.kernel.org, bpf@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-can@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux1394-devel@lists.sourceforge.net, io-uring@vger.kernel.org, lvs-devel@vger.kernel.org, linux-mtd@lists.infradead.org, kasan-dev@googlegroups.com, linux-mmc@vger.kernel.org, nvdimm@lists.linux.dev, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-perf-users@vger.kernel.org, linux-raid@vger.kernel.org, l

On Tue, Jun 28, 2022 at 10:54:58AM -0700, Kees Cook wrote:

 
> which must also be assuming it's a header. So probably better to just
> drop the driver_data field? I don't see anything using it (that I can
> find) besides as a sanity-check that the field exists and is at the end
> of the struct.

The field is guaranteeing alignment of the following structure. IIRC
there are a few cases that we don't have a u64 already to force this.

Jason
