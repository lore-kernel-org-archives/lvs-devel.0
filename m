From: Christoph Hellwig <hch@lst.de>
Subject: Re: get rid of the address_space override in setsockopt
Date: Wed, 22 Jul 2020 09:56:57 +0200
Message-ID: <20200722075657.GB26554@lst.de>
References: <20200720124737.118617-1-hch@lst.de> <20200720204756.iengwcguikj2yrxt@ast-mbp.dhcp.thefacebook.com>
Mime-Version: 1.0
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20200720204756.iengwcguikj2yrxt@ast-mbp.dhcp.thefacebook.com>
Sender: linux-crypto-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: Christoph Hellwig <hch@lst.de>, "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Eric Dumazet <edumazet@google.com>, linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, bpf@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-sctp@vger.kernel.org, linux-hams@vger.kernel.org, linux-bluetooth@vger.kernel.org, bridge@lists.linux-foundation.org, linux-can@vger.kernel.org, dccp@vger.kernel.org, linux-decnet-user@lists.sourceforge.net, linux-wpan@vger.kernel.org, linux-s390@vger.kernel.org, mptcp@lists.01.org, 

On Mon, Jul 20, 2020 at 01:47:56PM -0700, Alexei Starovoitov wrote:
> > a kernel pointer.  This is something that works for most common sockopts
> > (and is something that the ePBF support relies on), but unfortunately
> > in various corner cases we either don't use the passed in length, or in
> > one case actually copy data back from setsockopt, so we unfortunately
> > can't just always do the copy in the highlevel code, which would have
> > been much nicer.
> 
> could you rebase on bpf-next tree and we can route it this way then?
> we'll also test the whole thing before applying.

The bpf-next tree is missing all my previous setsockopt cleanups, so
there series won't apply.
