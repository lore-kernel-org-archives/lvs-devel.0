From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 19/26] net/ipv6: switch ipv6_flowlabel_opt to sockptr_t
Date: Mon, 27 Jul 2020 15:00:29 +0200
Message-ID: <20200727130029.GA26393@lst.de>
References: <20200723060908.50081-1-hch@lst.de> <20200723060908.50081-20-hch@lst.de> <20200727121505.GA1804864@shredder>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20200727121505.GA1804864@shredder>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ido Schimmel <idosch@idosch.org>
Cc: Christoph Hellwig <hch@lst.de>, "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Eric Dumazet <edumazet@google.com>, linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, bpf@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-sctp@vger.kernel.org, linux-hams@vger.kernel.org, linux-bluetooth@vger.kernel.org, bridge@lists.linux-foundation.org, linux-can@vger.kernel.org, dccp@vger.kernel.org, linux-decnet-user@lists.sourceforge.net, linux-wpan@vger.kernel.org, linux-s390@vger.kernel.org, mptcp@lists.01.org, 

On Mon, Jul 27, 2020 at 03:15:05PM +0300, Ido Schimmel wrote:
> I see a regression with IPv6 flowlabel that I bisected to this patch.
> When passing '-F 0' to 'ping' the flow label should be random, yet it's
> the same every time after this patch.

Can you send a reproducer?

> 
> It seems that the pointer is never advanced after the call to
> sockptr_advance() because it is passed by value and not by reference.
> Even if you were to pass it by reference I think you would later need to
> call sockptr_decrease() or something similar. Otherwise it is very
> error-prone.
> 
> Maybe adding an offset to copy_to_sockptr() and copy_from_sockptr() is
> better?

We could do that, although I wouldn't add it to the existing functions
to avoid the churns and instead add copy_to_sockptr_offset or something
like that.
