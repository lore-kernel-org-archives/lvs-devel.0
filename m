From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [RFC][PATCH v2 19/31] timers: net: Use del_timer_shutdown()
 before freeing timer
Date: Thu, 3 Nov 2022 17:51:23 -0400
Message-ID: <20221103175123.744d0f37@rorschach.local.home>
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
        <27a6a587fee5e9172e41acd16ae1bc1f556fdbd7.camel@redhat.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <27a6a587fee5e9172e41acd16ae1bc1f556fdbd7.camel@redhat.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Paolo Abeni <pabeni@redhat.com>
Cc: Jakub Kicinski <kuba@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Stephen Boyd <sboyd@kernel.org>, Guenter Roeck <linux@roeck-us.net>, Jesse Brandeburg <jesse.brandeburg@intel.com>, Tony Nguyen <anthony.l.nguyen@intel.com>, "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, Mirko Lindner <mlindner@marvell.com>, Stephen Hemminger <stephen@networkplumber.org>, Martin KaFai Lau <martin.lau@kernel.org>, Alexei Starovoitov <ast@kernel.org>, Kuniyuki Iwashima <kuniyu@amazon.com>, Pavel Begunkov <asml.silence@gmail.com>, Menglong Dong <imagedong@tencent.com>, linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org, bridge@lists.linux-foundation.or

On Sun, 30 Oct 2022 18:22:03 +0100
Paolo Abeni <pabeni@redhat.com> wrote:

> On the positive side, I think converting the sk_stop_timer in 
> inet_csk_clear_xmit_timers() should be safe and should cover the issue
> reported by Guenter

Would something like this be OK? 

[ Note, talking with Thomas Gleixner, we agreed that we are changing the
  name to: time_shutdown_sync() and timer_shutdown() (no wait version).
  I'll be posting new patches soon. ]

-- Steve

diff --git a/include/net/sock.h b/include/net/sock.h
index 22f8bab583dd..0ef58697d4e5 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2439,6 +2439,8 @@ void sk_stop_timer(struct sock *sk, struct timer_list *timer);
 
 void sk_stop_timer_sync(struct sock *sk, struct timer_list *timer);
 
+void sk_shutdown_timer(struct sock *sk, struct timer_list *timer);
+
 int __sk_queue_drop_skb(struct sock *sk, struct sk_buff_head *sk_queue,
 			struct sk_buff *skb, unsigned int flags,
 			void (*destructor)(struct sock *sk,
diff --git a/net/core/sock.c b/net/core/sock.c
index a3ba0358c77c..82124862b594 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -3357,6 +3357,13 @@ void sk_stop_timer_sync(struct sock *sk, struct timer_list *timer)
 }
 EXPORT_SYMBOL(sk_stop_timer_sync);
 
+void sk_shutdown_timer(struct sock *sk, struct timer_list* timer)
+{
+	if (timer_shutdown(timer))
+		__sock_put(sk);
+}
+EXPORT_SYMBOL(sk_shutdown_timer);
+
 void sock_init_data(struct socket *sock, struct sock *sk)
 {
 	sk_init_common(sk);
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 5e70228c5ae9..71f398f51958 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -722,15 +722,15 @@ void inet_csk_clear_xmit_timers(struct sock *sk)
 
 	icsk->icsk_pending = icsk->icsk_ack.pending = 0;
 
-	sk_stop_timer(sk, &icsk->icsk_retransmit_timer);
-	sk_stop_timer(sk, &icsk->icsk_delack_timer);
-	sk_stop_timer(sk, &sk->sk_timer);
+	sk_shutdown_timer(sk, &icsk->icsk_retransmit_timer);
+	sk_shutdown_timer(sk, &icsk->icsk_delack_timer);
+	sk_shutdown_timer(sk, &sk->sk_timer);
 }
 EXPORT_SYMBOL(inet_csk_clear_xmit_timers);
 
 void inet_csk_delete_keepalive_timer(struct sock *sk)
 {
-	sk_stop_timer(sk, &sk->sk_timer);
+	sk_shutdown_timer(sk, &sk->sk_timer);
 }
 EXPORT_SYMBOL(inet_csk_delete_keepalive_timer);
 


