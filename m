From: 'Christoph Hellwig' <hch@lst.de>
Subject: Re: [PATCH 13/26] bpfilter: switch bpfilter_ip_set_sockopt to
 sockptr_t
Date: Thu, 23 Jul 2020 13:44:58 +0200
Message-ID: <20200723114458.GA31363@lst.de>
References: <20200723060908.50081-1-hch@lst.de> <20200723060908.50081-14-hch@lst.de> <621e193e4af74d8198ed87d6a9ce8260@AcuMS.aculab.com>
Mime-Version: 1.0
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <621e193e4af74d8198ed87d6a9ce8260@AcuMS.aculab.com>
Sender: linux-crypto-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight@ACULAB.COM>
Cc: 'Christoph Hellwig' <hch@lst.de>, "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Eric Dumazet <edumazet@google.com>, "linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "bpf@vger.kernel.org" <bpf@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, "coreteam@netfilter.org" <coreteam@netfilter.org>, "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>, "linux-hams@vger.kernel.org" <linux-hams@vger.kernel.org>

On Thu, Jul 23, 2020 at 11:16:16AM +0000, David Laight wrote:
> From: Christoph Hellwig
> > Sent: 23 July 2020 07:09
> > 
> > This is mostly to prepare for cleaning up the callers, as bpfilter by
> > design can't handle kernel pointers.
> 
> You've failed to fix the sense of the above...

The sense still is correct.
