From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCHv3 0/2] IPVS: Add Generic Netlink configuration interface
Date: Fri, 8 Aug 2008 12:26:09 +1000
Message-ID: <20080808022607.GB6094@verge.net.au>
References: <1218120219-1117-1-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1218120219-1117-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: julius.volz@gmail.com, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, davem@davemloft.net, tgraf@suug.ch, vbusam@google.com

On Thu, Aug 07, 2008 at 04:43:37PM +0200, Julius Volz wrote:
> This is the third iteration of the IPVS Netlink interface, this time
> with only a small fix for a typo found by Thomas Graf. If there are no
> further major issues, can this be applied?
> 
> The two patches add a Generic Netlink interface to IPVS while keeping
> the old get/setsockopt interface for userspace backwards compatibility.
> The motivation for this is to have a more extensible interface for
> future changes, such as the planned IPv6 support.
> 
> An ipvsadm that already uses the new interface is available here:
> 
> http://sixpak.org/vince/google/ipvsadm/
> (by Vince Busam)
> 
> Old ipvsadms continue to work with this change.

Hi Julius,

these patches seem fine to me, however I am still seeing an oops
when using the new ipvsadm. Are we sure that this bug is in generic
code?

# ipvsadm -A -t 10.4.0.132:80
# ipvsadm -C
BUG: unable to handle kernel NULL pointer dereference at 00000028
IP: [<c021f034>] ip_vs_genl_set_cmd+0x254/0x494
*pde = 00000000 
Oops: 0000 [#1] 

Pid: 33, comm: ipvsadm Not tainted (2.6.27-rc2-kexec-11901-ge6fce5b-dirty #13)
EIP: 0060:[<c021f034>] EFLAGS: 00000206 CPU: 0
EIP is at ip_vs_genl_set_cmd+0x254/0x494
EAX: 00000014 EBX: 00000000 ECX: c7401300 EDX: c02e3018
ESI: 00000000 EDI: 00000011 EBP: c746dce4 ESP: c746dc20
 DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
Process ipvsadm (pid: 33, ti=c746c000 task=c6f22700 task.ti=c746c000)
Stack: 00000021 c0289340 c0289364 c0289374 c6faf088 00001102 c6faf0b4 c6faf058 
       00000003 c0289340 00000001 00000000 c02e0968 c01e948e 00000002 c6feb960 
       00000001 c6f84160 c6feb960 00000010 00000000 00000246 c01e4c57 00000246 
Call Trace:
 [<c01e948e>] ctrl_dumpfamily+0x86/0xd4
 [<c01e4c57>] sk_filter+0x67/0x7c
 [<c01e693d>] netlink_dump+0x15d/0x1a4
 [<c01e9858>] genl_rcv_msg+0x1dc/0x204
 [<c01e967c>] genl_rcv_msg+0x0/0x204
 [<c01e89d2>] netlink_rcv_skb+0x72/0x80
 [<c01e9671>] genl_rcv+0x19/0x24
 [<c01e84d2>] netlink_unicast+0x232/0x284
 [<c01e86dd>] netlink_sendmsg+0x1b9/0x288
 [<c01d0d3b>] sock_sendmsg+0xb7/0xe0
 [<c0120adc>] autoremove_wake_function+0x0/0x30
 [<c0120adc>] autoremove_wake_function+0x0/0x30
 [<c013a383>] __do_fault+0x15b/0x340
 [<c01d7832>] verify_iovec+0x2a/0x88
 [<c01d0e9f>] sys_sendmsg+0x13b/0x230
 [<c01d184a>] sys_recvmsg+0x1b6/0x240
 [<c01d1665>] move_addr_to_user+0x45/0x74
 [<c01d1b50>] sys_getsockname+0x94/0xa0
 [<c01d2a09>] release_sock+0x9/0x70
 [<c01d3bca>] sock_setsockopt+0x106/0x638
 [<c01d0a41>] sock_attach_fd+0x65/0xa0
 [<c01d1e88>] sys_socketcall+0x80/0x1d8
 [<c0103d42>] syscall_call+0x7/0xb
 =======================
Code: 8b 40 04 89 44 24 1c 8b 47 18 85 c0 74 07 8b 40 04 89 44 24 20 8d 44 24 18 e8 09 ca ff ff 89 c3 8b 84 24 88 00 00 00 85 c0 74 03 <ff> 48 14 b8 f0 90 28 c0 e8 e3 a5 00 00 89 d8 81 c4 8c 00 00 00 
EIP: [<c021f034>] ip_vs_genl_set_cmd+0x254/0x494 SS:ESP 0068:c746dc20
---[ end trace d371c2e324a230e1 ]---
Segmentation fault
