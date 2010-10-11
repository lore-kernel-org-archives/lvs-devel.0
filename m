From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: Slab corruption
Date: Mon, 11 Oct 2010 10:58:28 +0200
Message-ID: <201010111058.28651.hans.schillstrom@ericsson.com>
References: <20100926133313.GA30560@verge.net.au> <201010070857.21822.hans.schillstrom@ericsson.com> <alpine.LFD.2.00.1010091416260.2735@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1010091416260.2735@ja.ssi.bg>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>

Hello,

On Saturday 09 October 2010 13:23:29 Julian Anastasov wrote:
> 
>  	Hello,
> 
> On Thu, 7 Oct 2010, Hans Schillstrom wrote:
> 
> > Hi
> > Have you seen Slab corruption before ?
> > I got it when deleting a service when there is real-servers left
> > It's not related to IPv6 or fwmarks any "-D" causes it if there is rs attached for that service
> > (and it's not bad RAM).
> 
>  	Do you have this patch which is already in nf-next:

Yes

> http://archive.linuxvirtualserver.org/html/lvs-devel/2010-09/threads.html#00039
> 
> static inline void ip_vs_service_put(struct ip_vs_service *svc)
> {
>          atomic_dec(&svc->usecnt);
> }
> 
>  	There is one atomic_dec after free but I'm not sure
> if it matches the dump below. If in doubt just add
> svc = NULL in ip_vs_genl_set_cmd after the call to
> ip_vs_del_service.

added  svc = NULL, 
but it did not make any difference :-(
 
> 
> > ex.
> > # ipvsadm -D -f 21 -6
> > Slab corruption: size-512 start=ffff880001760488, len=512
> > Redzone: 0x9f911029d74e35b/0x9f911029d74e35b.
> > Last user: [<ffffffffa004aa3a>](__ip_vs_del_service+0xfa/0x108 [ip_vs])
> > 020: 6b 6b 6b 6b 6a 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> > Single bit error detected. Probably bad RAM.
> > Run memtest86+ or a similar memory test tool.
> > Prev obj: start=ffff880001760270, len=512
> > Redzone: 0x9f911029d74e35b/0x9f911029d74e35b.
> > Last user: [<ffffffff812b7a48>](skb_release_data+0xc1/0xc6)
> > 000: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> > 010: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> > Next obj: start=ffff8800017606a0, len=512
> > Redzone: 0xd84156c5635688c0/0xd84156c5635688c0.
> > Last user: [<ffffffff812b3487>](sock_wmalloc+0x34/0x75)
> > 000: 5a 5a 5a 5a 5a 5a 5a 5a 00 00 33 33 00 00 00 05
> > 010: 00 00 02 01 01 01 86 dd 60 00 00 00 00 30 59 01
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
> 

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
