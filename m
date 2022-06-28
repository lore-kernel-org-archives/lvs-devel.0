From: Jason Gunthorpe <jgg@ziepe.ca>
Subject: Re: [PATCH][next] treewide: uapi: Replace zero-length arrays with
 flexible-array members
Date: Mon, 27 Jun 2022 21:40:52 -0300
Message-ID: <20220628004052.GM23621@ziepe.ca>
References: <20220627180432.GA136081@embeddedor>
 <6bc1e94c-ce1d-a074-7d0c-8dbe6ce22637@iogearbox.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <bpf-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to;
        bh=nrCjPCGAs4MTUiLBt7Ijf/MJPuIyH6lM8yqPhdyhJD8=;
        b=QGfGz2XeyaJLxS6IycR7jteyzbs2f9vu4fQQcftWhoNW5sUtbyuMKwRS5XXshn3Hg2
         yZubOZXW72TGsXoMKBc9lhqncUYMSH0Z6bymz383cNPRRHeF7rKM5RXMNm4Eaw5tsGTg
         BQX0bHWNlf6m2F5J4oWG32dxQT2CTBmnGX6tl+1lipYgts8fc/1uUmHwN5t3zZzoA6Qn
         DTeDwoNVOxWo0hy32OR9hFE/UO0/97qh5eo+5ewqu/iIRVMFQ1AIctopaFBuZOm9BPLs
         HAx/pGMXLvvVO6Cb9sesF2T5smUMb44u7gsx78px69APS8fFzY4PmSgo/WM3D328ZbRr
         X/FA==
Content-Disposition: inline
In-Reply-To: <6bc1e94c-ce1d-a074-7d0c-8dbe6ce22637@iogearbox.net>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Daniel Borkmann <daniel@iogearbox.net>
Cc: "Gustavo A. R. Silva" <gustavoars@kernel.org>, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, x86@kernel.org, dm-devel@redhat.com, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-s390@vger.kernel.org, kvm@vger.kernel.org, intel-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, netdev@vger.kernel.org, bpf@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-can@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux1394-devel@lists.sourceforge.net, io-uring@vger.kernel.org, lvs-devel@vger.kernel.org, linux-mtd@lists.infradead.org, kasan-dev@googlegroups.com, linux-mmc@vger.kernel.org, nvdimm@lists.linux.dev, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-perf-users@vger.kernel.org, linux-raid@vger.kernel.org, linux-

On Mon, Jun 27, 2022 at 08:27:37PM +0200, Daniel Borkmann wrote:
> On 6/27/22 8:04 PM, Gustavo A. R. Silva wrote:
> > There is a regular need in the kernel to provide a way to declare
> > having a dynamically sized set of trailing elements in a structure.
> > Kernel code should always use “flexible array members”[1] for these
> > cases. The older style of one-element or zero-length arrays should
> > no longer be used[2].
> > 
> > This code was transformed with the help of Coccinelle:
> > (linux-5.19-rc2$ spatch --jobs $(getconf _NPROCESSORS_ONLN) --sp-file script.cocci --include-headers --dir . > output.patch)
> > 
> > @@
> > identifier S, member, array;
> > type T1, T2;
> > @@
> > 
> > struct S {
> >    ...
> >    T1 member;
> >    T2 array[
> > - 0
> >    ];
> > };
> > 
> > -fstrict-flex-arrays=3 is coming and we need to land these changes
> > to prevent issues like these in the short future:
> > 
> > ../fs/minix/dir.c:337:3: warning: 'strcpy' will always overflow; destination buffer has size 0,
> > but the source string has length 2 (including NUL byte) [-Wfortify-source]
> > 		strcpy(de3->name, ".");
> > 		^
> > 
> > Since these are all [0] to [] changes, the risk to UAPI is nearly zero. If
> > this breaks anything, we can use a union with a new member name.
> > 
> > [1] https://en.wikipedia.org/wiki/Flexible_array_member
> > [2] https://www.kernel.org/doc/html/v5.16/process/deprecated.html#zero-length-and-one-element-arrays
> > 
> > Link: https://github.com/KSPP/linux/issues/78
> > Build-tested-by: https://lore.kernel.org/lkml/62b675ec.wKX6AOZ6cbE71vtF%25lkp@intel.com/
> > Signed-off-by: Gustavo A. R. Silva <gustavoars@kernel.org>
> > ---
> > Hi all!
> > 
> > JFYI: I'm adding this to my -next tree. :)
> 
> Fyi, this breaks BPF CI:
> 
> https://github.com/kernel-patches/bpf/runs/7078719372?check_suite_focus=true
> 
>   [...]
>   progs/map_ptr_kern.c:314:26: error: field 'trie_key' with variable sized type 'struct bpf_lpm_trie_key' not at the end of a struct or class is a GNU extension [-Werror,-Wgnu-variable-sized-type-not-at-end]
>           struct bpf_lpm_trie_key trie_key;
>                                   ^

This will break the rdma-core userspace as well, with a similar
error:

/usr/bin/clang-13 -DVERBS_DEBUG -Dibverbs_EXPORTS -Iinclude -I/usr/include/libnl3 -I/usr/include/drm -g -O2 -fdebug-prefix-map=/__w/1/s=. -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2 -Wmissing-prototypes -Wmissing-declarations -Wwrite-strings -Wformat=2 -Wcast-function-type -Wformat-nonliteral -Wdate-time -Wnested-externs -Wshadow -Wstrict-prototypes -Wold-style-definition -Werror -Wredundant-decls -g -fPIC   -std=gnu11 -MD -MT libibverbs/CMakeFiles/ibverbs.dir/cmd_flow.c.o -MF libibverbs/CMakeFiles/ibverbs.dir/cmd_flow.c.o.d -o libibverbs/CMakeFiles/ibverbs.dir/cmd_flow.c.o   -c ../libibverbs/cmd_flow.c
In file included from ../libibverbs/cmd_flow.c:33:
In file included from include/infiniband/cmd_write.h:36:
In file included from include/infiniband/cmd_ioctl.h:41:
In file included from include/infiniband/verbs.h:48:
In file included from include/infiniband/verbs_api.h:66:
In file included from include/infiniband/ib_user_ioctl_verbs.h:38:
include/rdma/ib_user_verbs.h:436:34: error: field 'base' with variable sized type 'struct ib_uverbs_create_cq_resp' not at the end of a struct or class is a GNU extension [-Werror,-Wgnu-variable-sized-type-not-at-end]
        struct ib_uverbs_create_cq_resp base;
                                        ^
include/rdma/ib_user_verbs.h:644:34: error: field 'base' with variable sized type 'struct ib_uverbs_create_qp_resp' not at the end of a struct or class is a GNU extension [-Werror,-Wgnu-variable-sized-type-not-at-end]
        struct ib_uverbs_create_qp_resp base;

Which is why I gave up trying to change these..

Though maybe we could just switch off -Wgnu-variable-sized-type-not-at-end  during configuration ?

Jason
