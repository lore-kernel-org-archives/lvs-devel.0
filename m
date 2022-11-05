From: "Jason A. Donenfeld" <Jason-OnJsPKxuuEcAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v4a 00/38] timers: Use timer_shutdown*()
 before freeing timers
Date: Sat, 5 Nov 2022 22:03:18 +0100
Message-ID: <Y2bPlllkHo5DUmLY@zx2c4.com>
References: <20221105060024.598488967@goodmis.org>
	<CAHk-=wi95dGkg7DiuOZ27gGW+mxJipn9ykB6LHB-HrbbLG6OMQ@mail.gmail.com>
	<20221105123642.596371c7@rorschach.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <drbd-dev-bounces-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=zx2c4.com; s=20210105; 
	t=1667682204;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	in-reply-to:in-reply-to:references:references;
	bh=eqdLYS8BDcnZ1CTVSLTL2V9mpBrsInljjeWX569KabI=;
	b=Ek158U/IwAdzp/7JgxH8/niYIDD2c7iDpM/q00frrsf+kptgL3uCiSQ7Xlb7SIQ9YvTtg5
	hlBVvQrg9GahoQxIsHXxgh/CGzM4sTACdo/WX2PYJwuZbLx0SZ+njeVN3snq9LgpG5MQMr
	EBxmnADIwq+lyFhZU+rPI7l5k3bHDuo=
Content-Disposition: inline
In-Reply-To: <20221105123642.596371c7-tvvo3QnZDcrq6bvjpv6Lkf3PFXHtQ0wO@public.gmane.org>
List-Id: <lvs-devel.vger.kernel.org>
List-Unsubscribe: <https://lists.linbit.com/mailman/options/drbd-dev>,
	<mailto:drbd-dev-request-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linbit.com/pipermail/drbd-dev>
List-Post: <mailto:drbd-dev-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org>
List-Help: <mailto:drbd-dev-request-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linbit.com/mailman/listinfo/drbd-dev>,
	<mailto:drbd-dev-request-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org?subject=subscribe>
Sender: drbd-dev-bounces-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org
Errors-To: drbd-dev-bounces-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org
To: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Cc: alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org, linux-staging-cunTk1MwBs/YUNznpcFYbw@public.gmane.org, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, linaro-mm-sig-cunTk1MwBs8s++Sfvej+rw@public.gmane.org, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, linux-leds-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, drbd-dev-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nilfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-atm-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-afs-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, lvs-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, intel-wired-lan-qjLDD68F18P21nG7glBr7A@public.gmane.org, linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tipc-discussion-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>, linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bridge-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, intel-gfx-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, rcu-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, openipmi-developer-5NWGOfrQmneRv+LV9MX5uv+2+P5yyue3@public.gmane.org

On Sat, Nov 05, 2022 at 12:36:42PM -0400, Steven Rostedt wrote:
> ----------------------8<------------------------
> @@
> identifier ptr, timer, rfield, slab;
> @@
> (
> -	del_timer(&ptr->timer);
> +	timer_shutdown(&ptr->timer);
> |
> -	del_timer_sync(&ptr->timer);
> +	timer_shutdown_sync(&ptr->timer);
> )
>     ...
> (
> 	kfree_rcu(ptr, rfield);
> |
> 	kmem_cache_free(slab, ptr);
> |
> 	kfree(ptr);
> )
> ---------------------->8------------------------

Something that might help here is changing the `...` into
`... when exists` or into `... when != ptr` or similar.
See this section of the manual:
https://coccinelle.gitlabpages.inria.fr/website/docs/main_grammar004.html

Jason
