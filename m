From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: Slab corruption
Date: Tue, 12 Oct 2010 13:12:04 +0200
Message-ID: <201010121312.04745.hans.schillstrom@ericsson.com>
References: <20100926133313.GA30560@verge.net.au> <201010111058.28651.hans.schillstrom@ericsson.com> <alpine.LFD.2.00.1010112329580.1660@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1010112329580.1660@ja.ssi.bg>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>

Hello Julian,

On Monday 11 October 2010 22:36:47 Julian Anastasov wrote:
> 
>  	Hello,
> 
> On Mon, 11 Oct 2010, Hans Schillstrom wrote:
> 
> >>  	There is one atomic_dec after free but I'm not sure
> >> if it matches the dump below. If in doubt just add
> >> svc = NULL in ip_vs_genl_set_cmd after the call to
> >> ip_vs_del_service.
> >
> > added  svc = NULL,
> > but it did not make any difference :-(
> 
>  	Do you see this message in debugs? Once or twice?
> And with usecnt > 0?:
> 
> IP_VS_DBG_BUF(3, "Removing service %u/%s:%u usecnt=%d\n",
> 
>  	Also, do you have traffic or any connections
> while removing the service? What is the result when
> there is no traffic?
> 
> >>> ex.
> >>> # ipvsadm -D -f 21 -6
> >>> Slab corruption: size-512 start=ffff880001760488, len=512
> >>> Redzone: 0x9f911029d74e35b/0x9f911029d74e35b.
> >>> Last user: [<ffffffffa004aa3a>](__ip_vs_del_service+0xfa/0x108 [ip_vs])
> >>> 020: 6b 6b 6b 6b 6a 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> 
>  	Is this offset 0x24? Can you determine which
> field of struct ip_vs_service is on offset 0x24? It can
> be usecnt if platform is 64-bit.
> 

I am sorry, I made a mistake  
I verified that the patch was in my nf-next-2.6 clone
but I was running Dave Millers net-next-2.6...

I will switch to nf-next-2.6 and run my tests again
(with the patch included)
Anyway you was right, usecnt is at offset 0x24 on my 64 bit machine.

I will post the results today or to morrow.

> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
> 

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
