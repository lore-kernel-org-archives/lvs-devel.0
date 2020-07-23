From: 'Christoph Hellwig' <hch@lst.de>
Subject: Re: [PATCH 03/26] bpfilter: reject kernel addresses
Date: Thu, 23 Jul 2020 16:44:55 +0200
Message-ID: <20200723144455.GA12280@lst.de>
References: <20200723060908.50081-1-hch@lst.de> <20200723060908.50081-4-hch@lst.de> <c3dc5b4d84e64230bb6ca8df7bb70705@AcuMS.aculab.com>
Mime-Version: 1.0
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <c3dc5b4d84e64230bb6ca8df7bb70705@AcuMS.aculab.com>
Sender: linux-hams-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight@ACULAB.COM>
Cc: 'Christoph Hellwig' <hch@lst.de>, "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Eric Dumazet <edumazet@google.com>, "linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "bpf@vger.kernel.org" <bpf@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, "coreteam@netfilter.org" <coreteam@netfilter.org>, "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>, "linux-hams@vger.kernel.org" <linux-hams@vger.kernel.org>

On Thu, Jul 23, 2020 at 02:42:11PM +0000, David Laight wrote:
> From: Christoph Hellwig
> > Sent: 23 July 2020 07:09
> > 
> > The bpfilter user mode helper processes the optval address using
> > process_vm_readv.  Don't send it kernel addresses fed under
> > set_fs(KERNEL_DS) as that won't work.
> 
> What sort of operations is the bpf filter doing on the sockopt buffers?
> 
> Any attempts to reject some requests can be thwarted by a second
> application thread modifying the buffer after the bpf filter has
> checked that it allowed.
> 
> You can't do security by reading a user buffer twice.

I'm not saying that I approve of the design, but the current bpfilter
design uses process_vm_readv to access the buffer, which obviously does
not work with kernel buffers.
