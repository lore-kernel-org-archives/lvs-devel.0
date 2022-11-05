From: Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH v4a 00/38] timers: Use timer_shutdown*()
 before freeing timers
Date: Sat, 5 Nov 2022 12:31:29 -0700
Message-ID: <20221105193129.GA1487775@roeck-us.net>
References: <20221105060024.598488967@goodmis.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <drbd-dev-bounces-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20210112;
	h=in-reply-to:content-disposition:mime-version:references:message-id
	:subject:cc:to:from:date:sender:from:to:cc:subject:date:message-id
	:reply-to; bh=CTlAHc9k7qwIZyOhFoXagieaQq5pwRyAvyi0mAOE5RE=;
	b=jURw19XL/xOvCrYwmv2aWUKdeAoWjP9YO+FTg9LO7kNLGP2qrxnNI/DeaM/hhYlqsP
	YdQYptnzjKsYbbyAKOY5T5QWBhSSLuRj9tx/h3x3Iolz6OENad9xOgpnNTl3bQfF4abr
	IGnRZ+gwoVhjhy8eDyzb76gdYWeTNG8HbYJzf+upnNf3q7GfCqhXHTbMnctQM+lT4ISN
	LgN+zILvYp/x3cxyWSBN67VcIOLSthpIiMe3XVQLxJ5DNQbV3DpA0r2y4Xi6Om/6kI/T
	+bTGJHJtUOpMMkvOkxDlr0Z5JMnZYu43sVpFgzYDCR/HFlqDOFJ8Z5bQFtUlln66Rbqg
	ggdQ==
Content-Disposition: inline
In-Reply-To: <20221105060024.598488967-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
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
Cc: alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org, linux-staging-cunTk1MwBs/YUNznpcFYbw@public.gmane.org, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, linaro-mm-sig-cunTk1MwBs8s++Sfvej+rw@public.gmane.org, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, linux-leds-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, drbd-dev-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nilfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-atm-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-afs-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, lvs-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, intel-wired-lan-qjLDD68F18P21nG7glBr7A@public.gmane.org, linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tipc-discussion-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bridge-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, intel-gfx-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, rcu-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, openipmi-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, Anna-Maria Gleixner <anna-maria@l>

On Sat, Nov 05, 2022 at 02:00:24AM -0400, Steven Rostedt wrote:
> 
> Back in April, I posted an RFC patch set to help mitigate a common issue
> where a timer gets armed just before it is freed, and when the timer
> goes off, it crashes in the timer code without any evidence of who the
> culprit was. I got side tracked and never finished up on that patch set.
> Since this type of crash is still our #1 crash we are seeing in the field,
> it has become a priority again to finish it.
> 
> The last version of that patch set is here:
> 
>   https://lore.kernel.org/all/20221104054053.431922658-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org/
> 
> I'm calling this version 4a as it only has obvious changes were the timer that
> is being shutdown is in the same function where it will be freed or released,
> as this series should be "safe" for adding. I'll be calling the other patches
> 4b for the next merge window.
> 

For the series, as far as my testbed goes:

Build results:
	total: 152 pass: 152 fail: 0
Qemu test results:
	total: 500 pass: 500 fail: 0

No runtime crashes or warnings observed.

Tested-by: Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>

Guenter
