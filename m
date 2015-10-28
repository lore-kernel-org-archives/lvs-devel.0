From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH ipvsadm] ipvsadm: new attributes for sync daemon
Date: Wed, 28 Oct 2015 20:40:36 +0100
Message-ID: <20151028204036.13dde07b@redhat.com>
References: <CA+J0kfzPaWPOJUiR_ob3ttZYm0ZKF69_dg5SqJ+VXu0nY0tFFg@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <CA+J0kfzPaWPOJUiR_ob3ttZYm0ZKF69_dg5SqJ+VXu0nY0tFFg@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Phillip Moore <pdm@pobox.com>
Cc: Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, lvs-users@linuxvirtualserver.org, brouer@redhat.com


On Tue, 27 Oct 2015 11:32:19 -0500 Phillip Moore <pdm@pobox.com> wrote:

> Has a kernel patch to support this been released? I tried this just
> now and realized after it wasn't working that it must need kernel
> changes as well (which turns out is stated in the change). I
> specifically need the --mcast-group feature.

Hmm, I took this patch for the userspace ipvsadm tool, but I wonder if
the kernel change every got merged?  That is Simon's area... ?!?

 https://git.kernel.org/cgit/utils/kernel/ipvsadm/ipvsadm.git/commit/?id=ce615000479898

But I didn't cut a release with it, thus you need to use the git repo
version if ipvsadm to test this:

 git://git.kernel.org/pub/scm/utils/kernel/ipvsadm/ipvsadm.git

> I am looking to get this going now some how and hope I can some how
> get the changes back ported to my kernel or use a newer one.  I'm
> running 2.6.32-573.el6.x86_64

Well, that is a RHEL6 kernel, I know that change have not been
backported... you have to open a case with Red Hat if you really need
that change in a RHEL kernel.

 
> On Sun, Jul 26, 2015 at 7:12 AM, Julian Anastasov <ja@ssi.bg> wrote:
> > Add support for --sync-maxlen, --mcast-group, --mcast-port and
> > --mcast-ttl options for the --start-daemon command.
> >
> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> > ---
> [...]

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
