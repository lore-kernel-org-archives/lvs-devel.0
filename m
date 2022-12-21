From: Kalle Valo <kvalo@kernel.org>
Subject: Re: [PATCH] treewide: Convert del_timer*() to timer_shutdown*()
Date: Wed, 21 Dec 2022 20:47:50 +0200
Message-ID: <87mt7gk2zt.fsf@kernel.org>
References: <20221220134519.3dd1318b@gandalf.local.home>
Mime-Version: 1.0
Return-path: <linux-acpi-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1671648479;
        bh=hTuIjHBHd+Tec1DAOqqIPFW5jFXlpQ7ZWnftXs2hg6Q=;
        h=From:To:Cc:Subject:References:Date:In-Reply-To:From;
        b=XiS53svtnGlZKUpJLWpjIb00pvlTavkGyE/yhXeS7hKFYS8V/5Xav/+mlpRGezW6h
         BljUFnHKQWw/igsJKn42+z68Zwy3Z5sPZrjhFME/Kwqkbwjx7njFSsJY/zjJWCYIs2
         hg7VB/Upxxl01DViL7TGCOLjNQW9ZDg1YFt1aai4iFOc2yVu8ujua8wy7VEyZXvui4
         /1bJ/zTi5VZkqa0c9me5b9nyIRR+8AGM7a6aXGScjL7jgysNOOGh6mrX4vs3UGAGXF
         1s0aX5L7Ze9A8zWY2oezGwBJF7QaIiwiLIJLyqjhe4qpPeepExO7oc4XqzOCONcDBc
         /pYLvZHxEpyuQ==
In-Reply-To: <20221220134519.3dd1318b@gandalf.local.home> (Steven Rostedt's
        message of "Tue, 20 Dec 2022 13:45:19 -0500")
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, Stephen Boyd <sboyd@kernel.org>, Guenter Roeck <linux@roeck-us.net>, Anna-Maria Gleixner <anna-maria@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Julia Lawall <Julia.Lawall@inria.fr>, linux-sh@vger.kernel.org, cgroups@vger.kernel.org, linux-block@vger.kernel.org, linux-acpi@vger.kernel.org, linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org, drbd-dev@lists.linbit.com, linux-bluetooth@vger.kernel.org, intel-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, linux-input@vger.kernel.org, linux-leds@vger.kernel.org, linux-media@vger.kernel.org, intel-wired-lan@lists.osuosl.org, linux-usb@vger.kernel.org, linux-wir

Steven Rostedt <rostedt@goodmis.org> writes:

> [
>   Linus,
>
>     I ran the script against your latest master branch:
>     commit b6bb9676f2165d518b35ba3bea5f1fcfc0d969bf
>
>     As the timer_shutdown*() code is now in your tree, I figured
>     we can start doing the conversions. At least add the trivial ones
>     now as Thomas suggested that this gets applied at the end of the
>     merge window, to avoid conflicts with linux-next during the
>     development cycle. I can wait to Friday to run it again, and
>     resubmit.
>
>     What is the best way to handle this?
> ]
>
> From: "Steven Rostedt (Google)" <rostedt@goodmis.org>
>
> Due to several bugs caused by timers being re-armed after they are
> shutdown and just before they are freed, a new state of timers was added
> called "shutdown". After a timer is set to this state, then it can no
> longer be re-armed.
>
> The following script was run to find all the trivial locations where
> del_timer() or del_timer_sync() is called in the same function that the
> object holding the timer is freed. It also ignores any locations where the
> timer->function is modified between the del_timer*() and the free(), as
> that is not considered a "trivial" case.
>
> This was created by using a coccinelle script and the following commands:
>
>  $ cat timer.cocci
> @@
> expression ptr, slab;
> identifier timer, rfield;
> @@
> (
> -       del_timer(&ptr->timer);
> +       timer_shutdown(&ptr->timer);
> |
> -       del_timer_sync(&ptr->timer);
> +       timer_shutdown_sync(&ptr->timer);
> )
>   ... when strict
>       when != ptr->timer
> (
>         kfree_rcu(ptr, rfield);
> |
>         kmem_cache_free(slab, ptr);
> |
>         kfree(ptr);
> )
>
>  $ spatch timer.cocci . > /tmp/t.patch
>  $ patch -p1 < /tmp/t.patch
>
> Link: https://lore.kernel.org/lkml/20221123201306.823305113@linutronix.de/
>
> Signed-off-by: Steven Rostedt (Google) <rostedt@goodmis.org>

For wireless:

>  .../broadcom/brcm80211/brcmfmac/btcoex.c         |  2 +-
>  drivers/net/wireless/intel/iwlwifi/iwl-dbg-tlv.c |  2 +-
>  drivers/net/wireless/intel/iwlwifi/mvm/sta.c     |  2 +-
>  drivers/net/wireless/intersil/hostap/hostap_ap.c |  2 +-
>  drivers/net/wireless/marvell/mwifiex/main.c      |  2 +-
>  drivers/net/wireless/microchip/wilc1000/hif.c    |  6 +++---

Acked-by: Kalle Valo <kvalo@kernel.org>

-- 
https://patchwork.kernel.org/project/linux-wireless/list/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
