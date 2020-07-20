From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 03/24] net: add a new sockptr_t type
Date: Mon, 20 Jul 2020 19:43:22 +0200
Message-ID: <20200720174322.GA21785@lst.de>
References: <20200720124737.118617-1-hch@lst.de> <20200720124737.118617-4-hch@lst.de> <20200720163748.GA1292162@gmail.com>
Mime-Version: 1.0
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20200720163748.GA1292162@gmail.com>
Sender: linux-hams-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Eric Biggers <ebiggers@kernel.org>
Cc: Christoph Hellwig <hch@lst.de>, "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Eric Dumazet <edumazet@google.com>, linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, bpf@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-sctp@vger.kernel.org, linux-hams@vger.kernel.org, linux-bluetooth@vger.kernel.org, bridge@lists.linux-foundation.org, linux-can@vger.kernel.org, dccp@vger.kernel.org, linux-decnet-user@lists.sourceforge.net, linux-wpan@vger.kernel.org, linux-s390@vger.kernel.org, mptcp@lists.01.org, 

On Mon, Jul 20, 2020 at 09:37:48AM -0700, Eric Biggers wrote:
> How does this not introduce a massive security hole when
> CONFIG_ARCH_HAS_NON_OVERLAPPING_ADDRESS_SPACE?
> 
> AFAICS, userspace can pass in a pointer >= TASK_SIZE,
> and this code makes it be treated as a kernel pointer.

Yeah, we'll need to validate that before initializing the pointer.

But thinking this a little further:  doesn't this mean any
set_fs(KERNEL_DS) that has other user pointers than the one it is
intended for has the same issue?  Pretty much all of these are gone
in mainline now, but in older stable kernels there might be some
interesting cases, especially in the compat ioctl handlers.
