From: 'Christoph Hellwig' <hch@lst.de>
Subject: Re: get rid of the address_space override in setsockopt
Date: Wed, 22 Jul 2020 10:07:24 +0200
Message-ID: <20200722080724.GB26864@lst.de>
References: <20200720124737.118617-1-hch@lst.de> <ae6a743aaea3406596dbc89e332b6b3e@AcuMS.aculab.com>
Mime-Version: 1.0
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <ae6a743aaea3406596dbc89e332b6b3e@AcuMS.aculab.com>
Sender: linux-can-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight@ACULAB.COM>
Cc: 'Christoph Hellwig' <hch@lst.de>, "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Eric Dumazet <edumazet@google.com>, "linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "bpf@vger.kernel.org" <bpf@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, "coreteam@netfilter.org" <coreteam@netfilter.org>, "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>, "linux-hams@vger.kernel.org" <linux-hams@vger.kernel.org>

On Tue, Jul 21, 2020 at 10:26:58AM +0000, David Laight wrote:
> From: Christoph Hellwig
> > Sent: 20 July 2020 13:47
> > 
> > setsockopt is the last place in architecture-independ code that still
> > uses set_fs to force the uaccess routines to operate on kernel pointers.
> > 
> > This series adds a new sockptr_t type that can contained either a kernel
> > or user pointer, and which has accessors that do the right thing, and
> > then uses it for setsockopt, starting by refactoring some low-level
> > helpers and moving them over to it before finally doing the main
> > setsockopt method.
> 
> Another 'gotcha' ...
> 
> On an least some architectures (possibly only m68k) IIRC all structures
> are actually passed by reference.
> (This used to be true for sparc - but it may have changed in the
> last 30 years.)

Tough luck for ABIs wit suboptimal calling conventions.  At least we can
do the right thing for those that do not have the problem.
