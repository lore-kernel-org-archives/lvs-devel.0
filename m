From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [GIT PULL] treewide: timers: Use timer_shutdown*() before
 freeing timers
Date: Mon, 07 Nov 2022 11:47:04 +0100
Message-ID: <87pmdzvy6v.ffs@tglx>
References: <20221106223256.4bbdb018@rorschach.local.home>
Mime-Version: 1.0
Return-path: <linux-acpi-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linutronix.de;
        s=2020; t=1667818024;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=qnhu/C4/dTNGh+9YxTAUPF0AHXOgpdZiA4TofS1TDao=;
        b=m8gFAB2FYV5B4BIkkbSCrPl5kngI1vwmC89wOqBJ/q73+RRLDUvN8153YBd0ancpYaUudU
        +fTzmJoLwRrrXw9ulhVtc41yRIMLNrOmB9kVLUOAn2xwOs861TQYPTmwfVqoXOpGOLsPn5
        hNBacxD9XN6Mi6tXS/NIbwjqzso2C6oqm6/L/mt2cpmfqfHELnCL8o8Pn38Ir7+eD8OVqk
        Lj3kRr5Ls1MIF7+wsJc3Ym/BQIZf8UhWrd8aE7FpoY/qhjIfIvELeoa8/ZXUqY5eKhjinO
        ZF4FT08X0F8jeyihKYji9kBCreFY8X9nEznXEcECfWmIcYVRm4zXH9JmYOmiiQ==
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=linutronix.de;
        s=2020e; t=1667818024;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=qnhu/C4/dTNGh+9YxTAUPF0AHXOgpdZiA4TofS1TDao=;
        b=bzVvnuX1mysTSSrkmkIGsLumN3FZV+biUwiIDeLZdScudMhEXojJ3c4U7ytkUdHNPdLCjD
        NbhAMzPLE4OU4lBA==
In-Reply-To: <20221106223256.4bbdb018@rorschach.local.home>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Stephen Boyd <sboyd@kernel.org>, Guenter Roeck <linux@roeck-us.net>, Anna-Maria Gleixner <anna-maria@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Julia Lawall <Julia.Lawall@inria.fr>, linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-block@vger.kernel.org, linux-acpi@vger.kernel.org, linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org, drbd-dev@lists.linbit.com, linux-bluetooth@vger.kernel.org, intel-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, linux-input@vger.kernel.org, linux-leds@vger.kernel.org, linux-media@vger.kernel.org, intel-wired-lan@lists.osuosl.org, linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org, linux-scsi@vger.kernel.org, linux-staging

Linus,

On Sun, Nov 06 2022 at 22:32, Steven Rostedt wrote:
> As discussed here:
>
>   https://lore.kernel.org/all/20221106212427.739928660@goodmis.org/

Please hold off. It's only nits, but tip has documented rules and random
pull requests are not making them go away.

Thanks,

        tglx
