From: David Miller <davem@davemloft.net>
Subject: Re: get rid of the address_space override in setsockopt v2
Date: Sun, 26 Jul 2020 00:46:44 -0700 (PDT)
Message-ID: <20200726.004644.71243023033363639.davem@davemloft.net>
References: <20200723060908.50081-1-hch@lst.de>
        <20200724.154342.1433271593505001306.davem@davemloft.net>
        <20200726070311.GA16687@lst.de>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20200726070311.GA16687@lst.de>
Sender: linux-crypto-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: hch@lst.de
Cc: kuba@kernel.org, ast@kernel.org, daniel@iogearbox.net, kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, edumazet@google.com, linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, bpf@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-sctp@vger.kernel.org, linux-hams@vger.kernel.org, linux-bluetooth@vger.kernel.org, bridge@lists.linux-foundation.org, linux-can@vger.kernel.org, dccp@vger.kernel.org, linux-decnet-user@lists.sourceforge.net, linux-wpan@vger.kernel.org, linux-s390@vger.kernel.org, mptcp@lists.01.org, lvs-devel@vger.kernel.org, rds-devel@oss.oracle.com, linux-afs@lists.infradead.org, tipc-discussion@lists.sourceforge.net, linux-x25@vger.kernel.org

From: Christoph Hellwig <hch@lst.de>
Date: Sun, 26 Jul 2020 09:03:11 +0200

> On Fri, Jul 24, 2020 at 03:43:42PM -0700, David Miller wrote:
>> > Changes since v1:
>> >  - check that users don't pass in kernel addresses
>> >  - more bpfilter cleanups
>> >  - cosmetic mptcp tweak
>> 
>> Series applied to net-next, I'm build testing and will push this out when
>> that is done.
> 
> The buildbot found one warning with the isdn debug code after a few
> days, here is what I think is the best fix:

I already fixed this in net-next.
