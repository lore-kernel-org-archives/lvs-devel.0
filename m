From: yangxingwu <xingwu.yang@gmail.com>
Subject: Re: [PATCH] ipvs: Fix reuse connection if RS weight is 0
Date: Thu, 28 Oct 2021 10:50:00 +0800
Message-ID: <CA+7U5JuxN1BSneYuiZde_kZRNpPDuT23Wn7_Uyv12yk26tXEzA@mail.gmail.com>
References: <20211025115910.2595-1-xingwu.yang@gmail.com> <707b5fb3-6b61-c53-e983-bc1373aa2bf@ssi.bg>
 <CA+7U5JsSuwqP7eHj1tMHfsb+EemwrhZEJ2b944LFWTroxAnQRQ@mail.gmail.com>
 <1190ef60-3ad9-119e-5336-1c62522aec81@ssi.bg> <CA+7U5JvvsNejgOifAwDdjddkLHUL30JPXSaDBTwysSL7dhphuA@mail.gmail.com>
 <CA+7U5Jta_g2vCXiwScVVwLZppWp51TDOB7LxUxeundkPxNZYnA@mail.gmail.com> <35e6215-4fb3-5149-a888-67aa6fae958f@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ZIj8JUAa/oKHTviYbVQQPi5hTbJg26A4cMkQ91+NOI8=;
        b=iZ0NK8UU6jtSoNk8YFG/C/0ZrYxJp3ssvBFgVcBvZgrxo9WuTceVxZB2S/SLU1Qvbs
         BBsbwbXXYm7q0hx5iKdqjKl+pBjARCIP4tXohpNC6DGM9fin60TEzIMXbTDzHbrgFueE
         KuDGrQ6uuKxSbG2zaJ3MUHSYNwB05x+w5UAkne8B6NFsB4lORD7mjgV1B4d7lQxHQ0ov
         O2BBsbB0cWHi0i0CXs8wCGY1x/+J4Tfrkb7NdZAl1H37fI+46fQVtT2A+IMm7seG7ul/
         B1EKUouwzqWkXuYJuIDq31/EtIzFoZkmrsNcJLUqL+8KA3toIRERpwpsM0c4n2YGpjC6
         Baog==
In-Reply-To: <35e6215-4fb3-5149-a888-67aa6fae958f@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org

hello

On Thu, Oct 28, 2021 at 5:09 AM Julian Anastasov <ja@ssi.bg> wrote:
>
>
>         Hello,
>
> On Wed, 27 Oct 2021, yangxingwu wrote:
>
> > what we want is if RS weight is 0, then no new connections should be
> > served even if conn_reuse_mode is 0, just as commit dc7b3eb900aa
> > ("ipvs: Fix reuse connection if real server is
> > dead") trying to do
> >
> > Pls let me know if there are any other issues of concern
>
>         My concern is with the behaviour people expect
> from each sysctl var: conn_reuse_mode decides if port reuse
> is considered for rescheduling and expire_nodest_conn
> should have priority only for unavailable servers (nodest means
> No Destination), not in this case.
>
>         We don't know how people use the conn_reuse_mode=0
> mode, one may bind to a local port and try to send multiple
> connections in a row with the hope they will go to same real
> server, i.e. as part from same "session", even while weight=0.
> If they do not want such behaviour (99% of the cases), they
> will use the default conn_reuse_mode=1. OTOH, you have different
> expectations for mode 0, not sure why but you do not want to use
> the default mode=1 which is safer to use. May be the setups
> forget to stay with conn_reuse_mode=1 on kernels 5.9+ and
> set the var to 0 ?

The problem is we can NOT decide what the customers do, many of them
run kubernetes with old versions of kube-proxy. And most importantly,
upgrade to new version is a very long and painful process, that's why
we want to fix this at the kernel level

>         The problem with mentioned commit dc7b3eb900aa is that
> it breaks FTP and persistent connections while the goal of
> weight=0 is graceful inhibition of the server. We made
> the mistake to add priority for expire_nodest_conn when weight=0.
> This can be fixed with a !cp->control check. We do not want
> expire_nodest_conn to kill every connection during the
> graceful period.

ok, got it, I will try to fix this problem

> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
