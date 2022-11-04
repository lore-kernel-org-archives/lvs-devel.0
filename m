From: Eric Dumazet <edumazet@google.com>
Subject: Re: [RFC][PATCH v2 19/31] timers: net: Use del_timer_shutdown()
 before freeing timer
Date: Thu, 3 Nov 2022 17:00:20 -0700
Message-ID: <CANn89iLv9cak6_vXJG5t=Kq+eiMPdMxF8w4AAuAuFB5sOsy2zg@mail.gmail.com>
References: <20221027150525.753064657@goodmis.org> <20221027150928.780676863@goodmis.org>
 <20221027155513.60b211e2@gandalf.local.home> <CAHk-=wjAjW2P5To82+CAM0Rx8RexQBHPTVZBWBPHyEPGm37oFA@mail.gmail.com>
 <20221027163453.383bbf8e@gandalf.local.home> <CAHk-=whoS+krLU7JNe=hMp2VOcwdcCdTXhdV8qqKoViwzzJWfA@mail.gmail.com>
 <20221027170720.31497319@gandalf.local.home> <20221027183511.66b058c4@gandalf.local.home>
 <20221028183149.2882a29b@gandalf.local.home> <20221028154617.3c63ba68@kernel.org>
 <27a6a587fee5e9172e41acd16ae1bc1f556fdbd7.camel@redhat.com> <20221103175123.744d0f37@rorschach.local.home>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20210112;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:from:to:cc:subject:date:message-id:reply-to;
        bh=OIWN7urgPvg7gWQ/2jmCuNIcCwluarihUklEPGyHjcg=;
        b=WfZQ7T5J19AGsPaNUJuOsP0Km5Ixqe3g2OjzWlZ48O9n++G6HOElr/NHRpLA9fDnwr
         zjRaF+oN7J52K4Hkt1QfKpCQB5Wz5OV6RrsZAgAUs0tkU6h0aV7cYd6yEHz8xOWTUUaE
         nTwx3sfZXExTHFKflgZ0kHbhOyWH5xYa/4o8baHcab29Hq9pAX7cOlT1SrWXDbt87QYk
         qqJgjVZVqEHQO2qDmqBHDnF4n6wAmtRz5tmd/UsTP0SD10mD6uXXRAlwFdt5yYXaLs84
         Q6NGteraqshFTYF08psP5WYnjWqJg/XADvug0NuClQLOveJFe7i203jnVfhv2iws1QsI
         5poA==
In-Reply-To: <20221103175123.744d0f37@rorschach.local.home>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Paolo Abeni <pabeni@redhat.com>, Jakub Kicinski <kuba@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Stephen Boyd <sboyd@kernel.org>, Guenter Roeck <linux@roeck-us.net>, Jesse Brandeburg <jesse.brandeburg@intel.com>, Tony Nguyen <anthony.l.nguyen@intel.com>, "David S. Miller" <davem@davemloft.net>, Mirko Lindner <mlindner@marvell.com>, Stephen Hemminger <stephen@networkplumber.org>, Martin KaFai Lau <martin.lau@kernel.org>, Alexei Starovoitov <ast@kernel.org>, Kuniyuki Iwashima <kuniyu@amazon.com>, Pavel Begunkov <asml.silence@gmail.com>, Menglong Dong <imagedong@tencent.com>, linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org, bridge@lists.linux-foundation.org, netfilte

On Thu, Nov 3, 2022 at 2:51 PM Steven Rostedt <rostedt@goodmis.org> wrote:
>
> On Sun, 30 Oct 2022 18:22:03 +0100
> Paolo Abeni <pabeni@redhat.com> wrote:
>
> > On the positive side, I think converting the sk_stop_timer in
> > inet_csk_clear_xmit_timers() should be safe and should cover the issue
> > reported by Guenter
>
> Would something like this be OK?
>
> [ Note, talking with Thomas Gleixner, we agreed that we are changing the
>   name to: time_shutdown_sync() and timer_shutdown() (no wait version).
>   I'll be posting new patches soon. ]
>
> -- Steve
>
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 22f8bab583dd..0ef58697d4e5 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -2439,6 +2439,8 @@ void sk_stop_timer(struct sock *sk, struct timer_list *timer);
>
>  void sk_stop_timer_sync(struct sock *sk, struct timer_list *timer);
>
> +void sk_shutdown_timer(struct sock *sk, struct timer_list *timer);
> +
>  int __sk_queue_drop_skb(struct sock *sk, struct sk_buff_head *sk_queue,
>                         struct sk_buff *skb, unsigned int flags,
>                         void (*destructor)(struct sock *sk,
> diff --git a/net/core/sock.c b/net/core/sock.c
> index a3ba0358c77c..82124862b594 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -3357,6 +3357,13 @@ void sk_stop_timer_sync(struct sock *sk, struct timer_list *timer)
>  }
>  EXPORT_SYMBOL(sk_stop_timer_sync);
>
> +void sk_shutdown_timer(struct sock *sk, struct timer_list* timer)
> +{
> +       if (timer_shutdown(timer))
> +               __sock_put(sk);
> +}
> +EXPORT_SYMBOL(sk_shutdown_timer);
> +
>  void sock_init_data(struct socket *sock, struct sock *sk)
>  {
>         sk_init_common(sk);
> diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
> index 5e70228c5ae9..71f398f51958 100644
> --- a/net/ipv4/inet_connection_sock.c
> +++ b/net/ipv4/inet_connection_sock.c
> @@ -722,15 +722,15 @@ void inet_csk_clear_xmit_timers(struct sock *sk)
>
>         icsk->icsk_pending = icsk->icsk_ack.pending = 0;
>
> -       sk_stop_timer(sk, &icsk->icsk_retransmit_timer);
> -       sk_stop_timer(sk, &icsk->icsk_delack_timer);
> -       sk_stop_timer(sk, &sk->sk_timer);
> +       sk_shutdown_timer(sk, &icsk->icsk_retransmit_timer);
> +       sk_shutdown_timer(sk, &icsk->icsk_delack_timer);
> +       sk_shutdown_timer(sk, &sk->sk_timer);
>  }
>  EXPORT_SYMBOL(inet_csk_clear_xmit_timers);

 inet_csk_clear_xmit_timers() can be called multiple times during TCP
socket lifetime.

(See tcp_disconnect(), which can be followed by another connect() ... and loop)

Maybe add a second parameter, or add a new
inet_csk_shutdown_xmit_timers() only called from tcp_v4_destroy_sock() ?

>
>  void inet_csk_delete_keepalive_timer(struct sock *sk)
>  {
> -       sk_stop_timer(sk, &sk->sk_timer);
> +       sk_shutdown_timer(sk, &sk->sk_timer);

SO_KEEPALIVE can be called multiple times in a TCP socket lifetime,
on/off/on/off/...

I suggest leaving sk_stop_timer() here.

Eventually  inet_csk_clear_xmit_timers( sk, destroy=true) (or
inet_csk_shutdown_xmit_timers(())
   will  be called before the socket is destroyed.
