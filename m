From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [RFC][PATCH v2 19/31] timers: net: Use
 del_timer_shutdown() before freeing timer
Date: Fri, 4 Nov 2022 01:51:39 -0400
Message-ID: <20221104015139.58f17730@rorschach.local.home>
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
 <20221103175123.744d0f37@rorschach.local.home>
 <CANn89iLv9cak6_vXJG5t=Kq+eiMPdMxF8w4AAuAuFB5sOsy2zg@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <bridge-bounces@lists.linux-foundation.org>
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp3.osuosl.org C4AB061042
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp3.osuosl.org C435760A8A
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp3.osuosl.org 0CA8461038
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp3.osuosl.org 3EB5160A8A
In-Reply-To: <CANn89iLv9cak6_vXJG5t=Kq+eiMPdMxF8w4AAuAuFB5sOsy2zg@mail.gmail.com>
List-Id: <lvs-devel.vger.kernel.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>, 
 <mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
 <mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Errors-To: bridge-bounces@lists.linux-foundation.org
Sender: "Bridge" <bridge-bounces@lists.linux-foundation.org>
Content-Type: text/plain; charset="us-ascii"
To: Eric Dumazet <edumazet@google.com>
Cc: Alexei Starovoitov <ast@kernel.org>, Tony Nguyen <anthony.l.nguyen@intel.com>, linux-afs@lists.infradead.org, Menglong Dong <imagedong@tencent.com>, bridge@lists.linux-foundation.org, Jesse Brandeburg <jesse.brandeburg@intel.com>, lvs-devel@vger.kernel.org, coreteam@netfilter.org, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, Guenter Roeck <linux@roeck-us.net>, Martin KaFai Lau <martin.lau@kernel.org>, Kuniyuki Iwashima <kuniyu@amazon.com>, Thomas Gleixner <tglx@linutronix.de>, Mirko Lindner <mlindner@marvell.com>, linux-nfs@vger.kernel.org, tipc-discussion@lists.sourceforge.net, Stephen Boyd <sboyd@kernel.org>, linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, netfilter-devel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Pavel Begunkov <asml.silence@g>

On Thu, 3 Nov 2022 17:00:20 -0700
Eric Dumazet <edumazet@google.com> wrote:

>  inet_csk_clear_xmit_timers() can be called multiple times during TCP
> socket lifetime.
> 
> (See tcp_disconnect(), which can be followed by another connect() ... and loop)
> 
> Maybe add a second parameter, or add a new
> inet_csk_shutdown_xmit_timers() only called from tcp_v4_destroy_sock() ?
> 

I guess.

> >
> >  void inet_csk_delete_keepalive_timer(struct sock *sk)
> >  {
> > -       sk_stop_timer(sk, &sk->sk_timer);
> > +       sk_shutdown_timer(sk, &sk->sk_timer);  
> 
> SO_KEEPALIVE can be called multiple times in a TCP socket lifetime,
> on/off/on/off/...
> 
> I suggest leaving sk_stop_timer() here.
> 
> Eventually  inet_csk_clear_xmit_timers( sk, destroy=true) (or
> inet_csk_shutdown_xmit_timers(())
>    will  be called before the socket is destroyed.

OK. 

Guenter,

I posted a new series, but did not include this change. If you want to
test that other series, I would suggest to at least add the first part
of this patch, otherwise it will trigger. But we want to see if there's
other locations of issue that we should care about.

-- Steve
