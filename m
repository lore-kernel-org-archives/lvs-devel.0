From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: get rid of the address_space override in setsockopt
Date: Wed, 22 Jul 2020 10:09:41 -0700
Message-ID: <CAADnVQKy0+rsRftEzp4PvxQtj7uOwybz0Nd4_h0FR37p2Q=X4w@mail.gmail.com>
References: <20200720124737.118617-1-hch@lst.de> <20200720204756.iengwcguikj2yrxt@ast-mbp.dhcp.thefacebook.com>
 <20200722075657.GB26554@lst.de>
Mime-Version: 1.0
Return-path: <linux-hams-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=nqelWpCqH7nOe0oSyngzrBNpGRC3PyDyz91JHpls3Xk=;
        b=QbFOpYWq197fvdaI4E7hogiJ5z6DhlnMwFbSAyObyOYxQk/ojAWvAxU5xeCwIzRoyp
         bGpv6okHRbaDCk3F5IJgGXS3Wesi1t0HKLxD0rWbntKFa+o4FEuZ/aNqddB2gT9rJhFi
         ekTLt46VwAAqYYSOS+Ti6gpiM2sULyDbPlDxrV2EC1wYfvYmkCiCMfUA2sia4+eUOZSm
         DpKqJKTrsnJtuquGnG9/42hXesw1S5DhQmqbpijEy6OLbaHF8RyBbV+paN+wC914K+DB
         Om2JyFGEZL8bVoXG7xFZFOn3b/hxnJAALpQKOVax/+9YzLSzmIzDLinAT6/sMjMDDXxC
         pBiA==
In-Reply-To: <20200722075657.GB26554@lst.de>
Sender: linux-hams-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Eric Dumazet <edumazet@google.com>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Network Development <netdev@vger.kernel.org>, bpf <bpf@vger.kernel.org>, netfilter-devel <netfilter-devel@vger.kernel.org>, coreteam@netfilter.org, linux-sctp@vger.kernel.org, linux-hams@vger.kernel.org, linux-bluetooth@vger.kernel.org, "moderated list:ETHERNET BRIDGE" <bridge@lists.linux-foundation.org>, linux-can@vger.kernel.org, dccp@vger.kernel.org, linux-decnet-user@lists.sourceforge.net

On Wed, Jul 22, 2020 at 12:56 AM Christoph Hellwig <hch@lst.de> wrote:
>
> On Mon, Jul 20, 2020 at 01:47:56PM -0700, Alexei Starovoitov wrote:
> > > a kernel pointer.  This is something that works for most common sockopts
> > > (and is something that the ePBF support relies on), but unfortunately
> > > in various corner cases we either don't use the passed in length, or in
> > > one case actually copy data back from setsockopt, so we unfortunately
> > > can't just always do the copy in the highlevel code, which would have
> > > been much nicer.
> >
> > could you rebase on bpf-next tree and we can route it this way then?
> > we'll also test the whole thing before applying.
>
> The bpf-next tree is missing all my previous setsockopt cleanups, so
> there series won't apply.

Right. I've realized that after sending that email two days ago.
Now bpf-next->net-next PR is pending and as soon as it's merged
bpf-next will have all the recent bits.
