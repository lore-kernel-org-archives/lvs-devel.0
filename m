From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCHv2 0/2] IPVS: Add Generic Netlink configuration interface
Date: Fri, 25 Jul 2008 15:58:08 +1000
Message-ID: <20080725055806.GA5118@verge.net.au>
References: <1216645375-20410-1-git-send-email-juliusv@google.com> <20080722003403.GC9041@verge.net.au> <4886665E.5060209@google.com> <4887A4FE.8080706@google.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4887A4FE.8080706@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Vince Busam <vbusam@google.com>
Cc: Julius Volz <juliusv@google.com>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, davem@davemloft.net, tgraf@suug.ch

On Wed, Jul 23, 2008 at 02:39:10PM -0700, Vince Busam wrote:
> Vince Busam wrote:
>> Simon Horman wrote:
>>> I'm not an expert on netlink, but these patches are looking good to me.
>>> Is the user-space portion available somewhere?
>
> Newer versions are available at
> http://sixpak.org/vince/google/ipvsadm/

Great, thanks :-)

I have been playing with this a little today. I am able to configure
a virtual service and it does work. However clearing seems to be a bit
of a problem, as per the trace below.

I am using the following code:

linux-next-2.6 14b395e35d1afdd8019d11b92e28041fad591b71
+ [PATCH] IPVS: Move userspace definitions to include/linux/ip_vs.h
+ [PATCHv2 1/2] IPVS: Add genetlink interface definitions to ip_vs.h
+ [PATCHv2 2/2] IPVS: Add genetlink interface implementation

I am running the code on i386 qemu running on an i386 machine.

My ipvsadm is ipvsadm-1.25-nl-2 (statically linked).
My libnl is Debian's libnl1 1.1-2 (rebuilt to provide a static version).

# ipvsadm -A -t 10.4.0.132:80
# ipvsadm -C
# ipvsadm -A -t 10.4.0.132:80
BUG: unable to handle kernel paging request at 44e30116
IP: [<c01e8b34>] ctrl_dumpfamily+0xa4/0xbc
*pde = 00000000 
Oops: 0000 [#1] 

Pid: 33, comm: ipvsadm Not tainted (2.6.26-kexec-05253-g14b395e-dirty #23)
EIP: 0060:[<c01e8b34>] EFLAGS: 00000212 CPU: 0
EIP is at ctrl_dumpfamily+0xa4/0xbc
EAX: c6f8b560 EBX: c02ee14c ECX: c02ee178 EDX: 44e300c6
ESI: c02ee108 EDI: 00000000 EBP: 00000010 ESP: c746dc48
 DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
Process ipvsadm (pid: 33, ti=c746c000 task=c6f20a50 task.ti=c746c000)
Stack: 00000000 00000000 c6f8b560 c744e300 c744e260 c744e300 000000d0 c6faf000 
       c01e7073 00000020 0000000f ffffff97 c6f8b560 c744be00 c744e260 c6faf000 
       c6f8b560 00000000 c01e72c2 c6faf800 c0290ca0 c0290c60 c744e260 c01e83d2 
Call Trace:
 [<c01e7073>] netlink_dump+0x53/0x1bc
 [<c01e72c2>] netlink_dump_start+0xe6/0x118
 [<c01e83d2>] genl_rcv_msg+0x112/0x174
 [<c01e8a90>] ctrl_dumpfamily+0x0/0xbc
 [<c018cd2e>] copy_to_user+0x2a/0x38
 [<c01e82c0>] genl_rcv_msg+0x0/0x174
 [<c01e7450>] netlink_rcv_skb+0x38/0x7c
 [<c01e844d>] genl_rcv+0x19/0x24
 [<c01e6290>] netlink_unicast+0x168/0x1a4
 [<c01e6ad8>] netlink_sendmsg+0x1f8/0x260
 [<c01cf7a6>] sock_sendmsg+0xb2/0xd8
 [<c0121bf8>] autoremove_wake_function+0x0/0x30
 [<c016126e>] simple_lookup+0x2a/0x30
 [<c015064e>] real_lookup+0xa2/0xd4
 [<c018cd65>] copy_from_user+0x29/0x4c
 [<c018cd65>] copy_from_user+0x29/0x4c
 [<c01d6586>] verify_iovec+0x32/0x7c
 [<c01d0bcd>] sys_sendmsg+0x111/0x200
 [<c0133429>] buffered_rmqueue+0x115/0x1e0
 [<c0133643>] get_page_from_freelist+0x9f/0xf8
 [<c0133733>] __alloc_pages_internal+0x97/0x3dc
 [<c013c37f>] do_anonymous_page+0xa7/0xd0
 [<c013c95c>] handle_mm_fault+0x154/0x1a0
 [<c01d107e>] sys_socketcall+0x1a2/0x1ac
 [<c0103db2>] syscall_call+0x7/0xb
 =======================
Code: 48 08 8b 02 8b 50 2c 6a 01 ff 74 24 10 6a 02 89 d8 e8 39 f9 ff ff 83 c4 0c 85 c0 79 c2 8b 44 24 08 89 68 14 89 78 18 8b 54 24 0b <8b> 42 50 83 c4 10 5b 5e 5f 5d c3 90 c7 04 24 00 00 00 00 e9 68 
EIP: [<c01e8b34>] ctrl_dumpfamily+0xa4/0xbc SS:ESP 0068:c746dc48
---[ end trace fe319f25bee8d956 ]---
Segmentation fault
# 
# 
