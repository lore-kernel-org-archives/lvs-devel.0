From: Smart Weblications GmbH - Florian Wiessner 
	<f.wiessner@smart-weblications.de>
Subject: Re: 3.12.33 - BUG xfrm_selector_match+0x25/0x2f6
Date: Tue, 09 Dec 2014 11:23:25 +0100
Message-ID: <5486CD9D.4060107@smart-weblications.de>
References: <547F2462.6040405@smart-weblications.de> <20141204075627.GE6390@secunet.com> <alpine.LFD.2.11.1412042338370.4841@ja.home.ssi.bg> <5481173A.9060308@smart-weblications.de> <alpine.LFD.2.11.1412051126090.2522@ja.home.ssi.bg> <5481B944.2000002@smart-weblications.de> <alpine.LFD.2.11.1412072019410.1885@ja.home.ssi.bg> <54858948.2060007@smart-weblications.de> <alpine.LFD.2.11.1412082234350.2401@ja.home.ssi.bg>
Reply-To: f.wiessner@smart-weblications.de
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.11.1412082234350.2401@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Julian Anastasov <ja@ssi.bg>
Cc: Steffen Klassert <steffen.klassert@secunet.com>, netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, stable@vger.kernel.org, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org

Hi Julian,

Am 08.12.2014 21:40, schrieb Julian Anastasov:
>=20
> 	Hello,
>=20
> On Mon, 8 Dec 2014, Smart Weblications GmbH - Florian Wiessner wrote:
>=20
>> Am 07.12.2014 19:27, schrieb Julian Anastasov:>
>>>
>>> 	I'm attaching a patch that avoids rerouting in
>>> IPVS for LOCAL_IN. Please test it in your setup. My tests
>>> were with NAT on today's net tree. I checked that it
>>> compiles for 3.12.33. You can use the default snat_reroute=3D1.
>>>
>>
>> I'm sorry to tell you that your patch does not fix the problem. The =
BUG happens
>> as soon as the client sends PASV, the ftp server does not return "En=
tering
>> Passive Mode":
>=20
> 	Patch is to avoid the xfrm_selector_match crash,
> may be caused when using local client (mail?).
> For nf_ct_seqadj_set you have to use commit b25adce16064
> ("ipvs: correct usage/allocation of seqadj ext in ipvs").
> I'll send it to you privately...
>=20

I rebuild everything with the two provided patches and still get:

[  512.475449] BUG: unable to handle kernel NULL pointer dereference at
0000000000000014
[  512.481277] IP: [<ffffffffa013d470>] nf_ct_seqadj_set+0x60/0x90 [nf_=
conntrack]
[  512.481442] PGD 0
[  512.481572] Oops: 0000 [#1] SMP
[  512.481750] Modules linked in: ip_vs_rr netconsole xt_nat xt_multipo=
rt veth
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
coretemp ip_vs_ftp ip_vs nf_nat nf_conntrack psmouse serio_raw i2c_i801=
 lpc_ich
mfd_core evdev btrfs lzo_decompress lzo_compress
[  512.485323] CPU: 4 PID: 28142 Comm: vsftpd Not tainted 3.12.33 #5
[  512.485405] Hardware name: Supermicro X9SCI/X9SCA/X9SCI/X9SCA, BIOS =
1.1a
09/28/2011
[  512.485497] task: ffff880703f1c500 ti: ffff8805cab2e000 task.ti: fff=
f8805cab2e000
[  512.485594] RIP: 0010:[<ffffffffa013d470>]  [<ffffffffa013d470>]
nf_ct_seqadj_set+0x60/0x90 [nf_conntrack]
[  512.485751] RSP: 0018:ffff88083fd03988  EFLAGS: 00010206
[  512.485829] RAX: 000000000000000c RBX: ffff8805cb314b1c RCX: 0000000=
000000003
[  512.485916] RDX: 0000000000000026 RSI: 0000000000000003 RDI: ffff880=
5cb314b1c
[  512.486007] RBP: 00000000030a6079 R08: ffff88079d058c80 R09: ffff880=
83fd03998
[  512.486084] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000=
000000003
[  512.486162] R13: 0000000000000000 R14: 0000000000000003 R15: ffff880=
8170150bc
[  512.486240] FS:  00007f0497645700(0000) GS:ffff88083fd00000(0000)
knlGS:0000000000000000
[  512.486351] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  512.486431] CR2: 0000000000000014 CR3: 00000007457f4000 CR4: 0000000=
0000407e0
[  512.486512] Stack:
[  512.486583]  ffff88077b389460 0000000000000012 0000000000000014 ffff=
8805cb314b18
[  512.486886]  ffff880817015001 ffffffffa0152681 0000000000000000 ffff=
ffff00000045
[  512.487195]  ffff880800000048 0000001b00000003 ffff88083fd03a60 ffff=
88077b389460
[  512.487501] Call Trace:
[  512.487574]  <IRQ>
[  512.487634]  [<ffffffffa0152681>] ? __nf_nat_mangle_tcp_packet+0x109=
/0x120
[nf_nat]
[  512.487859]  [<ffffffffa017a49e>] ? ip_vs_ftp_out.part.8+0x2b2/0x338=
 [ip_vs_ftp]
