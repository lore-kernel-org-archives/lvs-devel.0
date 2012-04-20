From: "Ryan O'Hara" <rohara@redhat.com>
Subject: kernel oops - do_ip_vs_get_ctl
Date: Fri, 20 Apr 2012 00:03:27 -0500
Message-ID: <4F90EE1F.9010904@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000409080208020808000005"
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: lvs-devel@vger.kernel.org

This is a multi-part message in MIME format.
--------------000409080208020808000005
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


I frequently get a kernel oops in do_ip_vs_get_ctl when starting 
keepalived on a 3.3.0 kernel. I'm attaching the trace from 
/var/log/messages. Has anyone encountered this problem and if so is 
there a patch available? Much appreciated.

Ryan


--------------000409080208020808000005
Content-Type: text/plain;
 name="oops.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="oops.txt"

Mar 25 22:04:32 rocket-01 kernel: [  232.003309] nf_conntrack version 0.5.0 (7969 buckets, 31876 max)
Mar 25 22:04:32 rocket-01 kernel: [  232.015724] IPVS: Registered protocols (TCP, UDP, SCTP, AH, ESP)
Mar 25 22:04:32 rocket-01 kernel: [  232.019222] BUG: unable to handle kernel NULL pointer dereference at 00000000000005f8
Mar 25 22:04:32 rocket-01 kernel: [  232.020016] IP: [<ffffffffa00bf6b9>] do_ip_vs_get_ctl+0x5d9/0x960 [ip_vs]
Mar 25 22:04:32 rocket-01 kernel: [  232.020016] PGD 3b98e067 PUD 3b999067 PMD 0 
Mar 25 22:04:32 rocket-01 kernel: [  232.020016] Oops: 0000 [#1] SMP 
Mar 25 22:04:32 rocket-01 kernel: [  232.020016] CPU 0 
Mar 25 22:04:32 rocket-01 kernel: [  232.020016] Modules linked in: ip_vs(+) nf_conntrack libcrc32c lockd i2c_piix4 joydev i2c_core virtio_net virtio_balloon microcode sunrpc virtio_blk [last unloaded: scsi_wait_scan]
Mar 25 22:04:32 rocket-01 kernel: [  232.020016] 
Mar 25 22:04:32 rocket-01 kernel: [  232.020016] Pid: 868, comm: keepalived Not tainted 3.3.0-4.fc16.x86_64 #1 Red Hat KVM
Mar 25 22:04:32 rocket-01 kernel: [  232.020016] RIP: 0010:[<ffffffffa00bf6b9>]  [<ffffffffa00bf6b9>] do_ip_vs_get_ctl+0x5d9/0x960 [ip_vs]
Mar 25 22:04:32 rocket-01 kernel: [  232.020016] RSP: 0018:ffff88003b9f3ca8  EFLAGS: 00010293
Mar 25 22:04:32 rocket-01 kernel: [  232.020016] RAX: 0000000000001000 RBX: 0000000000000481 RCX: 0000000000000001
Mar 25 22:04:32 rocket-01 kernel: [  232.020016] RDX: ffff88003b9f3fd8 RSI: 000000000062ba20 RDI: ffffffffa00d10c0
Mar 25 22:04:32 rocket-01 kernel: [  232.020016] RBP: ffff88003b9f3e48 R08: 0000000000000000 R09: 0000000000000000
Mar 25 22:04:32 rocket-01 kernel: [  232.020016] R10: 0000000000000074 R11: 0000000000001000 R12: 0000000000000000
Mar 25 22:04:32 rocket-01 kernel: [  232.020016] R13: ffffffff81f72240 R14: 00000000fffffe00 R15: 000000000062ba14
Mar 25 22:04:32 rocket-01 kernel: [  232.020016] FS:  00007f53e38277c0(0000) GS:ffff88003fc00000(0000) knlGS:0000000000000000
Mar 25 22:04:32 rocket-01 kernel: [  232.020016] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Mar 25 22:04:32 rocket-01 kernel: [  232.020016] CR2: 00000000000005f8 CR3: 000000003b99c000 CR4: 00000000000006f0
Mar 25 22:04:32 rocket-01 kernel: [  232.020016] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Mar 25 22:04:32 rocket-01 kernel: [  232.020016] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Mar 25 22:04:32 rocket-01 kernel: [  232.020016] Process keepalived (pid: 868, threadinfo ffff88003b9f2000, task ffff88003b924590)
Mar 25 22:04:32 rocket-01 kernel: [  232.020016] Stack:
Mar 25 22:04:32 rocket-01 kernel: [  232.020016]  ffff88000000000c ffffffff00000001 ffff88003b9f3ed4 ffffffff814d3173
Mar 25 22:04:32 rocket-01 kernel: [  232.020016]  0000100000010201 ffff88003c826700 0000000000000481 00007fff5552827c
Mar 25 22:04:32 rocket-01 kernel: [  232.020016]  ffff88003b9f3ea8 ffffffff81522b8d ffff88003b9f3b78 000000003b9f3f18
Mar 25 22:04:32 rocket-01 kernel: [  232.020016] Call Trace:
Mar 25 22:04:32 rocket-01 kernel: [  232.020016]  [<ffffffff814d3173>] ? release_sock+0xe3/0x110
Mar 25 22:04:32 rocket-01 kernel: [  232.020016]  [<ffffffff81522b8d>] ? do_ip_getsockopt.part.1+0x7d/0x650
Mar 25 22:04:32 rocket-01 kernel: [  232.020016]  [<ffffffff8114671d>] ? handle_pte_fault+0x2ad/0xad0
Mar 25 22:04:32 rocket-01 kernel: [  232.020016]  [<ffffffff814ced7b>] ? move_addr_to_user+0xbb/0xd0
Mar 25 22:04:32 rocket-01 kernel: [  232.020016]  [<ffffffff8116c22f>] ? kmem_cache_free+0x2f/0x130
Mar 25 22:04:32 rocket-01 kernel: [  232.020016]  [<ffffffff811bf5a1>] ? fsnotify_clear_marks_by_inode+0x31/0xf0
Mar 25 22:04:32 rocket-01 kernel: [  232.020016]  [<ffffffff8116c22f>] ? kmem_cache_free+0x2f/0x130
Mar 25 22:04:32 rocket-01 kernel: [  232.020016]  [<ffffffff8126be84>] ? avc_has_perm_flags+0x74/0x90
Mar 25 22:04:32 rocket-01 kernel: [  232.020016]  [<ffffffff81512ce6>] ? nf_sockopt_find.part.0+0xa6/0x120
Mar 25 22:04:32 rocket-01 kernel: [  232.020016]  [<ffffffff81512f38>] nf_sockopt+0x98/0xc0
Mar 25 22:04:32 rocket-01 kernel: [  232.020016]  [<ffffffff81512f78>] nf_getsockopt+0x18/0x20
Mar 25 22:04:32 rocket-01 kernel: [  232.020016]  [<ffffffff81523335>] ip_getsockopt+0xa5/0x110
Mar 25 22:04:32 rocket-01 kernel: [  232.020016]  [<ffffffff81543716>] raw_getsockopt+0x16/0x30
Mar 25 22:04:32 rocket-01 kernel: [  232.020016]  [<ffffffff814d2924>] sock_common_getsockopt+0x14/0x20
Mar 25 22:04:32 rocket-01 kernel: [  232.020016]  [<ffffffff814d1db3>] sys_getsockopt+0x73/0xe0
Mar 25 22:04:32 rocket-01 kernel: [  232.020016]  [<ffffffff815fc029>] system_call_fastpath+0x16/0x1b
Mar 25 22:04:32 rocket-01 kernel: [  232.020016] Code: 49 81 f8 00 01 00 00 0f 85 18 ff ff ff 45 31 f6 e9 45 fb ff ff 8b 05 17 28 01 00 c7 85 80 fe ff ff 01 02 01 00 89 85 84 fe ff ff <41> 8b 84 24 f8 05 00 00 89 85 88 fe ff ff e9 91 fc ff ff 48 8d 
Mar 25 22:04:32 rocket-01 kernel: [  232.020016] RIP  [<ffffffffa00bf6b9>] do_ip_vs_get_ctl+0x5d9/0x960 [ip_vs]
Mar 25 22:04:32 rocket-01 kernel: [  232.020016]  RSP <ffff88003b9f3ca8>
Mar 25 22:04:32 rocket-01 kernel: [  232.020016] CR2: 00000000000005f8
Mar 25 22:04:32 rocket-01 kernel: [  232.086854] ---[ end trace 3203677ddb800294 ]---
Mar 25 22:04:32 rocket-01 kernel: [  232.088977] IPVS: Connection hash table configured (size=4096, memory=64Kbytes)
Mar 25 22:04:32 rocket-01 kernel: [  232.090732] IPVS: Creating netns size=2088 id=0
Mar 25 22:04:32 rocket-01 kernel: [  232.092253] IPVS: ipvs loaded.

--------------000409080208020808000005--
