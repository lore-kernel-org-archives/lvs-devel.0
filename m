From: Simon Horman <horms@verge.net.au>
Subject: Re: ipvs oops in 3.0-rc7
Date: Fri, 22 Jul 2011 09:08:05 +0900
Message-ID: <20110722000805.GB31867@verge.net.au>
References: <20110720205019.9dfa30c3.rdunlap@xenotime.net>
 <alpine.LFD.2.00.1107211202380.1660@ja.ssi.bg>
 <CA+v9cxbhpt3LSZ_m+OA_Kujt79mvDZ7VnGqjbbPQxS_gY6+pTA@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+v9cxbhpt3LSZ_m+OA_Kujt79mvDZ7VnGqjbbPQxS_gY6+pTA@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Huajun Li <huajun.li.lee@gmail.com>
Cc: Julian Anastasov <ja@ssi.bg>, Randy Dunlap <rdunlap@xenotime.net>, netdev <netdev@vger.kernel.org>, lvs-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>

On Thu, Jul 21, 2011 at 09:37:29PM +0800, Huajun Li wrote:
> 2011/7/21 Julian Anastasov <ja@ssi.bg>:
> >
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0Hello,
> >
> > On Wed, 20 Jul 2011, Randy Dunlap wrote:
> >
> >> I'm seeing the following Oops in 3.0-rc7 on x86_64, just loading a=
nd unloading
> >> modules. =C2=A0Any chance this is already fixed? =C2=A0I can test =
current git, but I
> >> wanted to ask first.
> >>
> >> Looks like it is on the second module load of ip_vs (i.e.,
> >> modprobe ip_vs; rmmod ip_vs; modprobe ip_vs).
> >
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0I think, this problem was fixed by this =
patch:
> >
> > http://www.spinics.net/lists/lvs-devel/msg02051.html
> >
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0But it seems it was lost somewhere ...
> >
>=20
> That's great, SB. can help to apply it again, thanks.

Sorry about that. For some reason I thought that would be / had been
picked up. I'll send a pull request ASAP.
