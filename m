From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH][next] treewide: uapi: Replace zero-length arrays with
 flexible-array members
Date: Tue, 28 Jun 2022 11:05:53 -0700
Message-ID: <202206281104.7CC3935@keescook>
References: <20220627180432.GA136081@embeddedor>
 <CAMuHMdU27TG_rpd=WTRPRcY22A4j4aN-6d_8OmK2aNpX06G3ig@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <bpf-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to;
        bh=pTcGgtfSu6n7KkCWKQ4ciWe5XeKK5S4riO8KfNVW7Ig=;
        b=F/CZTCTDOlhkWqZ+vOzW0DaoZ/EZ1dOhoCSSJ2RrwBNwuY7CCyvEtaLLk8DO+FYVI8
         oY1bh2Rw2NH/e7uwuajkABgxQQynq/vb9wDrQT1ziurYSmeBDoqa9s9XGmGLyXXXVu1m
         Ptj/OKkdrLcBprdD9gQ9RffSNU26yKh9HCJiI=
Content-Disposition: inline
In-Reply-To: <CAMuHMdU27TG_rpd=WTRPRcY22A4j4aN-6d_8OmK2aNpX06G3ig@mail.gmail.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: "Gustavo A. R. Silva" <gustavoars@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, dm-devel@redhat.com, linux-m68k <linux-m68k@lists.linux-m68k.org>, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, KVM list <kvm@vger.kernel.org>, Intel Graphics Development <intel-gfx@lists.freedesktop.org>, DRI Development <dri-devel@lists.freedesktop.org>, netdev <netdev@vger.kernel.org>, bpf <bpf@vger.kernel.org>, linux-btrfs <linux-btrfs@vger.kernel.org>, linux-can@vger.kernel.org, Linux FS Devel <linux-fsdevel@vger.kernel.org>, linux1394-devel@lists.sourceforge.net, io-uring@vger.kernel.org, lvs-devel@vger.kernel.org, MTD Maling List <linux-mtd@lists.infradea>

On Tue, Jun 28, 2022 at 09:27:21AM +0200, Geert Uytterhoeven wrote:
> Hi Gustavo,
> 
> Thanks for your patch!
> 
> On Mon, Jun 27, 2022 at 8:04 PM Gustavo A. R. Silva
> <gustavoars@kernel.org> wrote:
> > There is a regular need in the kernel to provide a way to declare
> > having a dynamically sized set of trailing elements in a structure.
> > Kernel code should always use “flexible array members”[1] for these
> > cases. The older style of one-element or zero-length arrays should
> > no longer be used[2].
> 
> These rules apply to the kernel, but uapi is not considered part of the
> kernel, so different rules apply.  Uapi header files should work with
> whatever compiler that can be used for compiling userspace.

Right, userspace isn't bound by these rules, but the kernel ends up
consuming these structures, so we need to fix them. The [0] -> []
changes (when they are not erroneously being used within other
structures) is valid for all compilers. Flexible arrays are C99; it's
been 23 years. :)

But, yes, where we DO break stuff we need to workaround it, etc.

-- 
Kees Cook
