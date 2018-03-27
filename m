From: Julian Anastasov <ja@ssi.bg>
Subject: Re: possible deadlock in rtnl_lock (5)
Date: Tue, 27 Mar 2018 22:52:36 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1803272227370.3460@ja.home.ssi.bg>
References: <000000000000f7826f0568630354@google.com> <20180327115001.GC26275@breakpoint.cc>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20180327115001.GC26275@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Florian Westphal <fw@strlen.de>
Cc: syzbot <syzbot+a46d6abf9d56b1365a72@syzkaller.appspotmail.com>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, syzkaller-bugs@googlegroups.com


	Hello,

On Tue, 27 Mar 2018, Florian Westphal wrote:

> syzbot <syzbot+a46d6abf9d56b1365a72@syzkaller.appspotmail.com> wrote:
> [ cc Julian and trimming cc list ]
> 
> > syzkaller688027/4497 is trying to acquire lock:
> >  (rtnl_mutex){+.+.}, at: [<00000000bb14d7fb>] rtnl_lock+0x17/0x20
> > net/core/rtnetlink.c:74
> 
> > but task is already holding lock:
> > IPVS: stopping backup sync thread 4495 ...
> >  (rtnl_mutex){+.+.}, at: [<00000000bb14d7fb>] rtnl_lock+0x17/0x20
> > net/core/rtnetlink.c:74
> > 
> > other info that might help us debug this:
> >  Possible unsafe locking scenario:
> > 
> >        CPU0
> >        ----
> >   lock(rtnl_mutex);
> >   lock(rtnl_mutex);
> > 
> >  *** DEADLOCK ***
> > 
> >  May be due to missing lock nesting notation
> 
> Looks like this is real, commit e0b26cc997d57305b4097711e12e13992580ae34
> ("ipvs: call rtnl_lock early") added rtnl_lock when starting sync thread
> but socket close invokes rtnl_lock too:

	I see, thanks! I'll have to move the locks into
start_sync_thread and to split make_{send,receive}_sock
to {make,setup}_{send,receive}_sock ...

> > stack backtrace:
> >  rtnl_lock+0x17/0x20 net/core/rtnetlink.c:74
> >  ip_mc_drop_socket+0x88/0x230 net/ipv4/igmp.c:2643
> >  inet_release+0x4e/0x1c0 net/ipv4/af_inet.c:413
> >  sock_release+0x8d/0x1e0 net/socket.c:595
> >  start_sync_thread+0x2213/0x2b70 net/netfilter/ipvs/ip_vs_sync.c:1924
> >  do_ip_vs_set_ctl+0x1139/0x1cc0 net/netfilter/ipvs/ip_vs_ctl.c:2389

Regards