[  512.487957]  [<ffffffffa0162884>] ? ip_vs_app_pkt_out+0x105/0x18b [i=
p_vs]
[  512.488038]  [<ffffffffa0166028>] ? tcp_snat_handler+0x6b/0x320 [ip_=
vs]
[  512.488123]  [<ffffffffa0158d3d>] ? ip_vs_conn_out_get_proto+0x1c/0x=
25 [ip_vs]
[  512.488222]  [<ffffffffa015b93c>] ? ip_vs_out+0x2a5/0x5f6 [ip_vs]
[  512.488325]  [<ffffffff8150f544>] ? ip_frag_mem+0x2a/0x2a
[  512.488405]  [<ffffffff81508e1f>] ? nf_iterate+0x42/0x80
[  512.488486]  [<ffffffff81508ec6>] ? nf_hook_slow+0x69/0xff
[  512.488565]  [<ffffffff8150f544>] ? ip_frag_mem+0x2a/0x2a
[  512.488645]  [<ffffffff8150f8ae>] ? ip_forward+0x22d/0x2cf
[  512.488729]  [<ffffffff814e57ce>] ? __netif_receive_skb_core+0x5f0/0=
x66c
[  512.488810]  [<ffffffff814e59df>] ? process_backlog+0x13e/0x13e
[  512.488893]  [<ffffffffa0458e09>] ? br_handle_frame_finish+0x382/0x3=
82 [bridge]
[  512.488987]  [<ffffffff814e5a2b>] ? netif_receive_skb+0x4c/0x7d
[  512.489068]  [<ffffffffa0458d95>] ? br_handle_frame_finish+0x30e/0x3=
82 [bridge]
[  512.489166]  [<ffffffffa0458fda>] ? br_handle_frame+0x1d1/0x217 [bri=
dge]
[  512.489247]  [<ffffffff814e567d>] ? __netif_receive_skb_core+0x49f/0=
x66c
[  512.489338]  [<ffffffff814e592b>] ? process_backlog+0x8a/0x13e
[  512.489415]  [<ffffffff814e5c31>] ? net_rx_action+0xa2/0x1c0
[  512.489493]  [<ffffffff81047e2e>] ? __do_softirq+0xf6/0x24f
[  512.489578]  [<ffffffff815ad7dc>] ? call_softirq+0x1c/0x30
[  512.489655]  <EOI>
[  512.489721]  [<ffffffff8100464d>] ? do_softirq+0x2c/0x5f
[  512.489920]  [<ffffffff81047ca1>] ? local_bh_enable+0x67/0x85
[  512.489996]  [<ffffffff81511689>] ? ip_finish_output+0x2c9/0x322
[  512.490076]  [<ffffffff8151240a>] ? ip_queue_xmit+0x2b7/0x2f0
[  512.490156]  [<ffffffff81524772>] ? tcp_transmit_skb+0x6ef/0x755
[  512.490235]  [<ffffffff815250e8>] ? tcp_write_xmit+0x886/0x9cb
[  512.490311]  [<ffffffff8152527a>] ? __tcp_push_pending_frames+0x24/0=
x7e
[  512.490392]  [<ffffffff8151a33c>] ? tcp_sendmsg+0xa4c/0xbfc
[  512.490466]  [<ffffffff814d3477>] ? sock_aio_write+0xe3/0xfd
[  512.490545]  [<ffffffff81122f4d>] ? do_sync_write+0x59/0x79
[  512.490623]  [<ffffffff811239e3>] ? vfs_write+0xc4/0x182
[  512.490703]  [<ffffffff81123daf>] ? SyS_write+0x45/0x7c
[  512.490781]  [<ffffffff815ac35b>] ? tracesys+0xdd/0xe2
[  512.490859] Code: 68 14 4d 01 c5 45 85 e4 74 46 f0 80 4f 78 40 48 8d=
 5f 04 48
89 df e8 00 e2 46 e1 31 c0 41 83 fe 02 0f 97 c0 48 6b c0 0c 4c 01 e8 <8=
b> 70 08
39 70 04 74 08 89 ea 0f ca 39 10 79 0d 89 70 04 44 01
[  512.494558] RIP  [<ffffffffa013d470>] nf_ct_seqadj_set+0x60/0x90 [nf=
_conntrack]
[  512.494714]  RSP <ffff88083fd03988>
[  512.494785] CR2: 0000000000000014
[  512.494871] ---[ end trace 8a6e753cba1ccec2 ]---




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
