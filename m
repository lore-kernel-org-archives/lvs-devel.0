From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 12/24] bpfilter: switch bpfilter_ip_set_sockopt to
 sockptr_t
Date: Tue, 21 Jul 2020 08:36:57 +0000
Message-ID: <f9493b4c514441b4b51bc7e4e75e8c40@AcuMS.aculab.com>
References: <20200720124737.118617-1-hch@lst.de>
 <20200720124737.118617-13-hch@lst.de>
Mime-Version: 1.0
Content-Transfer-Encoding: 8BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20200720124737.118617-13-hch@lst.de>
Content-Language: en-US
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: 'Christoph Hellwig' <hch@lst.de>, "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Eric Dumazet <edumazet@google.com>
Cc: "linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "bpf@vger.kernel.org" <bpf@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, "coreteam@netfilter.org" <coreteam@netfilter.org>, "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>, "linux-hams@vger.kernel.org" <linux-hams@vger.kernel.org>, "linux-bluetooth@vger.kernel.org" <linux-bluetooth@vger.kernel.org>, "bridge@lists.linux-foundation.org" <bridge@lists.linux-foundation.org>, "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>, "dccp@vger.kernel.org" <dccp@vger.kernel.org>, "linux-decnet-user@lists.sourceforge.net" <linux-decnet-user@lists.sourcefor>

From: Christoph Hellwig
> Sent: 20 July 2020 13:47
> 
> This is mostly to prepare for cleaning up the callers, as bpfilter by
> design can't handle kernel pointers.
                      ^^^ user ??

	David
