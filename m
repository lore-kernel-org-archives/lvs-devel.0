From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [syzbot] memory leak in ip_vs_add_service
Date: Wed, 2 Jun 2021 17:39:00 -0400
Message-ID: <CADvbK_duDeZidW1mgSyNo+f1Hj4L0V6=L-Upfgp+5DEu5P-8Ag@mail.gmail.com>
References: <000000000000c91e6f05c3144acc@google.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=xos9OJTYV7KNq70j5XkcIV//nbltaFsBYHEXjco6NKo=;
        b=CEHFlIyOM7mg0/TRCHBMyLp1RcGKwVIuVbKwywkAw5G5GYiL8a53OnMSr+eN26BLzV
         HlSWBx201WY19VSo6Nlp0oIT/WsJBtVYjBTwWpKCsCE0x+XVknr+AqU9ri5VU++bQ2lf
         GnrJykYPK5Qej6jQz3ICHMVJ/DzT3/aOlPQ9Go8biUD2QpWZOOGbKenOt3SqKLqg+aPB
         caHWepWix0xAWHMfEXvqx6H01rMXlIZOfn64uEY3yeLuD3P8/mhcH0PIcq6Ow1Vq4AJz
         /rabVhwJTpIQxkEfnOTWjBa0tw2+8rNvMYsTLALD92CLp1FkmwDgRYcHwebpJ0uxbMCg
         8xqQ==
In-Reply-To: <000000000000c91e6f05c3144acc@google.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: syzbot <syzbot+e562383183e4b1766930@syzkaller.appspotmail.com>
Cc: coreteam@netfilter.org, davem <davem@davemloft.net>, Florian Westphal <fw@strlen.de>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, kadlec@netfilter.org, Jakub Kicinski <kuba@kernel.org>, LKML <linux-kernel@vger.kernel.org>, lvs-devel@vger.kernel.org, network dev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>

On Mon, May 24, 2021 at 10:33 AM syzbot
<syzbot+e562383183e4b1766930@syzkaller.appspotmail.com> wrote:
>
> Hello,
>
> syzbot found the following issue on:
>
> HEAD commit:    c3d0e3fd Merge tag 'fs.idmapped.mount_setattr.v5.13-rc3' o..
> git tree:       upstream
> console output: https://syzkaller.appspot.com/x/log.txt?x=148d0bd7d00000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=ae7b129a135ab06b
> dashboard link: https://syzkaller.appspot.com/bug?extid=e562383183e4b1766930
> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=15585a4bd00000
> C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=13900753d00000
>
> IMPORTANT: if you fix the issue, please add the following tag to the commit:
> Reported-by: syzbot+e562383183e4b1766930@syzkaller.appspotmail.com
>
> BUG: memory leak
> unreferenced object 0xffff888115227800 (size 512):
>   comm "syz-executor263", pid 8658, jiffies 4294951882 (age 12.560s)
>   hex dump (first 32 bytes):
>     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>   backtrace:
>     [<ffffffff83977188>] kmalloc include/linux/slab.h:556 [inline]
>     [<ffffffff83977188>] kzalloc include/linux/slab.h:686 [inline]
>     [<ffffffff83977188>] ip_vs_add_service+0x598/0x7c0 net/netfilter/ipvs/ip_vs_ctl.c:1343
>     [<ffffffff8397d770>] do_ip_vs_set_ctl+0x810/0xa40 net/netfilter/ipvs/ip_vs_ctl.c:2570
>     [<ffffffff838449a8>] nf_setsockopt+0x68/0xa0 net/netfilter/nf_sockopt.c:101
>     [<ffffffff839ae4e9>] ip_setsockopt+0x259/0x1ff0 net/ipv4/ip_sockglue.c:1435
>     [<ffffffff839fa03c>] raw_setsockopt+0x18c/0x1b0 net/ipv4/raw.c:857
>     [<ffffffff83691f20>] __sys_setsockopt+0x1b0/0x360 net/socket.c:2117
>     [<ffffffff836920f2>] __do_sys_setsockopt net/socket.c:2128 [inline]
>     [<ffffffff836920f2>] __se_sys_setsockopt net/socket.c:2125 [inline]
>     [<ffffffff836920f2>] __x64_sys_setsockopt+0x22/0x30 net/socket.c:2125
>     [<ffffffff84350efa>] do_syscall_64+0x3a/0xb0 arch/x86/entry/common.c:47
>     [<ffffffff84400068>] entry_SYSCALL_64_after_hwframe+0x44/0xae
do_ip_vs_set_ctl() allows users to add svc with the flags field set.
when IP_VS_SVC_F_HASHED is used, and in ip_vs_svc_hash()
called ip_vs_add_service() will trigger the err msg:

IPVS: ip_vs_svc_hash(): request for already hashed, called from
do_ip_vs_set_ctl+0x810/0xa40

and the svc allocated will leak.

so fix it by mask the flags with ~IP_VS_SVC_F_HASHED in
ip_vs_copy_usvc_compat(), while at it also remove the unnecessary
flag IP_VS_SVC_F_HASHED set in ip_vs_edit_service().

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index d45dbcba8b49..f09a443c9ec0 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1497,7 +1497,6 @@ ip_vs_edit_service(struct ip_vs_service *svc,
struct ip_vs_service_user_kern *u)
        /*
         * Set the flags and timeout value
         */
-       svc->flags = u->flags | IP_VS_SVC_F_HASHED;
        svc->timeout = u->timeout * HZ;
        svc->netmask = u->netmask;

@@ -2430,7 +2429,7 @@ static void ip_vs_copy_usvc_compat(struct
ip_vs_service_user_kern *usvc,
        /* Deep copy of sched_name is not needed here */
        usvc->sched_name        = usvc_compat->sched_name;

-       usvc->flags             = usvc_compat->flags;
+       usvc->flags             = usvc_compat->flags & ~IP_VS_SVC_F_HASHED;
        usvc->timeout           = usvc_compat->timeout;
        usvc->netmask           = usvc_compat->netmask;
 }


>
>
>
> ---
> This report is generated by a bot. It may contain errors.
> See https://goo.gl/tpsmEJ for more information about syzbot.
> syzbot engineers can be reached at syzkaller@googlegroups.com.
>
> syzbot will keep track of this issue. See:
> https://goo.gl/tpsmEJ#status for how to communicate with syzbot.
> syzbot can test patches for this issue, for details see:
> https://goo.gl/tpsmEJ#testing-patches
