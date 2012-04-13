From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [PATCH] netfilter: ipvs: Verify that IP_VS protocol has been registered
Date: Fri, 13 Apr 2012 10:03:41 +0200
Message-ID: <201204131003.43742.hans.schillstrom@ericsson.com>
References: <1333668273-8873-1-git-send-email-levinsasha928@gmail.com> <CA+1xoqcxggYxb_ha4VdQtCUW-iYeVbaB38mC_pwAzdCf=rS7mQ@mail.gmail.com> <20120413041150.GA26149@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20120413041150.GA26149@verge.net.au>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: Sasha Levin <levinsasha928@gmail.com>, Pablo Neira Ayuso <pablo@netfilter.org>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "ja@ssi.bg" <ja@ssi.bg>, "kaber@trash.net" <kaber@trash.net>, "davem@davemloft.net" <davem@davemloft.net>, "davej@redhat.com" <davej@redhat.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hello Simon and Sasha
Sorry for not helping been quite busy for a while

On Friday 13 April 2012 06:11:50 Simon Horman wrote:
> On Fri, Apr 13, 2012 at 02:54:13AM +0200, Sasha Levin wrote:
> > On Thu, Apr 12, 2012 at 1:46 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> > >> If you return here, I think you'll leave things in inconsistent state,
> > >> ie. the tcp protocol is registered. You have to unregister it before
> > >> leaving.
> > 
> > I thought that the cleanup callback is getting called for failed init
> > calls, if that's not the case then we can probably call it ourselves
> > if any of these failed.
> 
> Good point. In any case, I think that I have found a new problem.
> 
> With your proposed patch in place I see a panic in ftp helper registration
> in the case where protocol registration fails. I have not had any
> luck resolving this so far. Perhaps ipvs->net needs to be reset to NULL
> if initialisation fails and that can be checked when modules register
> themselves?
I think Pablo was touching the root cause,

There is a generic fault in the patch, you must take care of un_register of the protocol
i.e. my sugguestion is do like this:

#ifdef CONFIG_IP_VS_PROTO_TCP
	if (register_ip_vs_proto_netns(net, &ip_vs_protocol_tcp) < 0)
		goto unreg;
#endif
#ifdef CONFIG_IP_VS_PROTO_UDP
	if (register_ip_vs_proto_netns(net, &ip_vs_protocol_udp) < 0)
		goto unreg;
#endif
...

unreg:
	ip_vs_protocol_net_cleanup(net);
	return -ENOMEM;
}

and in register_ip_vs_proto_netns() kzalloc() could be changed to GFP_KERNEL 
since this will allways be called from process context


> 
> IPVS: Registered protocols (TCP, UDP, SCTP, AH, ESP)
> IPVS: Connection hash table configured (size=4096, memory=64Kbytes)
> IPVS: Each connection entry needs 264 bytes at least
> input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input1
> IPVS: [rr] scheduler registered.
> IPVS: [wrr] scheduler registered.
> IPVS: [lc] scheduler registered.
> IPVS: [wlc] scheduler registered.
> IPVS: [lblc] scheduler registered.
> IPVS: [lblcr] scheduler registered.
> IPVS: [dh] scheduler registered.
> IPVS: [sh] scheduler registered.
> IPVS: [sed] scheduler registered.
> IPVS: [nq] scheduler registered.
> general protection fault: 0000 [#1] SMP
> CPU 0
> Modules linked in:
> 
> Pid: 1, comm: swapper/0 Not tainted 3.3.0-03812-gf51f739 #219 Bochs Bochs
> RIP: 0010:[<ffffffff811e21ba>]  [<ffffffff811e21ba>] register_ip_vs_app+0x3a/0x70
> RSP: 0018:ffff880002039df0  EFLAGS: 00010246
> RAX: 002a002900280027 RBX: ffff8800020ce680 RCX: 0000000000000000
> RDX: 0000000000000000 RSI: ffff8800020ce680 RDI: ffffffff8162ab80
> RBP: ffff880002039e00 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000001 R12: ffff880003916800
> R13: 00000000fffffff4 R14: ffffffff816e5f00 R15: ffff880003916800
> FS:  0000000000000000(0000) GS:ffff880002600000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 00000000004697e0 CR3: 0000000001605000 CR4: 00000000000006b0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process swapper/0 (pid: 1, threadinfo ffff880002038000, task ffff8800020375a0)
> Stack:
>  ffff8800020ce680 0000000000000000 ffff880002039e50 ffffffff81675610
>  ffffffff81614060 00ffffff00000006 ffffffff8149dc9d ffffffff8162b8a0
>  0000000000000000 ffffffff81675699 0000000000000000 0000000000000000
> Call Trace:
>  [<ffffffff81675610>] __ip_vs_ftp_init+0x6b/0xf4
>  [<ffffffff81675699>] ? __ip_vs_ftp_init+0xf4/0xf4
>  [<ffffffff811a6011>] ops_init.constprop.11+0x91/0x110
>  [<ffffffff81675699>] ? __ip_vs_ftp_init+0xf4/0xf4
>  [<ffffffff811a60fc>] register_pernet_operations.isra.8+0x6c/0xc0
>  [<ffffffff811a61e0>] register_pernet_subsys+0x20/0x40
>  [<ffffffff81675593>] ? ip_vs_sed_init+0x12/0x12
>  [<ffffffff816756a9>] ip_vs_ftp_init+0x10/0x12
>  [<ffffffff810001ca>] do_one_initcall+0x3a/0x160
>  [<ffffffff81654bae>] kernel_init+0x9b/0x115
>  [<ffffffff81298bf4>] kernel_thread_helper+0x4/0x10
>  [<ffffffff81654b13>] ? start_kernel+0x31d/0x31d
>  [<ffffffff81298bf0>] ? gs_change+0xb/0xb
> Code: f8 48 89 f3 4c 8b a7 40 09 00 00 e8 e1 a6 ff ff 48 c7 c7 80 ab 62 81 e8 25 30 0b 00 49 8b 84 24 08 01 00 00 48 c7 c7 80 ab 62 81 <48> 89 58 08 48 89 03 49 8d 84 24 08 01 00 00 48 89 43 08 49 89
> RIP  [<ffffffff811e21ba>] register_ip_vs_app+0x3a/0x70
>  RSP <ffff880002039df0>
> ---[ end trace 3e5d9bede957f8b4 ]---
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
