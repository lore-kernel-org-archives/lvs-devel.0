From: Smart Weblications GmbH - Florian Wiessner 
	<f.wiessner@smart-weblications.de>
Subject: Re: 3.12.33 - BUG xfrm_selector_match+0x25/0x2f6
Date: Mon, 08 Dec 2014 12:19:36 +0100
Message-ID: <54858948.2060007@smart-weblications.de>
References: <547F2462.6040405@smart-weblications.de> <20141204075627.GE6390@secunet.com> <alpine.LFD.2.11.1412042338370.4841@ja.home.ssi.bg> <5481173A.9060308@smart-weblications.de> <alpine.LFD.2.11.1412051126090.2522@ja.home.ssi.bg> <5481B944.2000002@smart-weblications.de> <alpine.LFD.2.11.1412072019410.1885@ja.home.ssi.bg>
Reply-To: f.wiessner@smart-weblications.de
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.11.1412072019410.1885@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Julian Anastasov <ja@ssi.bg>
Cc: Steffen Klassert <steffen.klassert@secunet.com>, netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, stable@vger.kernel.org, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org

Hi Julian,

Am 07.12.2014 19:27, schrieb Julian Anastasov:>
> 	Hello,
>
> On Fri, 5 Dec 2014, Smart Weblications GmbH - Florian Wiessner wrote:
>
>> thank you for the fast responses! I would like to test any patch for=
 3.12.
>
> 	I'm attaching a patch that avoids rerouting in
> IPVS for LOCAL_IN. Please test it in your setup. My tests
> were with NAT on today's net tree. I checked that it
> compiles for 3.12.33. You can use the default snat_reroute=3D1.
>

I'm sorry to tell you that your patch does not fix the problem. The BUG=
 happens
as soon as the client sends PASV, the ftp server does not return "Enter=
ing
Passive Mode":

[   91.862502] BUG: unable to handle kernel NULL pointer dereference at
0000000000000014
[   91.862735] IP: [<ffffffffa013a470>] nf_ct_seqadj_set+0x60/0x90 [nf_=
conntrack]
[   91.862889] PGD 0
[   91.863026] Oops: 0000 [#1] SMP
[   91.863235] Modules linked in: netconsole xt_nat xt_multiport ip_vs_=
rr veth
iptable_mangle xt_mark nf_conntrack_netlink nfnetlink ipt_MASQUERADE ip=
table_nat
nf_nat_ipv4 nf_conntrack_ipv4 nf_defrag_ipv4 ipt_REJECT xt_tcpudp iptab=
le_filter
ip_tables cpufreq_ondemand cpufreq_powersave cpufreq_conservative
cpufreq_userspace ocfs2_stack_o2cb ocfs2_dlm bridge stp llc bonding fus=
e
nf_conntrack_ftp 8021q openvswitch gre vxlan xt_conntrack x_tables ocfs=
2_dlmfs
dlm sctp ocfs2 ocfs2_nodemanager ocfs2_stackglue configfs rbd kvm_intel=
 kvm
coretemp ip_vs_ftp ip_vs nf_nat nf_conntrack i2c_i801 psmouse serio_raw=
 lpc_ich
mfd_core evdev btrfs lzo_decompress lzo_compress
[   91.866846] CPU: 1 PID: 18895 Comm: vsftpd Not tainted 3.12.33 #5
[   91.866927] Hardware name: Supermicro X9SCI/X9SCA/X9SCI/X9SCA, BIOS =
1.1a
09/28/2011
[   91.867023] task: ffff8807b9360540 ti: ffff8807afe90000 task.ti: fff=
f8807afe90000
[   91.867116] RIP: 0010:[<ffffffffa013a470>]  [<ffffffffa013a470>]
nf_ct_seqadj_set+0x60/0x90 [nf_conntrack]
[   91.867268] RSP: 0018:ffff88083fc43988  EFLAGS: 00010206
[   91.867346] RAX: 000000000000000c RBX: ffff88079aeb006c RCX: 0000000=
000000003
[   91.867428] RDX: 000000000000002a RSI: 0000000000000003 RDI: ffff880=
79aeb006c
[   91.867509] RBP: 00000000ce63f6dd R08: ffff8807b2eed780 R09: ffff880=
83fc43998
[   91.867598] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000=
000000003
[   91.867679] R13: 0000000000000000 R14: 0000000000000003 R15: ffff880=
815d948bc
[   91.867761] FS:  00007f1a8aad5700(0000) GS:ffff88083fc40000(0000)
knlGS:0000000000000000
[   91.867855] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   91.867926] CR2: 0000000000000014 CR3: 00000007a386a000 CR4: 0000000=
0000407e0
[   91.868008] Stack:
[   91.868073]  ffff88081690d220 0000000000000012 0000000000000014 ffff=
88079aeb0068
[   91.868383]  ffff880815d94801 ffffffffa014f681 0000000000000000 ffff=
ffff00000045
[   91.868694]  ffff880800000048 0000001b00000003 ffff88083fc43a60 ffff=
88081690d220
[   91.869003] Call Trace:
[   91.869077]  <IRQ>
[   91.869136]  [<ffffffffa014f681>] ? __nf_nat_mangle_tcp_packet+0x109=
/0x120
[nf_nat]
[   91.869356]  [<ffffffffa017749e>] ? ip_vs_ftp_out.part.8+0x2b2/0x338=
 [ip_vs_ftp]
