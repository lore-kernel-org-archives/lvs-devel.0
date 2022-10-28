From: Jakub Kicinski <kuba@kernel.org>
Subject: Re: [RFC][PATCH v2 19/31] timers: net: Use del_timer_shutdown()
 before freeing timer
Date: Fri, 28 Oct 2022 15:46:17 -0700
Message-ID: <20221028154617.3c63ba68@kernel.org>
References: <20221027150525.753064657@goodmis.org>
        <20221027150928.780676863@goodmis.org>
        <20221027155513.60b211e2@gandalf.local.home>
        <CAHk-=wjAjW2P5To82+CAM0Rx8RexQBHPTVZBWBPHyEPGm37oFA@mail.gmail.com>
        <20221027163453.383bbf8e@gandalf.local.home>
        <CAHk-=whoS+krLU7JNe=hMp2VOcwdcCdTXhdV8qqKoViwzzJWfA@mail.gmail.com>
        <20221027170720.31497319@gandalf.local.home>
        <20221027183511.66b058c4@gandalf.local.home>
        <20221028183149.2882a29b@gandalf.local.home>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1666997179;
        bh=s26jHyd1kGfu++KNYnyX//dTrAoWFdZ+ZNmo3nKnJss=;
        h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
        b=VxGwJ9O9yotsrKvlxcwXmQ0Fk4p3v9D5+DlTte1u/b8zE1L6oWXtT1okcCGymzc+F
         uUzTBz6nnK6iiPp7ONuOcluxciyA+H2AWZrZubpDNsGXF9Il1djnbo/LR4hvlZPj9A
         0kcsvnbXvyZm70ZgqLxx8R3a5VvJzOLCGoXRet/I+ti1hMmQnBvu+tjrjCIr4vv2w6
         OEFoGL6xEvwVAQA3kmozlS8z6UFzjyJceJxRPFqcAUpN8icgdMmKp9Kauc4XA3OBaI
         M/O249pRehQLwqy4hrrgyuAQ8mLrPOQJg4gBTCW/3paQdOBy2HRsGcOdxhzSitZK13
         YSSld8uxG8jGQ==
In-Reply-To: <20221028183149.2882a29b@gandalf.local.home>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Stephen Boyd <sboyd@kernel.org>, Guenter Roeck <linux@roeck-us.net>, Jesse Brandeburg <jesse.brandeburg@intel.com>, Tony Nguyen <anthony.l.nguyen@intel.com>, "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, Paolo Abeni <pabeni@redhat.com>, Mirko Lindner <mlindner@marvell.com>, Stephen Hemminger <stephen@networkplumber.org>, Martin KaFai Lau <martin.lau@kernel.org>, Alexei Starovoitov <ast@kernel.org>, Kuniyuki Iwashima <kuniyu@amazon.com>, Pavel Begunkov <asml.silence@gmail.com>, Menglong Dong <imagedong@tencent.com>, linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org, bridge@lists.linux-foundation.org

On Fri, 28 Oct 2022 18:31:49 -0400 Steven Rostedt wrote:
> Could someone from networking confirm (or deny) that the timer being
> removed in sk_stop_timer() will no longer be used even if del_timer()
> returns false?
> 
> net/core/sock.c:
> 
> void sk_stop_timer(struct sock *sk, struct timer_list* timer)
> {
> 	if (del_timer(timer))
> 		__sock_put(sk);
> }
> 
> If this is the case, then I'll add the following interface:
> 
>    del_timer_sync_shutdown() // the common case which syncs
> 
>    del_timer_shutdown() // the uncommon case, that returns immediately
>                         // used for those cases that add extra code to
>                         // handle it, like sk_stop_timer()

Sorry too many bugs at once :)

FWIW Paolo was saying privately earlier today that he spotted some cases
of reuse, he gave an example of ccid2_hc_tx_packet_recv()

So we can't convert all cases of sk_stop_timer() in one fell swoop :(

> Which has the same semantics as del_timer_sync() and del_timer()
> respectively, but will prevent the timer from being rearmed again.
> 
> This way we can convert the sk_stop_timer() to:
> 
> void sk_stop_timer(struct sock *sk, struct timer_list* timer)
> {
> 	if (del_timer_shutdown(timer))
> 		__sock_put(sk);
> }
> 
> 
> We can also add the del_timer_shutdown() to other locations that need to
> put a timer into a shutdown state before freeing, and where it's in a
> context that can not call del_timer_sync_shutdown().
