From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [RFC][PATCH v2 19/31] timers: net: Use
 del_timer_shutdown() before freeing timer
Date: Thu, 27 Oct 2022 16:13:55 -0700
Message-ID: <20221027231355.GA279418@roeck-us.net>
Mime-Version: 1.0
Return-path: <bridge-bounces@lists.linux-foundation.org>
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp3.osuosl.org 47AB7607AA
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp3.osuosl.org 8F75260773
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp2.osuosl.org 49EF7402DC
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp2.osuosl.org 479C4400D0
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20210112;
 h=content-disposition:mime-version:message-id:subject:cc:to:from:date
 :sender:from:to:cc:subject:date:message-id:reply-to;
 bh=P41rwxhUMczs6ljwzqKYGCdlQ+dI/irnsNJUBE737lw=;
 b=nUs4BQ4QHj5upmui25ZlamsxDTY94q2eK6CXv3krB1huVK8iXo01EW8k7VAhNVROHi
 PjYBf8CwASEYPGf6SwTYwp/ZxxL+hu+oIEzBD66Gszc4ROJ0le1pA55DFqSM51JsTFZU
 gU5Wpx+bws1qVVFzHCN4FW/OY3wOMqGAS29n07JnNPwk7gWEJ4JAX/hseDkT64kYN3wQ
 XrXoWl/xM7zG/HuTEiKdr1MfmR0ifM6cjZrdxqnY+bg/ra9Xu38mR+BX7nY3UrahaCWD
 AC2+gJVoU576iIFXXsgNFhmCCUiwKUFb0hh6k9uqPefGAva3wPgPVGU4KfkgNYVbwaAx
 djyQ==
Content-Disposition: inline
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
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Alexei Starovoitov <ast@kernel.org>, Eric Dumazet <edumazet@google.com>, Tony Nguyen <anthony.l.nguyen@intel.com>, linux-afs@lists.infradead.org, Menglong Dong <imagedong@tencent.com>, bridge@lists.linux-foundation.org, Jesse Brandeburg <jesse.brandeburg@intel.com>, lvs-devel@vger.kernel.org, coreteam@netfilter.org, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, Martin KaFai Lau <martin.lau@kernel.org>, Kuniyuki Iwashima <kuniyu@amazon.com>, Thomas Gleixner <tglx@linutronix.de>, Mirko Lindner <mlindner@marvell.com>, linux-nfs@vger.kernel.org, tipc-discussion@lists.sourceforge.net, Stephen Boyd <sboyd@kernel.org>, linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, netfilter-devel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Pavel Begunkov <asml.silence@gm>

On Thu, Oct 27, 2022 at 05:07:55PM -0400, Steven Rostedt wrote:
> On Thu, 27 Oct 2022 16:34:53 -0400
> Steven Rostedt <rostedt@goodmis.org> wrote:
> 
> > What about del_timer_try_shutdown(), that if it removes the timer, it sets
> > the function to NULL (making it equivalent to a successful shutdown),
> > otherwise it does nothing. Allowing the the timer to be rearmed.
> > 
> > I think this would work in this case.
> 
> Guenter,
> 
> Can you apply this patch on top of the series, and see if it makes the
> warning go away?

Applied, and started testing.

Please let me know if I am missing some other patch(es) to apply.

Thanks,
Guenter

> 
> diff --git a/include/linux/timer.h b/include/linux/timer.h
> index d4d90149d015..e3c5f4bdd526 100644
> --- a/include/linux/timer.h
> +++ b/include/linux/timer.h
> @@ -184,12 +184,23 @@ static inline int timer_pending(const struct timer_list * timer)
>  	return !hlist_unhashed_lockless(&timer->entry);
>  }
>  
> +extern int __del_timer(struct timer_list * timer, bool free);
> +
>  extern void add_timer_on(struct timer_list *timer, int cpu);
> -extern int del_timer(struct timer_list * timer);
>  extern int mod_timer(struct timer_list *timer, unsigned long expires);
>  extern int mod_timer_pending(struct timer_list *timer, unsigned long expires);
>  extern int timer_reduce(struct timer_list *timer, unsigned long expires);
>  
> +static inline int del_timer_try_shutdown(struct timer_list *timer)
> +{
> +	return __del_timer(timer, true);
> +}
> +
> +static inline int del_timer(struct timer_list *timer)
> +{
> +	return __del_timer(timer, false);
> +}
> +
>  /*
>   * The jiffies value which is added to now, when there is no timer
>   * in the timer wheel:
> diff --git a/kernel/time/timer.c b/kernel/time/timer.c
> index 7305c65ad0eb..073031cb3bb9 100644
> --- a/kernel/time/timer.c
> +++ b/kernel/time/timer.c
> @@ -1255,7 +1255,7 @@ EXPORT_SYMBOL_GPL(add_timer_on);
>   * (ie. del_timer() of an inactive timer returns 0, del_timer() of an
>   * active timer returns 1.)
>   */
> -int del_timer(struct timer_list *timer)
> +int __del_timer(struct timer_list *timer, bool free)
>  {
>  	struct timer_base *base;
>  	unsigned long flags;
> @@ -1266,12 +1266,16 @@ int del_timer(struct timer_list *timer)
>  	if (timer_pending(timer)) {
>  		base = lock_timer_base(timer, &flags);
>  		ret = detach_if_pending(timer, base, true);
> +		if (free && ret) {
> +			timer->function = NULL;
> +			debug_timer_deactivate(timer);
> +		}
>  		raw_spin_unlock_irqrestore(&base->lock, flags);
>  	}
>  
>  	return ret;
>  }
> -EXPORT_SYMBOL(del_timer);
> +EXPORT_SYMBOL(__del_timer);
>  
>  static int __try_to_del_timer_sync(struct timer_list *timer, bool free)
>  {
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 10cc84379d75..23a97442a0a6 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -3345,7 +3345,7 @@ EXPORT_SYMBOL(sk_reset_timer);
>  
>  void sk_stop_timer(struct sock *sk, struct timer_list* timer)
>  {
> -	if (del_timer(timer))
> +	if (del_timer_try_shutdown(timer))
>  		__sock_put(sk);
>  }
>  EXPORT_SYMBOL(sk_stop_timer);
