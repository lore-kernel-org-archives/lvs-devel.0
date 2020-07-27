From: Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: get rid of the address_space override in setsockopt v2
Date: Mon, 27 Jul 2020 14:48:14 +0100
Message-ID: <20200727134814.GD794331@ZenIV.linux.org.uk>
References: <20200723060908.50081-1-hch@lst.de>
 <20200724.154342.1433271593505001306.davem@davemloft.net>
 <8ae792c27f144d4bb5cbea0c1cce4eed@AcuMS.aculab.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <8ae792c27f144d4bb5cbea0c1cce4eed@AcuMS.aculab.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight@aculab.com>
Cc: 'David Miller' <davem@davemloft.net>, "hch@lst.de" <hch@lst.de>, "kuba@kernel.org" <kuba@kernel.org>, "ast@kernel.org" <ast@kernel.org>, "daniel@iogearbox.net" <daniel@iogearbox.net>, "kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>, "yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>, "edumazet@google.com" <edumazet@google.com>, "linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "bpf@vger.kernel.org" <bpf@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, "coreteam@netfilter.org" <coreteam@netfilter.org>, "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>, "linux-hams@vger.kernel.org" <linux-hams@vger.kernel.o>

On Mon, Jul 27, 2020 at 09:51:45AM +0000, David Laight wrote:

> I'm sure there is code that processes options in chunks.
> This probably means it is possible to put a chunk boundary
> at the end of userspace and continue processing the very start
> of kernel memory.
> 
> At best this faults on the kernel copy code and crashes the system.

Really?  Care to provide some details, or is it another of your "I can't
be possibly arsed to check what I'm saying, but it stands for reason
that..." specials?
