From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL net] IPVS
Date: Tue, 10 Jul 2012 15:05:03 +0200
Message-ID: <20120710130503.GA21118@1984>
References: <1335488039-13471-1-git-send-email-horms@verge.net.au>
 <20120430092722.GA6866@1984>
 <20120710092002.GE12776@verge.net.au>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120710092002.GE12776@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Jesper Dangaard Brouer <brouer@redhat.com>

Hi Simon,

On Tue, Jul 10, 2012 at 06:20:03PM +0900, Simon Horman wrote:
> On Mon, Apr 30, 2012 at 11:27:22AM +0200, Pablo Neira Ayuso wrote:
> > On Fri, Apr 27, 2012 at 09:53:54AM +0900, Simon Horman wrote:
> > > Hi Pablo,
> > > 
> > > please consider the following 5 changes for 3.4, they are all bug fixes.
> > > I would also like these changes considered for stable.
> > 
> > Please, ping me again once these have hit Linus tree to ask for
> > -stable submission.
> 
> Sorry for letting this slip through the cracks.
> 
> Please consider the following commits which are in Linus's tree for stable.
> Or I can submit them directly if that is easier.
> 
> There are 7 patches listed below. The first 5 were the patches in this
> pull request. The last two were patches in a git pull request
> a few days earlier.

That's fine, I can make it, but you have to include what stable
releases this will be applied, eg. patch 1 to releases 3.4 and 3.2.

I think -stable maintainers will ask for that.

