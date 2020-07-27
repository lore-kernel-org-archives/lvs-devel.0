From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: get rid of the address_space override in setsockopt v2
Date: Mon, 27 Jul 2020 14:09:09 +0000
Message-ID: <5d958e937db54849b4ef9046e7e12277@AcuMS.aculab.com>
References: <20200723060908.50081-1-hch@lst.de>
 <20200724.154342.1433271593505001306.davem@davemloft.net>
 <8ae792c27f144d4bb5cbea0c1cce4eed@AcuMS.aculab.com>
 <20200727134814.GD794331@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Transfer-Encoding: 8BIT
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20200727134814.GD794331@ZenIV.linux.org.uk>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: 'Al Viro' <viro@zeniv.linux.org.uk>
Cc: 'David Miller' <davem@davemloft.net>, "hch@lst.de" <hch@lst.de>, "kuba@kernel.org" <kuba@kernel.org>, "ast@kernel.org" <ast@kernel.org>, "daniel@iogearbox.net" <daniel@iogearbox.net>, "kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>, "yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>, "edumazet@google.com" <edumazet@google.com>, "linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "bpf@vger.kernel.org" <bpf@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, "coreteam@netfilter.org" <coreteam@netfilter.org>, "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>, "linux-hams@vger.kernel.org" <linux-hams@vger.kernel.o>

From: Al Viro
> Sent: 27 July 2020 14:48
> 
> On Mon, Jul 27, 2020 at 09:51:45AM +0000, David Laight wrote:
> 
> > I'm sure there is code that processes options in chunks.
> > This probably means it is possible to put a chunk boundary
> > at the end of userspace and continue processing the very start
> > of kernel memory.
> >
> > At best this faults on the kernel copy code and crashes the system.
> 
> Really?  Care to provide some details, or is it another of your "I can't
> be possibly arsed to check what I'm saying, but it stands for reason
> that..." specials?

I did more 'homework' than sometimes :-)
Slightly difficult without a searchable net-next tree.
However, as has been pointed out is a different thread
this code is used to update IPv6 flow labels:

> > -		if (copy_from_user(fl->opt+1, optval+CMSG_ALIGN(sizeof(*freq)), olen))
> > +		sockptr_advance(optval, CMSG_ALIGN(sizeof(*freq)));
> > +		if (copy_from_sockptr(fl->opt + 1, optval, olen))
> >  			goto done;

and doesn't work because the advances are no longer cumulative.

Now access_ok() has to take the base address and length to stop
'running into' kernel space, but the code above can advance from
a valid user pointer (which won't fault) to a kernel address.

If there were always an unmapped 'guard' page in the user address
space the access_ok() check prior to copy_to/from_user() wouldn't
need the length.
So I surmise that no such guard page exists and so the above
can advance from user addresses into kernel ones.

	David

-
Registered Address Lakeside, Bramley Road, Mount Farm, Milton Keynes, MK1 1PT, UK
Registration No: 1397386 (Wales)

