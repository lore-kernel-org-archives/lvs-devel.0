From: Joel Granados <joel.granados@gmail.com>
Subject: Re: [PATCH v2 00/14] sysctl: Add a size argument to
 register functions in sysctl
Date: Tue, 1 Aug 2023 11:35:55 +0200
Message-ID: <20230801093555.wwl27a7wjm2oinxx@localhost>
References: <20230731071728.3493794-1-j.granados@samsung.com>
 <CGME20230731213734eucas1p2728233a3b9ecd360bbd0cb77f8a44002@eucas1p2.samsung.com>
 <ZMgpck0rjqHR74sl@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature"; boundary="ltg4mtomzaz4i2ki"
Return-path: <bridge-bounces@lists.linux-foundation.org>
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp1.osuosl.org 1AFBB814A0
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp1.osuosl.org E942381492
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp3.osuosl.org E3820607E1
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp3.osuosl.org 25A3560739
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20221208; t=1690882558; x=1691487358;
 h=in-reply-to:content-disposition:mime-version:references:message-id
 :subject:cc:to:from:date:from:to:cc:subject:date:message-id:reply-to;
 bh=VvT5J/1PJpb72S8f2nh5awbFCHxyuUpdf923ik/K8j4=;
 b=ExXgh7eFyYEhKQs65FHri/ViJcpb8MfKCX9kbY13ZsJxBfJuzrlXbGUOa6PJHRnfVL
 5KktONa25XH2j439bmJpT0Q4yTjYmX4D0DiBC4baDGrA30FHudWESCVxKcX9ypBipHeM
 SQep1J2NOOI4y6MR1DOFPz5PzuY+E3qQVzADtwAIobtemnENQgZGsUJnpi/joyh4WivY
 LIlCKOUJEek89CNVl+TOnj477K/qps7R9Z8rmn8+cL4kkeZWcXXI6KXXgTaf/3PYTlrh
 pg5N0MEigdMBUTHFqQA2OwiMPdbJ/RuZNlJ9em5VweXgkSGFnwmWM0zlA01zCeSuodhm
 IVHw==
Content-Disposition: inline
In-Reply-To: <ZMgpck0rjqHR74sl@bombadil.infradead.org>
List-Id: <lvs-devel.vger.kernel.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>, 
 <mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
 <mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Errors-To: bridge-bounces@lists.linux-foundation.org
Sender: "Bridge" <bridge-bounces@lists.linux-foundation.org>
To: Luis Chamberlain <mcgrof@kernel.org>
Cc: Wen Gu <guwen@linux.alibaba.com>, Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>, Pablo Neira Ayuso <pablo@netfilter.org>, Catalin Marinas <catalin.marinas@arm.com>, Nikolay Aleksandrov <razor@blackwall.org>, Alexander Aring <alex.aring@gmail.com>, linux-sctp@vger.kernel.org, Miquel Raynal <miquel.raynal@bootlin.com>, Jan Karcher <jaka@linux.ibm.com>, Mat Martineau <martineau@kernel.org>, Will Deacon <will@kernel.org>, Alexander Gordeev <agordeev@linux.ibm.com>, Stefan Schmidt <stefan@datenfreihafen.org>, Steffen Klassert <steffen.klassert@secunet.com>, linux-s390@vger.kernel.org, rds-devel@oss.oracle.com, Xin Long <lucien.xin@gmail.com>, Herbert Xu <herbert@gondor.apana.org.au>, linux-rdma@vger.kernel.org, Tony Lu <tonylu@linux.alibaba.com>, bridge@lists.linux-foundation.org, willy@infradead.org, Jozsef Kadlecsik <kadlec@netfilter.org>, lvs-devel@vger.kernel.org


--ltg4mtomzaz4i2ki
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jul 31, 2023 at 02:36:50PM -0700, Luis Chamberlain wrote:
> > Joel Granados (14):
> >   sysctl: Prefer ctl_table_header in proc_sysctl
> >   sysctl: Use ctl_table_header in list_for_each_table_entry
> >   sysctl: Add ctl_table_size to ctl_table_header
> >   sysctl: Add size argument to init_header
> >   sysctl: Add a size arg to __register_sysctl_table
> >   sysctl: Add size to register_sysctl
> >   sysctl: Add size arg to __register_sysctl_init
>=20
> This is looking great thanks, I've taken the first 7 patches above
> to sysctl-next to get more exposure / testing and since we're already
> on rc4.
Thx for the feedback.

>=20
> Since the below patches involve more networking I'll wait to get
> more feedback from networking folks before merging them.
Just FYI, these are all networking except for the last one. That one is
actually just in sysctl and will set everything up for removing the
sentinels.

>=20
> >   sysctl: Add size to register_net_sysctl function
> >   ax.25: Update to register_net_sysctl_sz
> >   netfilter: Update to register_net_sysctl_sz
> >   networking: Update to register_net_sysctl_sz
> >   vrf: Update to register_net_sysctl_sz
> >   sysctl: SIZE_MAX->ARRAY_SIZE in register_net_sysctl
> >   sysctl: Use ctl_table_size as stopping criteria for list macro
>=20
>   Luis

--=20

Joel Granados

--ltg4mtomzaz4i2ki
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQGyBAABCgAdFiEErkcJVyXmMSXOyyeQupfNUreWQU8FAmTI0fkACgkQupfNUreW
QU/TKwv3ZwfCMFKh+tMOXHzAsW3p+jp8IR2frQvlCy8j4amsnTB8wJmsjkpeuJ3p
s6IFeYrPE0pDidKOwzYiA4JDZdYDgF1hevrQAuqDsLkKBHzW0Cr6dt21CIQx9uZR
RwhONU/JHoW6MKmO2PlcOiSQiRAhX/OvUhtCgQPTbff3fT6EAu9twn0vfWcyy+H0
mn6LM2go/DW2cgdm4oa1U+DqwpJiGCabLbQNfPa8Vx8g7CK2y2Azd5/obW6ryOxe
QDPdmQdVjytDnDHSW2AEYe2bDympPHaaoDU79e4FPVXC15+UAgF+/ExfDUVq6ek4
FG5Gjh7ev+i6vPYAUR4AuPtB3hwH+vDsSE6Vcd37iKn/mjg1fi0DHx7Wz1Be/n1o
8iSbL0N6an0fzzKlOdfwQs1bytw+ssWZtxLIQ3MUhHvwj882OXkYCBRW4Aycgop7
/H+zOm0K2Yluph2h+5qmhjkzUlTx2MNwfSs34wsvBNsbb1MGZQouIAAQowb+mTzS
31kDDA8=
=shIJ
-----END PGP SIGNATURE-----

--ltg4mtomzaz4i2ki--
