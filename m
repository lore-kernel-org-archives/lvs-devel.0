From: Andreas Schwab <schwab@linux-m68k.org>
Subject: Re: get rid of the address_space override in setsockopt v2
Date: Sun, 26 Jul 2020 09:08:42 +0200
Message-ID: <87imea3g91.fsf@linux-m68k.org>
References: <20200723060908.50081-1-hch@lst.de>
        <20200724.154342.1433271593505001306.davem@davemloft.net>
        <20200726070311.GA16687@lst.de>
Mime-Version: 1.0
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20200726070311.GA16687@lst.de> (Christoph Hellwig's message of
        "Sun, 26 Jul 2020 09:03:11 +0200")
Sender: linux-can-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: David Miller <davem@davemloft.net>, kuba@kernel.org, ast@kernel.org, daniel@iogearbox.net, kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, edumazet@google.com, linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, bpf@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-sctp@vger.kernel.org, linux-hams@vger.kernel.org, linux-bluetooth@vger.kernel.org, bridge@lists.linux-foundation.org, linux-can@vger.kernel.org, dccp@vger.kernel.org, linux-decnet-user@lists.sourceforge.net, linux-wpan@vger.kernel.org, linux-s390@vger.kernel.org, mptcp@lists.01.org, lvs-devel@vger.kernel.org, rds-devel@oss.oracle.com, linux-afs@lists.infradead.org, tipc-discussion@lists.sourceforge.net, linux-x25@vger.kernel.org

On Jul 26 2020, Christoph Hellwig wrote:

> From 6601732f7a54db5f04efba08f7e9224e5b757112 Mon Sep 17 00:00:00 2001
> From: Christoph Hellwig <hch@lst.de>
> Date: Sun, 26 Jul 2020 09:00:09 +0200
> Subject: mISDN: remove a debug printk in data_sock_setsockopt
>
> The %p won't work with the new sockptr_t type.  But in the times of
> ftrace, bpftrace and co these kinds of debug printks are pretty anyway,

I think there is a word missing after pretty.

Andreas.

-- 
Andreas Schwab, schwab@linux-m68k.org
GPG Key fingerprint = 7578 EB47 D4E5 4D69 2510  2552 DF73 E780 A9DA AEC1
"And now for something completely different."
