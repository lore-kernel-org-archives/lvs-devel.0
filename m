From: Phillip Moore <pdm@pobox.com>
Subject: Re: [PATCH ipvsadm] ipvsadm: new attributes for sync
	daemon
Date: Tue, 27 Oct 2015 11:32:19 -0500
Message-ID: <CA+J0kfzPaWPOJUiR_ob3ttZYm0ZKF69_dg5SqJ+VXu0nY0tFFg@mail.gmail.com>
Reply-To: "LinuxVirtualServer.org users mailing list."
	<lvs-users@linuxvirtualserver.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <lvs-users-bounces+gcll-lvs-users=m.gmane.org@linuxvirtualserver.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed; d=pobox.com; h=mime-version
	:date:message-id:subject:from:to:cc:content-type; s=sasl; bh=Y4o
	ZXLOCi6JOZuP4BjSO3qfQV/Q=; b=g5mBHmgjI1f/wItlwWFGw99titUnVncuo/H
	pQapfxEcxSZJCoQxhlfAVZ3B5vDNKv33JdZ2xp3hNjDZKq8VvKB0ZlWS3obsbDLv
	g8kP9rPHrro3NEFX80NXo8TuSwS5TOoF6UiGk2LarUPjtPt1ashEjtaVm5O+l3VG
	p3AVbvGQ=
List-Id: <lvs-devel.vger.kernel.org>
List-Unsubscribe: <http://lists.graemef.net/mailman/listinfo/lvs-users>,
	<mailto:lvs-users-request@linuxvirtualserver.org?subject=unsubscribe>
List-Archive: <http://lists.graemef.net/pipermail/lvs-users>
List-Post: <mailto:lvs-users@linuxvirtualserver.org>
List-Help: <mailto:lvs-users-request@linuxvirtualserver.org?subject=help>
List-Subscribe: <http://lists.graemef.net/mailman/listinfo/lvs-users>,
	<mailto:lvs-users-request@linuxvirtualserver.org?subject=subscribe>
Sender: lvs-users-bounces@linuxvirtualserver.org
Errors-To: lvs-users-bounces+gcll-lvs-users=m.gmane.org@linuxvirtualserver.org
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, lvs-users@linuxvirtualserver.org, Simon Horman <horms@verge.net.au>, Jesper Dangaard Brouer <brouer@redhat.com>

Has a kernel patch to support this been released? I tried this just
now and realized after it wasn't working that it must need kernel
changes as well (which turns out is stated in the change). I
specifically need the --mcast-group feature.

I am looking to get this going now some how and hope I can some how
get the changes back ported to my kernel or use a newer one.  I'm
running 2.6.32-573.el6.x86_64

Thanks,
Phillip Moore

On Sun, Jul 26, 2015 at 7:12 AM, Julian Anastasov <ja@ssi.bg> wrote:
> Add support for --sync-maxlen, --mcast-group, --mcast-port and
> --mcast-ttl options for the --start-daemon command.
>
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
...
