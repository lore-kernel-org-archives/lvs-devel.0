From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [lvs-users] [PATCH] ipvsadm: add SCTP support
Date: Fri, 6 Feb 2015 00:25:14 +0100
Message-ID: <20150206002514.1ee92144@redhat.com>
References: <1422693668-25736-1-git-send-email-ja@ssi.bg>
	<trinity-52eb73c8-bae2-44a8-acf1-b85fa331b003-1423169712697@3capp-webde-bs38>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <trinity-52eb73c8-bae2-44a8-acf1-b85fa331b003-1423169712697@3capp-webde-bs38>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: support@remsnet.de
Cc: lvs-users@linuxvirtualserver.org, formorer@debian.org, logan@ubuntu.com, mt@suse.de, lvs-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>, overcastsky.zhao@gmail.com, brouer@redhat.com, Ryan O'Hara <rohara@redhat.com>


On Thu, 5 Feb 2015 21:55:12 +0100 support@remsnet.de wrote:

> Dear Julian & Simon ,
>=20
> Please Include this "ipvsadm: add SCTP support" patch and any outstan=
ing patches=20
> at the  https://git.kernel.org/cgit/utils/kernel/ipvsadm/ipvsadm.git =
=2E

Sure, I'll take care of applying this. (I currently don't have access
to my lab due to traveling, thus I assume/trust Julian tested this).

> Please Simon ;
> It's time for new release of ipvsadm .. 2 years passed allready with
> an few important patches added to ipvsadm 1.27.

I'll prepare for a new release then...

> I can=C2=B4t understand why Debian , Suse , FC / Redhat  and it=C2=B4=
s clones
> Distrubtions still publish the buggy ipvsadm 1.26 .

AFAIKR the RHEL/CentOS version does contain the important fixes
backported (as it was done before 1.27 was released).

> Today faced again issue on very Highly traffik PRODUCTIVE shop site
> with Debian 7.8 with IPVS, keepalived and outdated ipvsadm due that
> - caused an Customer emergency Firecall ..
>=20
> Please please dear Distribution Maintainers -  UPDATE from the
> Offial  ipvsadm GIT repro . Thanks.

Thanks for expressing your interest in the project, it is nice to know
that some is actually using and depending on this work :-)

--=20
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
