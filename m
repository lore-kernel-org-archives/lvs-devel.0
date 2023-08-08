From: Chris Maness <christopher.maness@gmail.com>
Subject: Re: [PATCH v2 00/14] sysctl: Add a size argument to register
 functions in sysctl
Date: Mon, 7 Aug 2023 20:07:24 -0700
Message-ID: <CANnsUMGHnurbph9F7mex=1s0mxhwpNgeQbKJ6j1r37Qmd6LAMQ@mail.gmail.com>
References: <20230731071728.3493794-1-j.granados@samsung.com>
 <ZMgpck0rjqHR74sl@bombadil.infradead.org> <ZNFlqwwvE6w6HyHl@bombadil.infradead.org>
 <CANnsUMG3WO_19GpnsNaXPqu6eEnpBvYUpkrf1QbHwsc9wEoCZQ@mail.gmail.com>
 <ZNGBrkP7J2g/BAWV@bombadil.infradead.org> <CANnsUMGRBnatKB4-3eYjb5aG7YnXDiZG6cjuwSgtjvVF6ErJNg@mail.gmail.com>
 <ZNGv3Q5VBsS2/w4e@bombadil.infradead.org>
Mime-Version: 1.0
Return-path: <linux-hams-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20221208; t=1691464055; x=1692068855;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:from:to:cc:subject:date:message-id:reply-to;
        bh=0G2Gm44L7ws5E/quoPqMuJmdghfzOor5wGEa6AaRIig=;
        b=MIB1dRWNV6Yb3HUd1qPb/bgwaoUzAlGVu8CxiiwIDYwN4TMseNzdPMVbuAfPyciWjI
         AZzeBtiA00C4EVQ8EGlp9e8Q3pbBFc8aCRl+HJu3YtRoio8lAQY1qu2UvIE5hChxs5Q1
         PKMC/y7tlRiDWg5YOtPXbZsaYs//GKuhiSEDo5WpI7edOLzGAaAJjqvFIOQWWQAuLo7Z
         JBsPnB5UvxOuJ1p76ZyxSuA7+KQWE3J2jS89kM5pl3PIv+dMsBBD/LquAyRZomdcC7zN
         v+sSG+iPprRQeQoEH+XZP/GEzjEboCjqHBhNwHzm7vxhsHdZplrvrz31A5i2G+xxBQ4/
         u+EA==
In-Reply-To: <ZNGv3Q5VBsS2/w4e@bombadil.infradead.org>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Luis Chamberlain <mcgrof@kernel.org>
Cc: Alexander Aring <alex.aring@gmail.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Catalin Marinas <catalin.marinas@arm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, "D. Wythe" <alibuda@linux.alibaba.com>, David Ahern <dsahern@kernel.org>, "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, Florian Westphal <fw@strlen.de>, Heiko Carstens <hca@linux.ibm.com>, Herbert Xu <herbert@gondor.apana.org.au>, Iurii Zaikin <yzaikin@google.com>, Jakub Kicinski <kuba@kernel.org>, Jan Karcher <jaka@linux.ibm.com>, Joel Granados <joel.granados@gmail.com>, Joel Granados <j.granados@samsung.com>, Joerg Reuter <jreuter@yaina.de>, Jozsef Kadlecsik <kadlec@netfilter.org>, Julian Anastasov <ja@ssi.bg>, Karsten Graul <k>

>
> Are you reporting a separate regression that goes all the way back to v4 kernels?
>

I am not certain what you mean by regression.

> > v2 is fine there.
>
> What does this mean?

I have to go all the way back to kernel version 2 for the serial 6PACK
driver to work.  If I try to use it in Kernel version 4, 5, or 6 the
kernel panics as soon as I attempt to connect to another station.

>
>   Luis

Chris KQ6UP


-- 
Thanks,
Chris Maness
