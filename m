Received: from mail-il1-f206.google.com (mail-il1-f206.google.com [209.85.166.206])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 15AD81F130A
	for <lvs-devel@vger.kernel.org>; Thu,  1 May 2025 15:06:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.166.206
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1746111996; cv=none; b=MdX17UPGJ8RzSufc5odSLAzR4wzAOsPvTdgChJPDK7iJ+/tzip6DP8YkY9CdKAEVnKRb9/SmIZnmke4FaAtPTVnmDG4S5SMVm5+q01TzDkjXV5L3Cdax0bo68s395SEBOe3fD6GrSDb2jh0C6bz8KABZIITwR1Rtnu9wGv09ORM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1746111996; c=relaxed/simple;
	bh=92JOii3jWAj4DKJszDeSKnQVESqen0D5y2yAev8Bcr8=;
	h=MIME-Version:Date:Message-ID:Subject:From:To:Content-Type; b=sQgERaZdmWJECGjop7ctOjjTn9gHYg5vsDF/7kIeotYNVQXLq4bA0bGU1pnqSkei0jqDutr//aA9Dgdy/aKeRN82P+bwzsMbL/nV2Fedmq21oPBnNbvmdwB8LWbrKx8/4kDqMcXyaNyPcdAo6tlyKFQhbu5CjFxkLSrEALx1E48=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com; arc=none smtp.client-ip=209.85.166.206
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com
Received: by mail-il1-f206.google.com with SMTP id e9e14a558f8ab-3d96661c8a2so13588615ab.0
        for <lvs-devel@vger.kernel.org>; Thu, 01 May 2025 08:06:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1746111994; x=1746716794;
        h=to:from:subject:message-id:date:mime-version:x-gm-message-state
         :from:to:cc:subject:date:message-id:reply-to;
        bh=5eH4/IxyGIQ/j17sepFRV59/LJDy4eEAai5InyyCjic=;
        b=j08oVd2uwQphUYkKmhaileoRAtoSG2EZnMV8sxnP+XwJuFWavBgztwN9Z9MfaWViok
         s2sgJcOVkIQDz3j6Ia+BEJNC0nTwJHbzOnz7M3A9aWOLBSzjUrSR7prH6fCKwd7wL7kf
         wRNEbkmL2xyXw5qGmRQ8h8Pb0u0DKxiZEmEfwG2SM+IlZuuJzm1IW2h/AqCKud2oUO+q
         2TsQFhU8/wIOlp1ZrwkXmj2HKoDgp0XIE/h0gofOHsiy2LV997RGjh7WzOacKeanrdRr
         OYjry9f6XGpMehelGYfnmzwq9AN4ltw4b0QrQK3/ztafU7Ly+hWHi2H4M+40JZJpR2+a
         lkhw==
X-Forwarded-Encrypted: i=1; AJvYcCWv17MGz9FuzMiRqrsnvKNTG6xpgXk2QpgLH/U7OxcJhNamfcXkyW8B+lsUg72/vOqp5SODEQ9bEv8=@vger.kernel.org
X-Gm-Message-State: AOJu0Yzfw6FfbLvsGRw4dekHIgO9utRK4/05wnck5sVD+Zl7oF5gbkSF
	M270g1+JLTqHQtZPEjoyNx9kgzDnWNd7xD+bFg8kShGmEOrfz3YDYhFh27hmTC36U41bZB/cZpm
	93gMe7P51DgysVDpYrIN/S5toOJAxgumqodL3V+VSZRlxU+WEMKZNLn0=
X-Google-Smtp-Source: AGHT+IGYkc2mm1+x+Xnn83DF+/+Q+9KJ5OV64G6RWcU+6RzrPGXItspl2t697nEcTp5NrWyml02qnCseN8+nWVoYWR1ZWHN9NpPf
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Received: by 2002:a05:6e02:188e:b0:3d5:891c:13fb with SMTP id
 e9e14a558f8ab-3d9701c93cfmr29836155ab.4.1746111994269; Thu, 01 May 2025
 08:06:34 -0700 (PDT)
