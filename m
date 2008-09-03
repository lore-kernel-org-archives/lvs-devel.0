From: =?ISO-8859-1?Q?Siim_P=F5der?= <siim@p6drad-teel.net>
Subject: Re: A one-liner ipvs patch
Date: Wed, 03 Sep 2008 12:02:43 +0300
Message-ID: <48BE52B3.3090100@p6drad-teel.net>
References: <48BE49A3.9030201@p6drad-teel.net>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <48BE49A3.9030201@p6drad-teel.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org

Siim P=F5der wrote:
> I have a few very high connection rate services behind LVS and when
> keepalived removes them because of problems, the LVS would be reboote=
d
> with tens of thousands of this message in the logs (rebooted by hardw=
are
> watchdogs).
>=20
> I have had it running on production systems for maybe 3 months or so =
and
> this problem hasn't occured any more, which does not prove that the
> patch isn't just curing a symptom, but I think it is concievable, tha=
t a
> lot of printks could hang a system.

sorry, this has been fixed in 2.6.25 already.

Siim
