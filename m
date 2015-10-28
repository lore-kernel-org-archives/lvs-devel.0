From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH ipvsadm] ipvsadm: new attributes for sync daemon
Date: Wed, 28 Oct 2015 22:17:39 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1510282201130.1817@ja.home.ssi.bg>
References: <CA+J0kfzPaWPOJUiR_ob3ttZYm0ZKF69_dg5SqJ+VXu0nY0tFFg@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <CA+J0kfzPaWPOJUiR_ob3ttZYm0ZKF69_dg5SqJ+VXu0nY0tFFg@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Phillip Moore <pdm@pobox.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, lvs-users@linuxvirtualserver.org


	Hello,

On Tue, 27 Oct 2015, Phillip Moore wrote:

> Has a kernel patch to support this been released? I tried this just
> now and realized after it wasn't working that it must need kernel
> changes as well (which turns out is stated in the change). I
> specifically need the --mcast-group feature.

	The kernel patch is in the net tree and will
come with 4.3.

> I am looking to get this going now some how and hope I can some how
> get the changes back ported to my kernel or use a newer one.  I'm
> running 2.6.32-573.el6.x86_64

	You can extract the commits from git:

e0b26cc997d5 ("ipvs: call rtnl_lock early")
e4ff67513096 ("ipvs: add sync_maxlen parameter for the sync daemon")
d33288172e72 ("ipvs: add more mcast parameters for the sync daemon")

	But you have to pay attention with the first patch
where the rtnl_lock is moved.

Regards

--
Julian Anastasov <ja@ssi.bg>
