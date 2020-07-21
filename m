From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 02/24] bpfilter: fix up a sparse annotation
Date: Tue, 21 Jul 2020 07:23:26 +0200
Message-ID: <20200721052326.GA10071@lst.de>
References: <20200720124737.118617-1-hch@lst.de> <20200720124737.118617-3-hch@lst.de> <20200721024016.2talwdt5hjqvirr6@ltop.local>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20200721024016.2talwdt5hjqvirr6@ltop.local>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Cc: Christoph Hellwig <hch@lst.de>, "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Eric Dumazet <edumazet@google.com>, linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, bpf@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-sctp@vger.kernel.org, linux-hams@vger.kernel.org, linux-bluetooth@vger.kernel.org, bridge@lists.linux-foundation.org, linux-can@vger.kernel.org, dccp@vger.kernel.org, linux-decnet-user@lists.sourceforge.net, linux-wpan@vger.kernel.org, linux-s390@vger.kernel.org, mptcp@lists.01.org, 

On Tue, Jul 21, 2020 at 04:40:16AM +0200, Luc Van Oostenryck wrote:
> >  	req.pid = current->pid;
> >  	req.cmd = optname;
> > -	req.addr = (long __force __user)optval;
> > +	req.addr = (__force long)optval;
> 
> For casts to integers, even '__force' is not needed (since integers
> can't be dereferenced, the concept of address-space is meaningless
> for them, so it's never useful to warn when it's dropped and
> '__force' is thus not needed).

That's what I thought. but if I remove it here I actually do get a
warning:

CHECK   net/bpfilter/bpfilter_kern.c
net/bpfilter/bpfilter_kern.c:52:21: warning: cast removes address space '__user' of expression

Using this recent sparse build:

hch@brick:~/work/linux$ sparse --version
v0.6.2-49-g707c5017
