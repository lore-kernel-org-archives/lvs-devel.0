From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Linux-kernel-mentees] [PATCH net] ipvs: Fix uninit-value in do_ip_vs_set_ctl()
Date: Mon, 10 Aug 2020 20:57:19 -0700
Message-ID: <CAM_iQpWsQubVJ-AYaLHujHwz68+nsHBcbgbf8XPMEPD=Vu+zaA@mail.gmail.com>
References: <20200810220703.796718-1-yepeilin.cs@gmail.com>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=/Ej3O/P5forMr7lkh8Irj0X/aIJv290wNqPXSY+K8SQ=;
        b=Dy6m6mzpsrA6AiUFbCE/bSjm0Ha27RRY29MhbJd/pIkrgoNaBTwHAWHseayvDnrnCA
         HwxjeaxYINZHazGU3LyZTfhUmoxozHW8eUuuTVJ2bChVO3S4jc5gnpGqdixrngOjOvZb
         pT0JrlO6rdHNLUXHOw+rGQRqzehZQ2t0HR9Ie3vLxrt+zMZ3FFs1DyT/jBuUMxkJfg6h
         cMxGGUnbb16zLxzIVzIFBfrt08riVQ01vqyYYEiqsVUQRbTPP4a+aQTdOpE7Um4t77vW
         SGhixNnowuHWYLNeYCXspG6tRjf8su5CFtSR4DePU5Ta+mGtOJLAs6rjesqLj0qHV7qj
         PU3w==
In-Reply-To: <20200810220703.796718-1-yepeilin.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peilin Ye <yepeilin.cs@gmail.com>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Network Developers <netdev@vger.kernel.org>, lvs-devel@vger.kernel.org, NetFilter <netfilter-devel@vger.kernel.org>, coreteam@netfilter.org, linux-kernel-mentees@lists.linuxfoundation.org, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>

On Mon, Aug 10, 2020 at 3:10 PM Peilin Ye <yepeilin.cs@gmail.com> wrote:
>
> do_ip_vs_set_ctl() is referencing uninitialized stack value when `len` is
> zero. Fix it.

Which exact 'cmd' is it here?

I _guess_ it is one of those uninitialized in set_arglen[], which is 0.
But if that is the case, should it be initialized to
sizeof(struct ip_vs_service_user) instead because ip_vs_copy_usvc_compat()
is called anyway. Or, maybe we should just ban len==0 case.

In either case, it does not look like you fix it correctly.

Thanks.
