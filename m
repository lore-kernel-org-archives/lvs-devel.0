From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [syzbot] memory leak in ip_vs_add_service
Date: Thu, 3 Jun 2021 13:35:35 -0400
Message-ID: <CADvbK_cUe=T5-zBcgUm4uA7rjqsomoB+DZYs9tQSWbqP3Q77Pw@mail.gmail.com>
References: <000000000000c91e6f05c3144acc@google.com> <CADvbK_duDeZidW1mgSyNo+f1Hj4L0V6=L-Upfgp+5DEu5P-8Ag@mail.gmail.com>
 <b216d7a4-c3dd-3714-3897-3124769c88f2@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=9ZEWHSSOb74rLWBdPbbD8Bw6Cd9qJ07nhLoANozAowA=;
        b=s1rHc9mCAalfAD9jNYasuCBfe7xeQ6PErUmHUjpRlAfZctPlDyJzoyZDFz0S644oTL
         tuIcnViK0JYmqG7TOGcuVnIJfHLnVBhGEcYJEwyipCvInodMovVIiqZD9clCGUA3A7JG
         UH8rHj9LeQa8Xia46PTscM8jQTd+tHoNgoXaq0JyCKCiTBzD4uUYU3bt8LiyZotOB5Tf
         OPqA1rYk6mrXkIR/VU1MIO5EaEXW/QEBfxaCiw00pHPAccx0FNvw/Ix9lf3T//EmHchm
         wckQ4m0buQR+jKtPUXW2psRKoSODGxOFdKrewizUUtNQAF2pOKO04u2voygJ3Qp9wrBw
         xPrw==
In-Reply-To: <b216d7a4-c3dd-3714-3897-3124769c88f2@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: syzbot <syzbot+e562383183e4b1766930@syzkaller.appspotmail.com>, coreteam@netfilter.org, Simon Horman <horms@verge.net.au>, LKML <linux-kernel@vger.kernel.org>, lvs-devel@vger.kernel.org, network dev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org, syzkaller-bugs <syzkaller-bugs@googlegroups.com>

On Thu, Jun 3, 2021 at 1:32 PM Julian Anastasov <ja@ssi.bg> wrote:
>
>
>         Hello,
>
> On Wed, 2 Jun 2021, Xin Long wrote:
>
> > On Mon, May 24, 2021 at 10:33 AM syzbot
> > <syzbot+e562383183e4b1766930@syzkaller.appspotmail.com> wrote:
> > >
> > > Hello,
> > >
> > > syzbot found the following issue on:
> > >
> > > HEAD commit:    c3d0e3fd Merge tag 'fs.idmapped.mount_setattr.v5.13-rc3' o..
> > > git tree:       upstream
> > > console output: https://syzkaller.appspot.com/x/log.txt?x=148d0bd7d00000
> > > kernel config:  https://syzkaller.appspot.com/x/.config?x=ae7b129a135ab06b
> > > dashboard link: https://syzkaller.appspot.com/bug?extid=e562383183e4b1766930
> > > syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=15585a4bd00000
> > > C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=13900753d00000
> > >
> > > IMPORTANT: if you fix the issue, please add the following tag to the commit:
> > > Reported-by: syzbot+e562383183e4b1766930@syzkaller.appspotmail.com
> > >
> > > BUG: memory leak
> > > unreferenced object 0xffff888115227800 (size 512):
> > >   comm "syz-executor263", pid 8658, jiffies 4294951882 (age 12.560s)
> > >   hex dump (first 32 bytes):
> > >     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> > >     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> > >   backtrace:
> > >     [<ffffffff83977188>] kmalloc include/linux/slab.h:556 [inline]
> > >     [<ffffffff83977188>] kzalloc include/linux/slab.h:686 [inline]
> > >     [<ffffffff83977188>] ip_vs_add_service+0x598/0x7c0 net/netfilter/ipvs/ip_vs_ctl.c:1343
> > >     [<ffffffff8397d770>] do_ip_vs_set_ctl+0x810/0xa40 net/netfilter/ipvs/ip_vs_ctl.c:2570
> > >     [<ffffffff838449a8>] nf_setsockopt+0x68/0xa0 net/netfilter/nf_sockopt.c:101
> > >     [<ffffffff839ae4e9>] ip_setsockopt+0x259/0x1ff0 net/ipv4/ip_sockglue.c:1435
> > >     [<ffffffff839fa03c>] raw_setsockopt+0x18c/0x1b0 net/ipv4/raw.c:857
> > >     [<ffffffff83691f20>] __sys_setsockopt+0x1b0/0x360 net/socket.c:2117
> > >     [<ffffffff836920f2>] __do_sys_setsockopt net/socket.c:2128 [inline]
> > >     [<ffffffff836920f2>] __se_sys_setsockopt net/socket.c:2125 [inline]
> > >     [<ffffffff836920f2>] __x64_sys_setsockopt+0x22/0x30 net/socket.c:2125
> > >     [<ffffffff84350efa>] do_syscall_64+0x3a/0xb0 arch/x86/entry/common.c:47
> > >     [<ffffffff84400068>] entry_SYSCALL_64_after_hwframe+0x44/0xae
> > do_ip_vs_set_ctl() allows users to add svc with the flags field set.
> > when IP_VS_SVC_F_HASHED is used, and in ip_vs_svc_hash()
> > called ip_vs_add_service() will trigger the err msg:
> >
> > IPVS: ip_vs_svc_hash(): request for already hashed, called from
> > do_ip_vs_set_ctl+0x810/0xa40
> >
> > and the svc allocated will leak.
> >
> > so fix it by mask the flags with ~IP_VS_SVC_F_HASHED in
> > ip_vs_copy_usvc_compat(), while at it also remove the unnecessary
> > flag IP_VS_SVC_F_HASHED set in ip_vs_edit_service().
>
>         The net tree already contains fix for this problem.
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
>
good, thanks for the info, :-)
