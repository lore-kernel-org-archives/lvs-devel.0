From: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Subject: Re: [RFC][PATCH v2 19/31] timers: net: Use del_timer_shutdown()
 before freeing timer
Date: Thu, 27 Oct 2022 18:35:11 -0400
Message-ID: <20221027183511.66b058c4@gandalf.local.home>
References: <20221027150525.753064657@goodmis.org>
        <20221027150928.780676863@goodmis.org>
        <20221027155513.60b211e2@gandalf.local.home>
        <CAHk-=wjAjW2P5To82+CAM0Rx8RexQBHPTVZBWBPHyEPGm37oFA@mail.gmail.com>
        <20221027163453.383bbf8e@gandalf.local.home>
        <CAHk-=whoS+krLU7JNe=hMp2VOcwdcCdTXhdV8qqKoViwzzJWfA@mail.gmail.com>
        <20221027170720.31497319@gandalf.local.home>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20221027170720.31497319-f9ZlEuEWxVcJvu8Pb33WZ0EMvNT87kid@public.gmane.org>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Stephen Boyd <sboyd-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>, Jesse Brandeburg <jesse.brandeburg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Tony Nguyen <anthony.l.nguyen-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Jakub Kicinski <kuba-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Mirko Lindner <mlindner-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>, Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>, Martin KaFai Lau <martin.lau-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Kuniyuki Iwashima <kuniyu-vV1OtcyAfmbQT0dZR+AlfA@public.gmane.org>, Pavel Begunkov <asml.silence-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Menglong Dong <imagedong-1Nz4purKYjRBDgjK7y7TUQ@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bridge-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netfilter-de

On Thu, 27 Oct 2022 17:07:20 -0400
Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org> wrote:

> Well, I think this current use case will break if we prevent the timer from
> being rearmed or run again if it's not found. But as you said, the
> networking folks need to confirm or deny it.
> 
> The fact that it does the sock_put() when it removes the timer makes me
> think that it can be called again, and we shouldn't prevent that from
> happening.
> 
> The debug code will let us know too, as it only "frees" it for freeing if
> it deactivated the timer and shut it down.

I think we have our answer from Guenter's report:


Linux version 6.1.0-rc2-00138-gced58c742836 (groeck@jupiter) (aarch64-linux-gcc (GCC) 11.3.0, GNU ld (GNU Binutils) 2.39) #1 SMP PREEMPT Thu Oct 27 14:53:17 PDT 2022
[   17.258727] ------------[ cut here ]------------
[   17.259079] ODEBUG: free active (active state 0) object type: timer_list hint: tcp_write_timer+0x0/0x190
[   17.259723] WARNING: CPU: 0 PID: 309 at lib/debugobjects.c:502 debug_print_object+0xb8/0x100
[   17.259951] Modules linked in:
[   17.260249] CPU: 0 PID: 309 Comm: telnet Tainted: G                 N 6.1.0-rc2-00138-gced58c742836 #1
[   17.260518] Hardware name: linux,dummy-virt (DT)
[   17.260779] pstate: 60000005 (nZCv daif -PAN -UAO -TCO -DIT -SSBS BTYPE=--)
[   17.260967] pc : debug_print_object+0xb8/0x100
[   17.261096] lr : debug_print_object+0xb8/0x100
[   17.261223] sp : ffff8000086539e0
[   17.261324] x29: ffff8000086539e0 x28: 0000000000000004 x27: ffff0d2ac2168000
[   17.261574] x26: 0000000000000000 x25: ffffa241e2b9de18 x24: ffffa241e4f8fcd8
[   17.261772] x23: ffffa241e336b370 x22: ffffa241e2b9de18 x21: ffff0d2ac20c5710
[   17.261967] x20: ffffa241e4ea2568 x19: ffffa241e3ea3c00 x18: 00000000ffffffff
[   17.262161] x17: 6c6973742068696e x16: 3a2074696d65725f x15: 6563742074797065
[   17.262375] x14: 65203029206f626a x13: ffffa241e3ec7640 x12: 0000000000000d50
[   17.262591] x11: 0000000000000470 x10: ffffa241e3f1f640 x9 : ffffa241e3ec7640
[   17.262821] x8 : 00000000ffffefff x7 : ffffa241e3f1f640 x6 : 0000000000000000
[   17.263028] x5 : ffff0d2adfebba68 x4 : 0000000000000000 x3 : 0000000000000027
[   17.263235] x2 : 0000000000000000 x1 : 0000000000000000 x0 : ffff0d2ac658b340
[   17.263528] Call trace:
[   17.263646]  debug_print_object+0xb8/0x100
[   17.263795]  __debug_check_no_obj_freed+0x1d0/0x25c
[   17.263927]  debug_check_no_obj_freed+0x20/0x90
[   17.264051]  slab_free_freelist_hook.constprop.0+0xac/0x1b0
[   17.264197]  kmem_cache_free+0x1ac/0x500
[   17.264311]  __sk_destruct+0x140/0x2a0
[   17.264425]  sk_destruct+0x54/0x64
[   17.264531]  __sk_free+0x74/0x120
[   17.264636]  sk_free+0x64/0x8c
[   17.264736]  tcp_close+0x94/0xc0
[   17.264840]  inet_release+0x50/0xb0
[   17.264949]  __sock_release+0x44/0xbc
[   17.265061]  sock_close+0x18/0x30
[   17.265166]  __fput+0x84/0x270
[   17.265266]  ____fput+0x10/0x20
[   17.265366]  task_work_run+0x88/0xf0
[   17.265491]  do_exit+0x334/0xafc
[   17.265596]  do_group_exit+0x34/0x90
[   17.265705]  __arm64_sys_exit_group+0x18/0x20
[   17.265826]  invoke_syscall+0x48/0x114
[   17.265941]  el0_svc_common.constprop.0+0x60/0x11c
[   17.266070]  do_el0_svc+0x30/0xd0
[   17.266175]  el0_svc+0x48/0xc0
[   17.266276]  el0t_64_sync_handler+0xbc/0x13c
[   17.266396]  el0t_64_sync+0x18c/0x190
[   17.266565] irq event stamp: 5192
[   17.266676] hardirqs last  enabled at (5191): [<ffffa241e1926a18>] __up_console_sem+0x78/0x84
[   17.266903] hardirqs last disabled at (5192): [<ffffa241e2b4d504>] el1_dbg+0x24/0x90
[   17.267093] softirqs last  enabled at (5170): [<ffffa241e181050c>] __do_softirq+0x46c/0x5d8
[   17.267305] softirqs last disabled at (5163): [<ffffa241e1816750>] ____do_softirq+0x10/0x20
[   17.267506] ---[ end trace 0000000000000000 ]---
[   17.275715] ------------[ cut here ]------------

I'll go modify that code to make it shutdown even if it returns zero.

I thinks this means we'll need to change the name to:

 del_timer_shutdown()
 del_timer_shutdown_sync()

But I want to confirm this first.

-- Steve


