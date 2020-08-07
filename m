From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 25/26] net: pass a sockptr_t into ->setsockopt
Date: Fri, 7 Aug 2020 09:21:20 +0200
Message-ID: <20200807072120.GB2086@lst.de>
References: <20200723060908.50081-1-hch@lst.de> <20200723060908.50081-26-hch@lst.de> <6357942b-0b6e-1901-7dce-e308c9fac347@gmail.com>
Mime-Version: 1.0
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6357942b-0b6e-1901-7dce-e308c9fac347@gmail.com>
Sender: linux-hams-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Christoph Hellwig <hch@lst.de>, "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Eric Dumazet <edumazet@google.com>, linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, bpf@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-sctp@vger.kernel.org, linux-hams@vger.kernel.org, linux-bluetooth@vger.kernel.org, bridge@lists.linux-foundation.org, linux-can@vger.kernel.org, dccp@vger.kernel.org, linux-decnet-user@lists.sourceforge.net, linux-wpan@vger.kernel.org, linux-s390@vger.kernel.org, mptcp@lists.01.org, 

On Thu, Aug 06, 2020 at 03:21:25PM -0700, Eric Dumazet wrote:
> converting get_user(...)   to  copy_from_sockptr(...) really assumed the optlen
> has been validated to be >= sizeof(int) earlier.
> 
> Which is not always the case, for example here.

Yes.  And besides the bpfilter mess the main reason I even had to add
the sockptr vs just copying optlen in the high-level socket code.

Please take a look at the patch in the other thread to just revert to
the "dumb" version everywhere.
