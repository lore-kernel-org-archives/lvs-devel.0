From: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Subject: Re: [RFC][PATCH v2 19/31] timers: net: Use del_timer_shutdown()
 before freeing timer
Date: Thu, 27 Oct 2022 17:07:20 -0400
Message-ID: <20221027170720.31497319@gandalf.local.home>
References: <20221027150525.753064657@goodmis.org>
        <20221027150928.780676863@goodmis.org>
        <20221027155513.60b211e2@gandalf.local.home>
        <CAHk-=wjAjW2P5To82+CAM0Rx8RexQBHPTVZBWBPHyEPGm37oFA@mail.gmail.com>
        <20221027163453.383bbf8e@gandalf.local.home>
        <CAHk-=whoS+krLU7JNe=hMp2VOcwdcCdTXhdV8qqKoViwzzJWfA@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAHk-=whoS+krLU7JNe=hMp2VOcwdcCdTXhdV8qqKoViwzzJWfA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Stephen Boyd <sboyd-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>, Jesse Brandeburg <jesse.brandeburg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Tony Nguyen <anthony.l.nguyen-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Jakub Kicinski <kuba-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Mirko Lindner <mlindner-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>, Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>, Martin KaFai Lau <martin.lau-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Kuniyuki Iwashima <kuniyu-vV1OtcyAfmbQT0dZR+AlfA@public.gmane.org>, Pavel Begunkov <asml.silence-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Menglong Dong <imagedong-1Nz4purKYjRBDgjK7y7TUQ@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bridge-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netfilter-de

On Thu, 27 Oct 2022 13:48:54 -0700
Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:

> On Thu, Oct 27, 2022 at 1:34 PM Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org> wrote:
> >
> > What about del_timer_try_shutdown(), that if it removes the timer, it sets
> > the function to NULL (making it equivalent to a successful shutdown),
> > otherwise it does nothing. Allowing the the timer to be rearmed.  
> 
> Sounds sane to me and should work, but as mentioned, I think the
> networking people need to say "yeah" too.
> 
> And maybe that function can also disallow any future re-arming even
> for the case where the timer couldn't be actively removed.

Well, I think this current use case will break if we prevent the timer from
being rearmed or run again if it's not found. But as you said, the
networking folks need to confirm or deny it.

The fact that it does the sock_put() when it removes the timer makes me
think that it can be called again, and we shouldn't prevent that from
happening.

The debug code will let us know too, as it only "frees" it for freeing if
it deactivated the timer and shut it down.

> 
> So any *currently* active timer wouldn't be waited for (either because
> locking may make that a deadlock situation, or simply due to
> performance issues), but at least it would guarantee that no new timer
> activations can happen.
> 
> Because I do like the whole notion of "timer has been shutdown and
> cannot be used as a timer any more without re-initializing it" being a
> real state - even for a timer that may be "currently in flight".
> 
> So this all sounds very worthwhile to me, but I'm not surprised that
> we have code that then knows about all the subtleties of "del_timer()
> might still have a running timer" and actually take advantage of it
> (where "advantage" is likely more of a "deal with the complexities"
> rather than anything really positive ;)

Good to hear. This has been a thorn in our side as we keep hitting these
crashes in the timer code that look like a timer was freed before it
triggered.

> 
> And those existing subtle users might want particular semantics to at
> least make said complexities easier.
> 

Yeah, as someone told me recently, "If you let them play long enough without
setting out the rules, they will take advantage of everything and it will be
extremely hard to get them back in order".

-- Steve

