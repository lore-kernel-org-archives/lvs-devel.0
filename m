From: syzbot <syzbot+7810ed2e0cb359580c17@syzkaller.appspotmail.com>
Subject: Re: INFO: task hung in do_ip_vs_set_ctl (2)
Date: Tue, 26 Nov 2019 07:47:00 -0800
Message-ID: <0000000000007a85c4059841ca66@google.com>
References: <94eb2c059ce0bca273056940d77d@google.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <94eb2c059ce0bca273056940d77d@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"; delsp="yes"
Content-Transfer-Encoding: 7bit
To: coreteam@netfilter.org, davem@davemloft.net, fw@strlen.de, horms@verge.net.au, ja@ssi.bg, kadlec@blackhole.kfki.hu, linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, mmarek@suse.com, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, pablo@netfilter.org, syzkaller-bugs@googlegroups.com, torvalds@linux-foundation.org, wensong@linux-vs.org, yamada.masahiro@socionext.com

syzbot has bisected this bug to:

commit 6f7da290413ba713f0cdd9ff1a2a9bb129ef4f6c
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Sun Jul 2 23:07:02 2017 +0000

     Linux 4.12

bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=11a2b78ce00000
start commit:   17dec0a9 Merge branch 'userns-linus' of git://git.kernel.o..
git tree:       net-next
kernel config:  https://syzkaller.appspot.com/x/.config?x=da08d02b86752ade
dashboard link: https://syzkaller.appspot.com/bug?extid=7810ed2e0cb359580c17
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=130abb47800000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=150a15bb800000

Reported-by: syzbot+7810ed2e0cb359580c17@syzkaller.appspotmail.com
Fixes: 6f7da290413b ("Linux 4.12")

For information about bisection process see: https://goo.gl/tpsmEJ#bisection
