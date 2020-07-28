From: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [PATCH 12/26] netfilter: switch nf_setsockopt to sockptr_t
Date: Tue, 28 Jul 2020 08:07:11 +0000
Message-ID: <908ed73081cc42d58a5b01e0c97dbe47@AcuMS.aculab.com>
References: <20200723060908.50081-1-hch@lst.de>
 <20200723060908.50081-13-hch@lst.de> <20200727150310.GA1632472@zx2c4.com>
 <20200727150601.GA3447@lst.de>
 <CAHmME9ric=chLJayn7Erve7WBa+qCKn-+Gjri=zqydoY6623aA@mail.gmail.com>
 <20200727162357.GA8022@lst.de>
Mime-Version: 1.0
Content-Transfer-Encoding: 8BIT
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20200727162357.GA8022-jcswGhMUV9g@public.gmane.org>
Content-Language: en-US
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: 'Christoph Hellwig' <hch-jcswGhMUV9g@public.gmane.org>, "Jason A. Donenfeld" <Jason-OnJsPKxuuEcAvxtiuMwx3w@public.gmane.org>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Jakub Kicinski <kuba-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>, Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>, Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>, Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linux Crypto Mailing List <linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "bpf-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <bpf-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org" <coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>, "linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-hams-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-hams-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, bridge@list

From: Christoph Hellwig
> Sent: 27 July 2020 17:24
> 
> On Mon, Jul 27, 2020 at 06:16:32PM +0200, Jason A. Donenfeld wrote:
> > Maybe sockptr_advance should have some safety checks and sometimes
> > return -EFAULT? Or you should always use the implementation where
> > being a kernel address is an explicit bit of sockptr_t, rather than
> > being implicit?
> 
> I already have a patch to use access_ok to check the whole range in
> init_user_sockptr.

That doesn't make (much) difference to the code paths that ignore
the user-supplied length.
OTOH doing the user/kernel check on the base address (not an
incremented one) means that the correct copy function is always
selected.

Perhaps the functions should all be passed a 'const sockptr_t'.
The typedef could be made 'const' - requiring non-const items
explicitly use the union/struct itself.

	David

-
Registered Address Lakeside, Bramley Road, Mount Farm, Milton Keynes, MK1 1PT, UK
Registration No: 1397386 (Wales)

