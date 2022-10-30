From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [RFC][PATCH v2 19/31] timers: net: Use del_timer_shutdown()
 before freeing timer
Date: Sun, 30 Oct 2022 18:22:03 +0100
Message-ID: <27a6a587fee5e9172e41acd16ae1bc1f556fdbd7.camel@redhat.com>
References: <20221027150525.753064657@goodmis.org>
         <20221027150928.780676863@goodmis.org>
         <20221027155513.60b211e2@gandalf.local.home>
         <CAHk-=wjAjW2P5To82+CAM0Rx8RexQBHPTVZBWBPHyEPGm37oFA@mail.gmail.com>
         <20221027163453.383bbf8e@gandalf.local.home>
         <CAHk-=whoS+krLU7JNe=hMp2VOcwdcCdTXhdV8qqKoViwzzJWfA@mail.gmail.com>
         <20221027170720.31497319@gandalf.local.home>
         <20221027183511.66b058c4@gandalf.local.home>
         <20221028183149.2882a29b@gandalf.local.home>
         <20221028154617.3c63ba68@kernel.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1667150531;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=xy7b3nRtAL8M7+VedHsmmAKhtOAAl2XLancWVFWUXlg=;
        b=DprYLL7Egkml7INxACtxk2WTXNU/oB6vcLwo6VYQ8Wn5xXo94eBlZLumhMizda/1lglgEE
        aDCIkAQbLRE8Y9+U57pXpJ3KxbHyKfFx4J73T8YH8JUODn05TQODtFXgUzM3r/90Aa2KVx
        YwEs0hV/8gjZYRo8uL1ipAZ89Tn+kak=
In-Reply-To: <20221028154617.3c63ba68@kernel.org>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Jakub Kicinski <kuba@kernel.org>, Steven Rostedt <rostedt@goodmis.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Stephen Boyd <sboyd@kernel.org>, Guenter Roeck <linux@roeck-us.net>, Jesse Brandeburg <jesse.brandeburg@intel.com>, Tony Nguyen <anthony.l.nguyen@intel.com>, "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, Mirko Lindner <mlindner@marvell.com>, Stephen Hemminger <stephen@networkplumber.org>, Martin KaFai Lau <martin.lau@kernel.org>, Alexei Starovoitov <ast@kernel.org>, Kuniyuki Iwashima <kuniyu@amazon.com>, Pavel Begunkov <asml.silence@gmail.com>, Menglong Dong <imagedong@tencent.com>, linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org, bridge@lists.linux-foundation.org, netfilter-devel@vger.kernel.org

On Fri, 2022-10-28 at 15:46 -0700, Jakub Kicinski wrote:
> On Fri, 28 Oct 2022 18:31:49 -0400 Steven Rostedt wrote:
> > Could someone from networking confirm (or deny) that the timer being
> > removed in sk_stop_timer() will no longer be used even if del_timer()
> > returns false?
> > 
> > net/core/sock.c:
> > 
> > void sk_stop_timer(struct sock *sk, struct timer_list* timer)
> > {
> > 	if (del_timer(timer))
> > 		__sock_put(sk);
> > }
> > 
> > If this is the case, then I'll add the following interface:
> > 
> >    del_timer_sync_shutdown() // the common case which syncs
> > 
> >    del_timer_shutdown() // the uncommon case, that returns immediately
> >                         // used for those cases that add extra code to
> >                         // handle it, like sk_stop_timer()
> 
> Sorry too many bugs at once :)
> 
> FWIW Paolo was saying privately earlier today that he spotted some cases
> of reuse, he gave an example of ccid2_hc_tx_packet_recv()

For the records, there are other cases, e.g. after sk_stop_timer() in 
clear_3rdack_retransmission() (mptcp code) the timer can be-rearmed
without re-initializing. I *think* there are more of such use in the 
in ax25/rose code.

> So we can't convert all cases of sk_stop_timer() in one fell swoop :(

On the positive side, I think converting the sk_stop_timer in 
inet_csk_clear_xmit_timers() should be safe and should cover the issue
reported by Guenter

Cheers,

Paolo

