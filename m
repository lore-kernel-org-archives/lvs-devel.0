From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: possible deadlock in rtnl_lock (5)
Date: Wed, 28 Mar 2018 07:56:30 +0200
Message-ID: <CACT4Y+baLrWMh9m5h+arz0uTn2acXyzJHhHWxpK4HHzVAHDZSg@mail.gmail.com>
References: <000000000000f7826f0568630354@google.com> <20180327115001.GC26275@breakpoint.cc>
 <alpine.LFD.2.20.1803272227370.3460@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:in-reply-to:references:from:date:message-id:subject:to
         :cc;
        bh=Z7ufyaF80U4311JrWWifl4zq/f495OB+hC4iawgDB0E=;
        b=jLlLx9ztLIge+A+tf59+oJYvMG8l4YaJVXVQSeEeHBRc6rdOyUknPYp5xhV7jHY9GO
         o2ulTcC6TM1miuH9S+iT3cXcZg6ov/hpHhst/DoG0g4FOe1N0Jn4x+jLhC2GcY1SDzhS
         Q5JK5navj9pJP1sJ1E+Dk6Zm8epplRwVVmfDa1P9JCQFG8kNYSXDFzRHQp9NdOzAw/+H
         AKZ4TTIFg+uD02Tv+RyFrEuYLwtu6x1/hgxPvfP7UqBmPISa3xPUTLF/esBU7mfGt3kg
         odc2FQStbe6vd0C5CzovFh75yAa4Zph2nnGJoYApnKf7QrS/A08UGx4uxXvs33Ay1PRz
         O0Fg==
In-Reply-To: <alpine.LFD.2.20.1803272227370.3460@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Florian Westphal <fw@strlen.de>, syzbot <syzbot+a46d6abf9d56b1365a72@syzkaller.appspotmail.com>, netdev <netdev@vger.kernel.org>, lvs-devel@vger.kernel.org, syzkaller-bugs@googlegroups.com

Please keep the Reported-by notice, and reproducer will probably be useful too:

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+a46d6abf9d56b1365a72@syzkaller.appspotmail.com
It will help syzbot understand when the bug is fixed. See footer for details.
If you forward the report, please keep this part and the footer.

syzbot hit the following crash on upstream commit
3eb2ce825ea1ad89d20f7a3b5780df850e4be274 (Sun Mar 25 22:44:30 2018 +0000)
Linux 4.16-rc7
syzbot dashboard link:
https://syzkaller.appspot.com/bug?extid=a46d6abf9d56b1365a72

So far this crash happened 27 times on net-next, upstream.
C reproducer: https://syzkaller.appspot.com/x/repro.c?id=6524202618191872
syzkaller reproducer:
https://syzkaller.appspot.com/x/repro.syz?id=5383267238805504
Raw console output: https://syzkaller.appspot.com/x/log.txt?id=5136472378179584
Kernel config: https://syzkaller.appspot.com/x/.config?id=-8440362230543204781
compiler: gcc (GCC) 7.1.1 20170620




On Tue, Mar 27, 2018 at 9:52 PM, Julian Anastasov <ja@ssi.bg> wrote:
>
>         Hello,
>
> On Tue, 27 Mar 2018, Florian Westphal wrote:
>
>> syzbot <syzbot+a46d6abf9d56b1365a72@syzkaller.appspotmail.com> wrote:
>> [ cc Julian and trimming cc list ]
>>
>> > syzkaller688027/4497 is trying to acquire lock:
>> >  (rtnl_mutex){+.+.}, at: [<00000000bb14d7fb>] rtnl_lock+0x17/0x20
>> > net/core/rtnetlink.c:74
>>
>> > but task is already holding lock:
>> > IPVS: stopping backup sync thread 4495 ...
>> >  (rtnl_mutex){+.+.}, at: [<00000000bb14d7fb>] rtnl_lock+0x17/0x20
>> > net/core/rtnetlink.c:74
>> >
>> > other info that might help us debug this:
>> >  Possible unsafe locking scenario:
>> >
>> >        CPU0
>> >        ----
>> >   lock(rtnl_mutex);
>> >   lock(rtnl_mutex);
>> >
>> >  *** DEADLOCK ***
>> >
>> >  May be due to missing lock nesting notation
>>
>> Looks like this is real, commit e0b26cc997d57305b4097711e12e13992580ae34
>> ("ipvs: call rtnl_lock early") added rtnl_lock when starting sync thread
>> but socket close invokes rtnl_lock too:
>
>         I see, thanks! I'll have to move the locks into
> start_sync_thread and to split make_{send,receive}_sock
> to {make,setup}_{send,receive}_sock ...
>
>> > stack backtrace:
>> >  rtnl_lock+0x17/0x20 net/core/rtnetlink.c:74
>> >  ip_mc_drop_socket+0x88/0x230 net/ipv4/igmp.c:2643
>> >  inet_release+0x4e/0x1c0 net/ipv4/af_inet.c:413
>> >  sock_release+0x8d/0x1e0 net/socket.c:595
>> >  start_sync_thread+0x2213/0x2b70 net/netfilter/ipvs/ip_vs_sync.c:1924
>> >  do_ip_vs_set_ctl+0x1139/0x1cc0 net/netfilter/ipvs/ip_vs_ctl.c:2389
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/syzkaller-bugs/alpine.LFD.2.20.1803272227370.3460%40ja.home.ssi.bg.
> For more options, visit https://groups.google.com/d/optout.