Date: Thu, 01 May 2025 08:06:34 -0700
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <68138dfa.050a0220.14dd7d.0017.GAE@google.com>
Subject: [syzbot] [lvs?] KMSAN: uninit-value in do_output_route4
From: syzbot <syzbot+04b9a82855c8aed20860@syzkaller.appspotmail.com>
To: coreteam@netfilter.org, davem@davemloft.net, edumazet@google.com, 
	horms@verge.net.au, ja@ssi.bg, kadlec@netfilter.org, kuba@kernel.org, 
	linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, 
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, pabeni@redhat.com, 
	pablo@netfilter.org, syzkaller-bugs@googlegroups.com
Content-Type: text/plain; charset="UTF-8"

Hello,

syzbot found the following issue on:

HEAD commit:    bc3372351d0c Merge tag 'for-6.15-rc3-tag' of git://git.ker..
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=12d64574580000
kernel config:  https://syzkaller.appspot.com/x/.config?x=fca45111586bf9a6
dashboard link: https://syzkaller.appspot.com/bug?extid=04b9a82855c8aed20860
compiler:       Debian clang version 15.0.6, Debian LLD 15.0.6
userspace arch: i386

Unfortunately, I don't have any reproducer for this issue yet.

Downloadable assets:
disk image: https://storage.googleapis.com/syzbot-assets/01b8968610a1/disk-bc337235.raw.xz
vmlinux: https://storage.googleapis.com/syzbot-assets/528a97652269/vmlinux-bc337235.xz
kernel image: https://storage.googleapis.com/syzbot-assets/768ed51bbb66/bzImage-bc337235.xz

IMPORTANT: if you fix the issue, please add the following tag to the commit:
Reported-by: syzbot+04b9a82855c8aed20860@syzkaller.appspotmail.com

=====================================================
BUG: KMSAN: uninit-value in do_output_route4+0x42c/0x4d0 net/netfilter/ipvs/ip_vs_xmit.c:147
 do_output_route4+0x42c/0x4d0 net/netfilter/ipvs/ip_vs_xmit.c:147
 __ip_vs_get_out_rt+0x403/0x21d0 net/netfilter/ipvs/ip_vs_xmit.c:330
 ip_vs_tunnel_xmit+0x205/0x2380 net/netfilter/ipvs/ip_vs_xmit.c:1136
 ip_vs_in_hook+0x1aa5/0x35b0 net/netfilter/ipvs/ip_vs_core.c:2063
 nf_hook_entry_hookfn include/linux/netfilter.h:154 [inline]
 nf_hook_slow+0xf7/0x400 net/netfilter/core.c:626
 nf_hook include/linux/netfilter.h:269 [inline]
 __ip_local_out+0x758/0x7e0 net/ipv4/ip_output.c:118
 ip_local_out net/ipv4/ip_output.c:127 [inline]
 ip_send_skb+0x6a/0x3c0 net/ipv4/ip_output.c:1501
 udp_send_skb+0xfda/0x1b70 net/ipv4/udp.c:1195
 udp_sendmsg+0x2fe3/0x33c0 net/ipv4/udp.c:1483
 inet_sendmsg+0x1fc/0x280 net/ipv4/af_inet.c:851
 sock_sendmsg_nosec net/socket.c:712 [inline]
 __sock_sendmsg+0x267/0x380 net/socket.c:727
 ____sys_sendmsg+0x91b/0xda0 net/socket.c:2566
 ___sys_sendmsg+0x28d/0x3c0 net/socket.c:2620
 __sys_sendmmsg+0x41d/0x880 net/socket.c:2702
 __compat_sys_sendmmsg net/compat.c:360 [inline]
 __do_compat_sys_sendmmsg net/compat.c:367 [inline]
 __se_compat_sys_sendmmsg net/compat.c:364 [inline]
 __ia32_compat_sys_sendmmsg+0xc8/0x140 net/compat.c:364
 ia32_sys_call+0x3ffa/0x41f0 arch/x86/include/generated/asm/syscalls_32.h:346
 do_syscall_32_irqs_on arch/x86/entry/syscall_32.c:83 [inline]
 __do_fast_syscall_32+0xb0/0x110 arch/x86/entry/syscall_32.c:306
 do_fast_syscall_32+0x38/0x80 arch/x86/entry/syscall_32.c:331
 do_SYSENTER_32+0x1f/0x30 arch/x86/entry/syscall_32.c:369
 entry_SYSENTER_compat_after_hwframe+0x84/0x8e

