From: Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [RFC][PATCH v2 19/31] timers: net: Use del_timer_shutdown()
 before freeing timer
Date: Fri, 4 Nov 2022 09:14:45 -0700
Message-ID: <20221104161445.GA1866159@roeck-us.net>
References: <20221027163453.383bbf8e@gandalf.local.home>
 <CAHk-=whoS+krLU7JNe=hMp2VOcwdcCdTXhdV8qqKoViwzzJWfA@mail.gmail.com>
 <20221027170720.31497319@gandalf.local.home>
 <20221027183511.66b058c4@gandalf.local.home>
 <20221028183149.2882a29b@gandalf.local.home>
 <20221028154617.3c63ba68@kernel.org>
 <27a6a587fee5e9172e41acd16ae1bc1f556fdbd7.camel@redhat.com>
 <20221103175123.744d0f37@rorschach.local.home>
 <CANn89iLv9cak6_vXJG5t=Kq+eiMPdMxF8w4AAuAuFB5sOsy2zg@mail.gmail.com>
 <20221104015139.58f17730@rorschach.local.home>
Mime-Version: 1.0
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:sender:from:to:cc:subject:date:message-id
         :reply-to;
        bh=vkBGgKFgg4QPXCpHtMi6j0J3ZcIgUdwyTJWClmiO8n8=;
        b=ZXT4b7xGHkwhtyRx7V1geQfUresoJ3Ad36AKxZcA+hYEkLlZTMmJdsg3FLF6RZb4Bm
         /Th2KOsiFM+wv4AFPnrljoJs2GpR7KNawydYt2C5cew9YFo+qW0UidzKrk4BDuG1u7w+
         m3w563eSaiPwL3l4sGKZaD+ak6hpgQhlR7eGCpJqdUtIM7CX7IVrS9HVCezWAA8wIfI4
         tbWxHgw8jm41jK3k3dRhGJKkPfEdX95COskXHfzG/e/VIoBDLovAFvOX7zEd4Utr1gQo
         7jv8BY+ymXeC+5KaWJgeXULPlc8QwCY2a+1Wc4m/cSjP0OKV+9XQ8V5888RvdMmc7n4q
         obpw==
Sender: Guenter Roeck <groeck7-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20221104015139.58f17730-tvvo3QnZDcrq6bvjpv6Lkf3PFXHtQ0wO@public.gmane.org>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Cc: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Jakub Kicinski <kuba-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Stephen Boyd <sboyd-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Jesse Brandeburg <jesse.brandeburg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Tony Nguyen <anthony.l.nguyen-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Mirko Lindner <mlindner-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>, Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>, Martin KaFai Lau <martin.lau-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Kuniyuki Iwashima <kuniyu-vV1OtcyAfmbQT0dZR+AlfA@public.gmane.org>, Pavel Begunkov <asml.silence-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Menglong Dong <imagedong-1Nz4purKYjRBDgjK7y7TUQ@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bridge-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org

On Fri, Nov 04, 2022 at 01:51:39AM -0400, Steven Rostedt wrote:
> On Thu, 3 Nov 2022 17:00:20 -0700
> Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> 
> >  inet_csk_clear_xmit_timers() can be called multiple times during TCP
> > socket lifetime.
> > 
> > (See tcp_disconnect(), which can be followed by another connect() ... and loop)
> > 
> > Maybe add a second parameter, or add a new
> > inet_csk_shutdown_xmit_timers() only called from tcp_v4_destroy_sock() ?
> > 
> 
> I guess.
> 
> > >
> > >  void inet_csk_delete_keepalive_timer(struct sock *sk)
> > >  {
> > > -       sk_stop_timer(sk, &sk->sk_timer);
> > > +       sk_shutdown_timer(sk, &sk->sk_timer);  
> > 
> > SO_KEEPALIVE can be called multiple times in a TCP socket lifetime,
> > on/off/on/off/...
> > 
> > I suggest leaving sk_stop_timer() here.
> > 
> > Eventually  inet_csk_clear_xmit_timers( sk, destroy=true) (or
> > inet_csk_shutdown_xmit_timers(())
> >    will  be called before the socket is destroyed.
> 
> OK. 
> 
> Guenter,
> 
> I posted a new series, but did not include this change. If you want to
> test that other series, I would suggest to at least add the first part
> of this patch, otherwise it will trigger. But we want to see if there's
> other locations of issue that we should care about.
> 

I'll run a test on the other series without change first. We'll see what
happens. If necessary I'll add [parts of] this patch and re-test, but
before doing that I would like to get a sense for the status of your
series as-is.

Thanks,
Guenter
