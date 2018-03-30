From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: INFO: task hung in stop_sync_thread (2)
Date: Fri, 30 Mar 2018 18:54:33 +0200
Message-ID: <CACT4Y+Yj+yAQ3gAAsJfHt5cHsxtC_opKWa4qJEUF=3bMtEGDCg@mail.gmail.com>
References: <000000000000878b6a05688805c5@google.com> <94eb2c05b2d8af3dfa0568a3f964@google.com>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:in-reply-to:references:from:date:message-id:subject:to
         :cc;
        bh=2LwqPeb5ywcLDPVcMv/lbR/g859MZnhOEtywhXh+Asc=;
        b=RfPzf3FkIO5UWC4mSP0RzlT9NTOYqv+7Dsv1Kpk8ACm789Uuf8+lHUHc+rAs72zrkf
         pWfKsqmVpW/OYSqzFr3qCnIPl//kT3RNpOP3a6L2cby+Yo2RlIhsOtmUnClyZlP2puy9
         9i2DY810RUagfS7UJHeNheaYZ1iZDkz53/GTi6ckyt6Cu9o+7aECDHy+57PnLkjYbjqi
         YDSe3JTj1P0nvvfKBSUe/Xyooc7cYrxJWjXzxZWxLRVL2oM6aFJsnAbqFzIUYtTCfvrZ
         UHMUFV8ixAZc1iF8qSqRK0iwpxPASaWOBQFgbUc79A1lT9R/at0j0weAwy82rUUq6cQB
         1fNQ==
In-Reply-To: <94eb2c05b2d8af3dfa0568a3f964@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: syzbot <syzbot+5fe074c01b2032ce9618@syzkaller.appspotmail.com>
Cc: coreteam@netfilter.org, David Miller <davem@davemloft.net>, Florian Westphal <fw@strlen.de>, horms@verge.net.au, Julian Anastasov <ja@ssi.bg>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, LKML <linux-kernel@vger.kernel.org>, lvs-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, syzkaller-bugs@googlegroups.com, wensong@linux-vs.org

On Fri, Mar 30, 2018 at 6:46 PM, syzbot
<syzbot+5fe074c01b2032ce9618@syzkaller.appspotmail.com> wrote:
> syzbot has found reproducer for the following crash on net-next commit

/\/\/\/\/\/\

now syzbot can test fixes

> 18845557fd6fc1998f2d0d8c30467f86db587529 (Thu Mar 29 20:24:06 2018 +0000)
> Merge tag 'wireless-drivers-next-for-davem-2018-03-29' of
> git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next
> syzbot dashboard link:
> https://syzkaller.appspot.com/bug?extid=5fe074c01b2032ce9618
>
> So far this crash happened 2 times on net-next.
> C reproducer: https://syzkaller.appspot.com/x/repro.c?id=5531070485233664
> syzkaller reproducer:
> https://syzkaller.appspot.com/x/repro.syz?id=5632385408303104
> Raw console output:
> https://syzkaller.appspot.com/x/log.txt?id=6520566391504896
> Kernel config: https://syzkaller.appspot.com/x/.config?id=-37309782588693906
> compiler: gcc (GCC) 7.1.1 20170620
>
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+5fe074c01b2032ce9618@syzkaller.appspotmail.com
> It will help syzbot understand when the bug is fixed.
