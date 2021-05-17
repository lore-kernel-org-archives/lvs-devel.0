From: Juerg Haefliger <juerg.haefliger@canonical.com>
Subject: Re: [PATCH] treewide: Remove leading spaces in Kconfig files
Date: Mon, 17 May 2021 10:29:15 +0200
Message-ID: <20210517102915.072b8665@gollum>
References: <20210516132209.59229-1-juergh@canonical.com>
        <YKIDJIfuufBrTQ4f@kroah.com>
        <CAB2i3ZgszsUVDuK2fkUXtD72tPSgrycnDawM4VAuGGPJiA9+cA@mail.gmail.com>
        <YKImotylLR7D4mQW@kroah.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="Sig_/D7AKy83dA=gk+i5Iqn9=k5c";
 protocol="application/pgp-signature"; micalg=pgp-sha512
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <YKImotylLR7D4mQW@kroah.com>
List-ID: <lvs-devel.vger.kernel.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: Juerg Haefliger <juerg.haefliger@canonical.com>, aaro.koskinen@iki.fi, tony@atomide.com, linux@prisktech.co.nz, David Miller <davem@davemloft.net>, kuba@kernel.org, jejb@linux.ibm.com, martin.petersen@oracle.com, Lee Jones <lee.jones@linaro.org>, Daniel Thompson <daniel.thompson@linaro.org>, jingoohan1@gmail.com, mst@redhat.com, jasowang@redhat.com, zbr@ioremap.net, pablo@netfilter.org, kadlec@netfilter.org, fw@strlen.de, horms@verge.net.au, ja@ssi.bg, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-crypto@vger.kernel.org, linux-usb@vger.kernel.org, netdev <netdev@vger.kernel.org>, linux-scsi@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-fbdev@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, netfilt

--Sig_/D7AKy83dA=gk+i5Iqn9=k5c
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 17 May 2021 10:17:38 +0200
Greg KH <gregkh@linuxfoundation.org> wrote:

> On Mon, May 17, 2021 at 10:07:43AM +0200, Juerg Haefliger wrote:
> > On Mon, May 17, 2021 at 7:46 AM Greg KH <gregkh@linuxfoundation.org> wr=
ote: =20
> > >
> > > On Sun, May 16, 2021 at 03:22:09PM +0200, Juerg Haefliger wrote: =20
> > > > There are a few occurences of leading spaces before tabs in a coupl=
e of
> > > > Kconfig files. Remove them by running the following command:
> > > >
> > > >   $ find . -name 'Kconfig*' | xargs sed -r -i 's/^[ ]+\t/\t/'
> > > >
> > > > Signed-off-by: Juerg Haefliger <juergh@canonical.com>
> > > > ---
> > > >  arch/arm/mach-omap1/Kconfig     | 12 ++++++------
> > > >  arch/arm/mach-vt8500/Kconfig    |  6 +++---
> > > >  arch/arm/mm/Kconfig             | 10 +++++-----
> > > >  drivers/char/hw_random/Kconfig  |  8 ++++----
> > > >  drivers/net/usb/Kconfig         | 10 +++++-----
> > > >  drivers/net/wan/Kconfig         |  4 ++--
> > > >  drivers/scsi/Kconfig            |  2 +-
> > > >  drivers/uio/Kconfig             |  2 +-
> > > >  drivers/video/backlight/Kconfig | 10 +++++-----
> > > >  drivers/virtio/Kconfig          |  2 +-
> > > >  drivers/w1/masters/Kconfig      |  6 +++---
> > > >  fs/proc/Kconfig                 |  4 ++--
> > > >  init/Kconfig                    |  2 +-
> > > >  net/netfilter/Kconfig           |  2 +-
> > > >  net/netfilter/ipvs/Kconfig      |  2 +-
> > > >  15 files changed, 41 insertions(+), 41 deletions(-) =20
> > >
> > > Please break this up into one patch per subsystem and resend to the
> > > proper maintainers that way. =20
> >=20
> > Hmm... How is my patch different from other treewide Kconfig cleanup
> > patches like:
> > a7f7f6248d97 ("treewide: replace '---help---' in Kconfig files with 'he=
lp'")
> > 8636a1f9677d ("treewide: surround Kconfig file paths with double quotes=
")
> > 83fc61a563cb ("treewide: Fix typos in Kconfig")
> > 769a12a9c760 ("treewide: Kconfig: fix wording / spelling")
> > f54619f28fb6 ("treewide: Fix typos in Kconfig") =20
>=20
> Ok, I'll just ignore this and not try to suggest a way for you to get
> your change accepted...

No worries. I can make the change, was just wondering...

...Juerg
=20
> greg k-h


--Sig_/D7AKy83dA=gk+i5Iqn9=k5c
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCgAdFiEEhZfU96IuprviLdeLD9OLCQumQrcFAmCiKVsACgkQD9OLCQum
QrePLw//Ykimz2jPT7e6QtcgGI7q3Z9YELDFMiqk+ujC4vzVJBFi+WZekZa+tti2
7T5x1ci+i2mPSr/sNSIuKfQcvBH7SBdcckdjSdD55wGKV7GWUMNDkJR1x7aW5Pzo
eEhHCY0hTkEq76S1wegRvD2HxXpsW4aH6rZjB/uNo9V/lRaJJNuouXrxs1zI/6zr
UtYRTLVqVCsTxv0C+XF/C0T+gdbhYaU/68B/+zUSLVo83JQBo9rXrPfNmRWGo5hO
SnFkkcfMuosZZ9RQqmpdR1y4D+1x7OrROghRJT8gy9LBF5c/0yTimblVifcoNXi0
fUZmNRzYvteApmm8m0SBbOEE3mHiKDVIJ7MHDdjtPweaNNJrH+CkXztENtzb+AJr
h6hlvQklXSI2/h+PaCLMPGxUnYDj5xhXVWwmiIy/0Hk466jeuPz4od5EQSe607ZB
dw8oX5/MCHtJhdsgSUB3BHiwWPD7zBuUouHOBGsyFJBsCFcU5MIiQVFe2fiNRbkA
nlmkOuBT2+LKK+2AU/nQ1IGkcP1b8a3Az8g6+ywxyjMHv1+7FafEMrFgJUGIeXNl
z80JfoWhqqI4UcRltEhJE44NfdVqDqHMomAwI2qHuSSZAWLKEjIPQkFtDlWDAlB4
d2q4e+YbdD1XE5/fFDYMOvZk31+d9GLtO0SQeZyuQo8r3MAkpR0=
=CrpS
-----END PGP SIGNATURE-----

--Sig_/D7AKy83dA=gk+i5Iqn9=k5c--
