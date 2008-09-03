From: Simon Horman <horms@verge.net.au>
Subject: Re: A one-liner ipvs patch
Date: Wed, 3 Sep 2008 18:47:48 +1000
Message-ID: <20080903084746.GB7748@verge.net.au>
References: <48BE49A3.9030201@p6drad-teel.net>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <48BE49A3.9030201@p6drad-teel.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Siim =?iso-8859-1?Q?P=F5der?= <siim@p6drad-teel.net>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org

On Wed, Sep 03, 2008 at 11:24:03AM +0300, Siim P=F5der wrote:
> Hi!
>=20
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

Hi Siim,

When trying to apply this I noticed that it has already been
included as "ipvs: Make wrr "no available servers" error message
rate-limited" by Sven Wegener, which was included in 2.6.25-rc1.

Thanks

