From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [RFC][PATCH v2 19/31] timers: net: Use del_timer_shutdown()
 before freeing timer
Date: Thu, 27 Oct 2022 17:15:55 -0400
Message-ID: <20221027171555.7fcd27ee@gandalf.local.home>
References: <20221027150525.753064657@goodmis.org>
        <20221027150928.780676863@goodmis.org>
        <20221027155513.60b211e2@gandalf.local.home>
        <CAHk-=wjAjW2P5To82+CAM0Rx8RexQBHPTVZBWBPHyEPGm37oFA@mail.gmail.com>
        <20221027163453.383bbf8e@gandalf.local.home>
        <CAHk-=whoS+krLU7JNe=hMp2VOcwdcCdTXhdV8qqKoViwzzJWfA@mail.gmail.com>
        <20221027170720.31497319@gandalf.local.home>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20221027170720.31497319@gandalf.local.home>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Stephen Boyd <sboyd@kernel.org>, Guenter Roeck <linux@roeck-us.net>, Jesse Brandeburg <jesse.brandeburg@intel.com>, Tony Nguyen <anthony.l.nguyen@intel.com>, "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, Mirko Lindner <mlindner@marvell.com>, Stephen Hemminger <stephen@networkplumber.org>, Martin KaFai Lau <martin.lau@kernel.org>, Alexei Starovoitov <ast@kernel.org>, Kuniyuki Iwashima <kuniyu@amazon.com>, Pavel Begunkov <asml.silence@gmail.com>, Menglong Dong <imagedong@tencent.com>, linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org, bridge@lists.linux-foundation.org, netfilter-de

On Thu, 27 Oct 2022 17:07:20 -0400
Steven Rostedt <rostedt@goodmis.org> wrote:

> > And maybe that function can also disallow any future re-arming even
> > for the case where the timer couldn't be actively removed.  

The naming of the functions will depend on this.

If the async version always shuts down the timer, then we should have the
interface be:

	del_timer_shutdown() <- async

	del_timer_shutdown_sync <- sync

As it would match the del_timer() and del_timer_sync() semantics.

If shutdown only happens if the timer is removed, then I believe the
current approach of del_timer_shutdown() being synchronous and
del_timer_try_shutdown() being async is the way to go, as it follows more
the semantics of mutex_lock() and mutex_trylock().

-- Steve