Uninit was created at:
 slab_post_alloc_hook mm/slub.c:4167 [inline]
 slab_alloc_node mm/slub.c:4210 [inline]
 __kmalloc_cache_noprof+0x8fa/0xe00 mm/slub.c:4367
 kmalloc_noprof include/linux/slab.h:905 [inline]
 ip_vs_dest_dst_alloc net/netfilter/ipvs/ip_vs_xmit.c:61 [inline]
 __ip_vs_get_out_rt+0x35d/0x21d0 net/netfilter/ipvs/ip_vs_xmit.c:323
 ip_vs_tunnel_xmit+0x205/0x2380 net/netfilter/ipvs/ip_vs_xmit.c:1136
 ip_vs_in_hook+0x1aa5/0x35b0 net/netfilter/ipvs/ip_vs_core.c:2063
 nf_hook_entry_hookfn include/linux/netfilter.h:154 [inline]
 nf_hook_slow+0xf7/0x400 net/netfilter/core.c:626
 nf_hook include/linux/netfilter.h:269 [inline]
 __ip_local_out+0x758/0x7e0 net/ipv4/ip_output.c:118
 ip_local_out net/ipv4/ip_output.c:127 [inline]
 ip_send_skb+0x6a/0x3c0 net/ipv4/ip_output.c:1501
 udp_send_skb+0xfda/0x1b70 net/ipv4/udp.c:1195
 udp_sendmsg+0x2fe3/0x33c0 net/ipv4/udp.c:1483
 inet_sendmsg+0x1fc/0x280 net/ipv4/af_inet.c:851
 sock_sendmsg_nosec net/socket.c:712 [inline]
 __sock_sendmsg+0x267/0x380 net/socket.c:727
 ____sys_sendmsg+0x91b/0xda0 net/socket.c:2566
 ___sys_sendmsg+0x28d/0x3c0 net/socket.c:2620
 __sys_sendmmsg+0x41d/0x880 net/socket.c:2702
 __compat_sys_sendmmsg net/compat.c:360 [inline]
 __do_compat_sys_sendmmsg net/compat.c:367 [inline]
 __se_compat_sys_sendmmsg net/compat.c:364 [inline]
 __ia32_compat_sys_sendmmsg+0xc8/0x140 net/compat.c:364
 ia32_sys_call+0x3ffa/0x41f0 arch/x86/include/generated/asm/syscalls_32.h:346
 do_syscall_32_irqs_on arch/x86/entry/syscall_32.c:83 [inline]
 __do_fast_syscall_32+0xb0/0x110 arch/x86/entry/syscall_32.c:306
 do_fast_syscall_32+0x38/0x80 arch/x86/entry/syscall_32.c:331
 do_SYSENTER_32+0x1f/0x30 arch/x86/entry/syscall_32.c:369
 entry_SYSENTER_compat_after_hwframe+0x84/0x8e

CPU: 0 UID: 0 PID: 22408 Comm: syz.4.5165 Not tainted 6.15.0-rc3-syzkaller-00019-gbc3372351d0c #0 PREEMPT(undef) 
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 02/12/2025
=====================================================


---
This report is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this issue. See:
https://goo.gl/tpsmEJ#status for how to communicate with syzbot.

If the report is already addressed, let syzbot know by replying with:
#syz fix: exact-commit-title

If you want to overwrite report's subsystems, reply with:
#syz set subsystems: new-subsystem
(See the list of subsystem names on the web dashboard)

If the report is a duplicate of another one, reply with:
#syz dup: exact-subject-of-another-report

If you want to undo deduplication, reply with:
#syz undup