[   91.869460]  [<ffffffffa015f884>] ? ip_vs_app_pkt_out+0x105/0x18b [i=
p_vs]
[   91.869539]  [<ffffffffa0163028>] ? tcp_snat_handler+0x6b/0x320 [ip_=
vs]
[   91.869622]  [<ffffffffa0155d3d>] ? ip_vs_conn_out_get_proto+0x1c/0x=
25 [ip_vs]
[   91.869736]  [<ffffffffa015893c>] ? ip_vs_out+0x2a5/0x5f6 [ip_vs]
[   91.869826]  [<ffffffff8150f544>] ? ip_frag_mem+0x2a/0x2a
[   91.869906]  [<ffffffff81508e1f>] ? nf_iterate+0x42/0x80
[   91.869996]  [<ffffffff81508ec6>] ? nf_hook_slow+0x69/0xff
[   91.870073]  [<ffffffff8150f544>] ? ip_frag_mem+0x2a/0x2a
[   91.870153]  [<ffffffff8150f8ae>] ? ip_forward+0x22d/0x2cf
[   91.870230]  [<ffffffff814e57ce>] ? __netif_receive_skb_core+0x5f0/0=
x66c
[   91.870311]  [<ffffffff814e59df>] ? process_backlog+0x13e/0x13e
[   91.870389]  [<ffffffffa0455e09>] ? br_handle_frame_finish+0x382/0x3=
82 [bridge]
[   91.870482]  [<ffffffff814e5a2b>] ? netif_receive_skb+0x4c/0x7d
[   91.870561]  [<ffffffffa0455d95>] ? br_handle_frame_finish+0x30e/0x3=
82 [bridge]
[   91.870652]  [<ffffffffa0455fda>] ? br_handle_frame+0x1d1/0x217 [bri=
dge]
[   91.870733]  [<ffffffff814e567d>] ? __netif_receive_skb_core+0x49f/0=
x66c
[   91.870817]  [<ffffffff8104daa3>] ? call_timer_fn+0x4b/0xf6
[   91.870893]  [<ffffffff814e592b>] ? process_backlog+0x8a/0x13e
[   91.870972]  [<ffffffff814e5c31>] ? net_rx_action+0xa2/0x1c0
[   91.871051]  [<ffffffff81047e2e>] ? __do_softirq+0xf6/0x24f
[   91.871132]  [<ffffffff815ad7dc>] ? call_softirq+0x1c/0x30
[   91.871203]  <EOI>
[   91.871260]  [<ffffffff8100464d>] ? do_softirq+0x2c/0x5f
[   91.871470]  [<ffffffff81047ca1>] ? local_bh_enable+0x67/0x85
[   91.871545]  [<ffffffff81511689>] ? ip_finish_output+0x2c9/0x322
[   91.871628]  [<ffffffff8151240a>] ? ip_queue_xmit+0x2b7/0x2f0
[   91.871714]  [<ffffffff81524772>] ? tcp_transmit_skb+0x6ef/0x755
[   91.871792]  [<ffffffff815250e8>] ? tcp_write_xmit+0x886/0x9cb
[   91.871872]  [<ffffffff8152527a>] ? __tcp_push_pending_frames+0x24/0=
x7e
[   91.871951]  [<ffffffff8151a33c>] ? tcp_sendmsg+0xa4c/0xbfc
[   91.872036]  [<ffffffff814d3477>] ? sock_aio_write+0xe3/0xfd
[   91.872129]  [<ffffffff81122f4d>] ? do_sync_write+0x59/0x79
[   91.872215]  [<ffffffff811239e3>] ? vfs_write+0xc4/0x182
[   91.872298]  [<ffffffff81123daf>] ? SyS_write+0x45/0x7c
[   91.872382]  [<ffffffff815ac35b>] ? tracesys+0xdd/0xe2
[   91.872461] Code: 68 14 4d 01 c5 45 85 e4 74 46 f0 80 4f 78 40 48 8d=
 5f 04 48
