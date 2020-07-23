From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 04/26] net: add a new sockptr_t type
Date: Thu, 23 Jul 2020 18:44:32 +0200
Message-ID: <20200723164432.GA20917@lst.de>
References: <20200723060908.50081-1-hch@lst.de> <20200723060908.50081-5-hch@lst.de> <CANn89iJ3LKth-iWwh0+P3D3RqtDNv4AyXkkzhXr0oSEvE_JoRQ@mail.gmail.com>
Mime-Version: 1.0
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CANn89iJ3LKth-iWwh0+P3D3RqtDNv4AyXkkzhXr0oSEvE_JoRQ@mail.gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Eric Dumazet <edumazet@google.com>
Cc: Christoph Hellwig <hch@lst.de>, "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, netdev <netdev@vger.kernel.org>, bpf <bpf@vger.kernel.org>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-sctp@vger.kernel.org, linux-hams@vger.kernel.org, linux-bluetooth@vger.kernel.org, bridge@lists.linux-foundation.org, linux-can@vger.kernel.org, dccp@vger.kernel.org, linux-decnet-user@lists.sourceforge.net, linux-wpan@vger.kernel.org, linux-s390@vger.ker

On Thu, Jul 23, 2020 at 09:40:27AM -0700, Eric Dumazet wrote:
> I am not sure why you chose sockptr_t   for something that really seems generic.
> 
> Or is it really meant to be exclusive to setsockopt() and/or getsockopt() ?
> 
> If the first user of this had been futex code, we would have used
> futexptr_t, I guess.

It was originally intended to be generic and called uptr_t, based
on me misunderstanding that Linus wanted a file operation for it,
which he absolutely didn't and hate with passion.  So the plan is to
only use it for setsockopt for now, although there are some arguments
for also using it in sendmsg/recvmsg.  There is no need to use it for
getsockopt.