> commit 8537de8a7ab6681cc72fb0411ab1ba7fdba62dd0
> Author: Hans Schillstrom <hans.schillstrom@ericsson.com>
> Date:   Thu Apr 26 07:47:44 2012 +0200
> 
>     ipvs: kernel oops - do_ip_vs_get_ctl
>     
>     Change order of init so netns init is ready
>     when register ioctl and netlink.
>     
>     Ver2
>     	Whitespace fixes and __init added.
>     
>     Reported-by: "Ryan O'Hara" <rohara@redhat.com>
>     Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
>     Acked-by: Julian Anastasov <ja@ssi.bg>
>     Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
>     Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> commit 582b8e3eadaec77788c1aa188081a8d5059c42a6
> Author: Hans Schillstrom <hans.schillstrom@ericsson.com>
> Date:   Thu Apr 26 09:45:35 2012 +0200
> 
>     ipvs: take care of return value from protocol init_netns
>     
>     ip_vs_create_timeout_table() can return NULL
>     All functions protocol init_netns is affected of this patch.
>     
>     Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
>     Acked-by: Julian Anastasov <ja@ssi.bg>
>     Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> commit 4b984cd50bc1b6d492175cd77bfabb78e76ffa67
> Author: Hans Schillstrom <hans.schillstrom@ericsson.com>
> Date:   Thu Apr 26 09:45:34 2012 +0200
> 
>     ipvs: null check of net->ipvs in lblc(r) shedulers
>     
>     Avoid crash when registering shedulers after
>     the IPVS core initialization for netns fails. Do this by
>     checking for present core (net->ipvs).
>     
>     Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
>     Acked-by: Julian Anastasov <ja@ssi.bg>
>     Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> commit 39f618b4fd95ae243d940ec64c961009c74e3333
> Author: Julian Anastasov <ja@ssi.bg>
> Date:   Wed Apr 25 00:29:58 2012 +0300
> 
>     ipvs: reset ipvs pointer in netns
>     
>     	Make sure net->ipvs is reset on netns cleanup or failed
>     initialization. It is needed for IPVS applications to know that
>     IPVS core is not loaded in netns.
>     
>     Signed-off-by: Julian Anastasov <ja@ssi.bg>
>     Acked-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
>     Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> commit 8d08d71ce59438a6ef06be5db07966e0c144b74e
> Author: Julian Anastasov <ja@ssi.bg>
> Date:   Wed Apr 25 00:29:59 2012 +0300
> 
>     ipvs: add check in ftp for initialized core
>     
>     	Avoid crash when registering ip_vs_ftp after
>     the IPVS core initialization for netns fails. Do this by
>     checking for present core (net->ipvs).
>     
>     Signed-off-by: Julian Anastasov <ja@ssi.bg>
>     Acked-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
>     Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> commit 8f9b9a2fad47af27e14b037395e03cd8278d96d7
> Author: Julian Anastasov <ja@ssi.bg>
> Date:   Fri Apr 13 18:08:43 2012 +0300
> 
>     ipvs: fix crash in ip_vs_control_net_cleanup on unload
>     
>     	commit 14e405461e664b777e2a5636e10b2ebf36a686ec (2.6.39)
>     ("Add __ip_vs_control_{init,cleanup}_sysctl()")
>     introduced regression due to wrong __net_init for
>     __ip_vs_control_cleanup_sysctl. This leads to crash when
>     the ip_vs module is unloaded.
>     
>     	Fix it by changing __net_init to __net_exit for
>     the function that is already renamed to ip_vs_control_net_cleanup_sysctl.
>     
>     Signed-off-by: Julian Anastasov <ja@ssi.bg>
>     Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
>     Signed-off-by: Simon Horman <horms@verge.net.au>
>     Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> 
> commit 7118c07a844d367560ee91adb2071bde2fabcdbf
> Author: Sasha Levin <levinsasha928@gmail.com>
> Date:   Sat Apr 14 12:37:46 2012 -0400
> 
>     ipvs: Verify that IP_VS protocol has been registered
>     
>     The registration of a protocol might fail, there were no checks
>     and all registrations were assumed to be correct. This lead to
>     NULL ptr dereferences when apps tried registering.
>     
>     For example:
>     
>     [ 1293.226051] BUG: unable to handle kernel NULL pointer dereference at 0000000000000018
>     [ 1293.227038] IP: [<ffffffff822aacb0>] tcp_register_app+0x60/0xb0
>     [ 1293.227038] PGD 391de067 PUD 6c20b067 PMD 0
>     [ 1293.227038] Oops: 0000 [#1] PREEMPT SMP
>     [ 1293.227038] CPU 1
>     [ 1293.227038] Pid: 19609, comm: trinity Tainted: G        W    3.4.0-rc1-next-20120405-sasha-dirty #57
>     [ 1293.227038] RIP: 0010:[<ffffffff822aacb0>]  [<ffffffff822aacb0>] tcp_register_app+0x60/0xb0
>     [ 1293.227038] RSP: 0018:ffff880038c1dd18  EFLAGS: 00010286
>     [ 1293.227038] RAX: ffffffffffffffc0 RBX: 0000000000001500 RCX: 0000000000010000
>     [ 1293.227038] RDX: 0000000000000000 RSI: ffff88003a2d5888 RDI: 0000000000000282
>     [ 1293.227038] RBP: ffff880038c1dd48 R08: 0000000000000000 R09: 0000000000000000
>     [ 1293.227038] R10: 0000000000000000 R11: 0000000000000000 R12: ffff88003a2d5668
>     [ 1293.227038] R13: ffff88003a2d5988 R14: ffff8800696a8ff8 R15: 0000000000000000
>     [ 1293.227038] FS:  00007f01930d9700(0000) GS:ffff88007ce00000(0000) knlGS:0000000000000000
>     [ 1293.227038] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>     [ 1293.227038] CR2: 0000000000000018 CR3: 0000000065dfc000 CR4: 00000000000406e0
>     [ 1293.227038] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>     [ 1293.227038] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>     [ 1293.227038] Process trinity (pid: 19609, threadinfo ffff880038c1c000, task ffff88002dc73000)
>     [ 1293.227038] Stack:
>     [ 1293.227038]  ffff880038c1dd48 00000000fffffff4 ffff8800696aada0 ffff8800694f5580
>     [ 1293.227038]  ffffffff8369f1e0 0000000000001500 ffff880038c1dd98 ffffffff822a716b
>     [ 1293.227038]  0000000000000000 ffff8800696a8ff8 0000000000000015 ffff8800694f5580
>     [ 1293.227038] Call Trace:
>     [ 1293.227038]  [<ffffffff822a716b>] ip_vs_app_inc_new+0xdb/0x180
>     [ 1293.227038]  [<ffffffff822a7258>] register_ip_vs_app_inc+0x48/0x70
>     [ 1293.227038]  [<ffffffff822b2fea>] __ip_vs_ftp_init+0xba/0x140
>     [ 1293.227038]  [<ffffffff821c9060>] ops_init+0x80/0x90
>     [ 1293.227038]  [<ffffffff821c90cb>] setup_net+0x5b/0xe0
>     [ 1293.227038]  [<ffffffff821c9416>] copy_net_ns+0x76/0x100
>     [ 1293.227038]  [<ffffffff810dc92b>] create_new_namespaces+0xfb/0x190
>     [ 1293.227038]  [<ffffffff810dca21>] unshare_nsproxy_namespaces+0x61/0x80
>     [ 1293.227038]  [<ffffffff810afd1f>] sys_unshare+0xff/0x290
>     [ 1293.227038]  [<ffffffff8187622e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
>     [ 1293.227038]  [<ffffffff82665539>] system_call_fastpath+0x16/0x1b
>     [ 1293.227038] Code: 89 c7 e8 34 91 3b 00 89 de 66 c1 ee 04 31 de 83 e6 0f 48 83 c6 22 48 c1 e6 04 4a 8b 14 26 49 8d 34 34 48 8d 42 c0 48 39 d6 74 13 <66> 39 58 58 74 22 48 8b 48 40 48 8d 41 c0 48 39 ce 75 ed 49 8d
>     [ 1293.227038] RIP  [<ffffffff822aacb0>] tcp_register_app+0x60/0xb0
>     [ 1293.227038]  RSP <ffff880038c1dd18>
>     [ 1293.227038] CR2: 0000000000000018
>     [ 1293.379284] ---[ end trace 364ab40c7011a009 ]---
>     [ 1293.381182] Kernel panic - not syncing: Fatal exception in interrupt
>     
>     Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
>     Acked-by: Julian Anastasov <ja@ssi.bg>
>     Signed-off-by: Simon Horman <horms@verge.net.au>
>     Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> 