89 df e8 00 12 47 e1 31 c0 41 83 fe 02 0f 97 c0 48 6b c0 0c 4c 01 e8 <8=
b> 70 08
39 70 04 74 08 89 ea 0f ca 39 10 79 0d 89 70 04 44 01
[   91.876166] RIP  [<ffffffffa013a470>] nf_ct_seqadj_set+0x60/0x90 [nf=
_conntrack]
[   91.876327]  RSP <ffff88083fc43988>
[   91.876400] CR2: 0000000000000014
[   91.876497] ---[ end trace 2c6d9f405db2170c ]---
[   91.876578] Kernel panic - not syncing: Fatal exception in interrupt
[   91.876666] Rebooting in 10 seconds..
[  101.935360] ACPI MEMORY or I/O RESET_REG.



node01:/ocfs2/usr/src/linux-3.12.33/scripts# ./decodecode
</tmp/node01-kernel-ipvs.log
[ 91.872461] Code: 68 14 4d 01 c5 45 85 e4 74 46 f0 80 4f 78 40 48 8d 5=
f 04 48
89 df e8 00 12 47 e1 31 c0 41 83 fe 02 0f 97 c0 48 6b c0 0c 4c 01 e8 <8=
b> 70 08
39 70 04 74 08 89 ea 0f ca 39 10 79 0d 89 70 04 44 01
All code
=3D=3D=3D=3D=3D=3D=3D=3D
   0:   68 14 4d 01 c5          pushq  $0xffffffffc5014d14
   5:   45 85 e4                test   %r12d,%r12d
   8:   74 46                   je     0x50
   a:   f0 80 4f 78 40          lock orb $0x40,0x78(%rdi)
   f:   48 8d 5f 04             lea    0x4(%rdi),%rbx
  13:   48 89 df                mov    %rbx,%rdi
  16:   e8 00 12 47 e1          callq  0xffffffffe147121b
  1b:   31 c0                   xor    %eax,%eax
  1d:   41 83 fe 02             cmp    $0x2,%r14d
  21:   0f 97 c0                seta   %al
  24:   48 6b c0 0c             imul   $0xc,%rax,%rax
  28:   4c 01 e8                add    %r13,%rax
  2b:*  8b 70 08                mov    0x8(%rax),%esi           <-- tra=
pping
instruction
  2e:   39 70 04                cmp    %esi,0x4(%rax)
  31:   74 08                   je     0x3b
  33:   89 ea                   mov    %ebp,%edx
  35:   0f ca                   bswap  %edx
  37:   39 10                   cmp    %edx,(%rax)
  39:   79 0d                   jns    0x48
  3b:   89 70 04                mov    %esi,0x4(%rax)
  3e:   44                      rex.R
  3f:   01                      .byte 0x1

Code starting with the faulting instruction
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
   0:   8b 70 08                mov    0x8(%rax),%esi
   3:   39 70 04                cmp    %esi,0x4(%rax)
   6:   74 08                   je     0x10
   8:   89 ea                   mov    %ebp,%edx
   a:   0f ca                   bswap  %edx
   c:   39 10                   cmp    %edx,(%rax)
   e:   79 0d                   jns    0x1d
  10:   89 70 04                mov    %esi,0x4(%rax)
  13:   44                      rex.R
  14:   01                      .byte 0x1



--=20

Mit freundlichen Gr=FC=DFen,

=46lorian Wiessner

Smart Weblications GmbH
Martinsberger Str. 1
D-95119 Naila

fon.: +49 9282 9638 200
fax.: +49 9282 9638 205
24/7: +49 900 144 000 00 - 0,99 EUR/Min*
http://www.smart-weblications.de

--
Sitz der Gesellschaft: Naila
Gesch=E4ftsf=FChrer: Florian Wiessner
HRB-Nr.: HRB 3840 Amtsgericht Hof
*aus dem dt. Festnetz, ggf. abweichende Preise aus dem Mobilfunknetz
