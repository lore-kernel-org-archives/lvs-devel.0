From: Jason Stubbs <j.stubbs@linkthink.co.jp>
Subject: Re: [PATCH] Move IPVS from net/ipv4/ipvs to net/netfilter/ipvs in preparation for IPv6 support
Date: Fri, 9 May 2008 22:21:56 +0900
Message-ID: <200805092221.57251.j.stubbs@linkthink.co.jp>
References: <f4845fc0805070732v516fc8c6y2cdddfd4f99c8f96@mail.gmail.com> <f4845fc0805070851y7f1f00d0xd2dfcc7feb79c173@mail.gmail.com> <Pine.LNX.4.64.0805090536120.22107@wm7d.net>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0805090536120.22107@wm7d.net>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: lvs-devel@vger.kernel.org
Cc: netdev@vger.kernel.org

On Friday 09 May 2008 21:49:52 Joseph Mack NA3T wrote:
> On Wed, 7 May 2008, Julius Volz wrote:
>=20
> > Hm, ok. This patch doesn't touch any functionality though. It only
> > moves files from one directory to another, so it's merely cosmetics=
,
> > no IPv6 knowledge required.
>=20
> are you at a stage where it's all split up, after which=20
> you'll only be working on the ipv6 part and leaving the ipv4=20
> untouched? Have you tested the ipv4 part to make sure it's=20
> still OK. ie the code is reorthogonalised but with no change=20
> in functionality?

I haven't applied the patch and done a diff to individual files to be c=
ertain, but I'm pretty sure that the patch is mainly just a directory c=
hange. IPVS itself is already fairly well abstracted protocol-wise. Jus=
t another guess, but it sounds like Julius is submitting the patch as i=
t would make more meaty patches smaller.

> If so then this might be a good point to submit to the=20
> kernel. Also Jason might be interested in the new version of=20
> the code (hopefully working in different parts of the code,=20
> you two won't be having many collisions).

Call me crazy, but I plan to put my patch into production in two weeks =
time without the connect-to-vip-from-director parts. If everything goes=
 well, I'll post patches again with adequate comments (and adjustments =
to comments). And to make this relevant: My patches don't do anything p=
rotocol specific other than to change when things are done and so would=
 be fairly easy to update for IPV6 if/when it is integrated.

--=20
Jason Stubbs <j.stubbs@linkthink.co.jp>
LINKTHINK INC.
=E6=9D=B1=E4=BA=AC=E9=83=BD=E6=B8=8B=E8=B0=B7=E5=8C=BA=E6=A1=9C=E3=83=B6=
=E4=B8=98=E7=94=BA22-14 N.E.S S=E6=A3=9F 3F
TEL 03-5728-4772  FAX 03-5728-4773
