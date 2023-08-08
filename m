From: Joel Granados <joel.granados@gmail.com>
Subject: Re: [PATCH v2 11/14] networking: Update to
	register_net_sysctl_sz
Date: Tue, 8 Aug 2023 17:23:38 +0200
Message-ID: <20230808152338.aoubpvauxpcuwfuz@localhost>
References: <20230731071728.3493794-1-j.granados@samsung.com>
 <20230731071728.3493794-12-j.granados@samsung.com>
 <CGME20230808112110eucas1p1332795fa88d771ac3f05825f33052cf9@eucas1p1.samsung.com>
 <22e0e672-f9f6-6afe-6ce6-63de264e7b6d@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature"; boundary="ry2jlv6i2gzplzus"
Return-path: <bridge-bounces@lists.linux-foundation.org>
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp3.osuosl.org 380A16113D
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp3.osuosl.org 072B16115C
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp4.osuosl.org 086A9408F7
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp4.osuosl.org C02CF408E5
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20221208; t=1691508221; x=1692113021;
 h=in-reply-to:content-disposition:mime-version:references:message-id
 :subject:cc:to:from:date:from:to:cc:subject:date:message-id:reply-to;
 bh=EKR/mQxiWCp6UmZoc/ZIdm/CvMRbYORnLL2Bmf5WunY=;
 b=TpisWaFuryn84hwDAI/nJx1g/+I/Q+8Bt69v895SwG2nRTVcmTB+q0SVXuKBPt6N51
 Rawqjt70YhCPEkSJZgZEYAbNUFQJJ00JOBEmt6tfwvHqk2/lZxpGgZqkNjvHfZqtD1gc
 FoBqzgQdts3iSK8uQih1Lvlqx2zE2cS16XmH497VWVgDTVsUGwOCMiCxgCp0XiYw+voU
 WHEnerBT6CjafIFaZceFoB/6uMHODH8hOJTTqp4JluVt/b+MeOOAeby/zdkOwrRZTdGe
 /0E3RyvXAqo9LWHWpkyuizb1DiCOxlIC01izr+IXJw1F0ZscKunSYNeKa+Cbj7brfXid
 C1nA==
Content-Disposition: inline
In-Reply-To: <22e0e672-f9f6-6afe-6ce6-63de264e7b6d@intel.com>
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
To: Przemek Kitszel <przemyslaw.kitszel@intel.com>
Cc: Wen Gu <guwen@linux.alibaba.com>, Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>, Pablo Neira Ayuso <pablo@netfilter.org>, Catalin Marinas <catalin.marinas@arm.com>, Nikolay Aleksandrov <razor@blackwall.org>, Alexander Aring <alex.aring@gmail.com>, linux-sctp@vger.kernel.org, Miquel Raynal <miquel.raynal@bootlin.com>, Jan Karcher <jaka@linux.ibm.com>, Mat Martineau <martineau@kernel.org>, Will Deacon <will@kernel.org>, Alexander Gordeev <agordeev@linux.ibm.com>, Stefan Schmidt <stefan@datenfreihafen.org>, Steffen Klassert <steffen.klassert@secunet.com>, linux-s390@vger.kernel.org, rds-devel@oss.oracle.com, Xin Long <lucien.xin@gmail.com>, Herbert Xu <herbert@gondor.apana.org.au>, linux-rdma@vger.kernel.org, Tony Lu <tonylu@linux.alibaba.com>, bridge@lists.linux-foundation.org, willy@infradead.org, Jozsef Kadlecsik <kadlec@netfilter.org>, lvs-devel@vger.kernel.org


--ry2jlv6i2gzplzus
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Aug 08, 2023 at 01:20:36PM +0200, Przemek Kitszel wrote:
> On 7/31/23 09:17, Joel Granados wrote:
> > Move from register_net_sysctl to register_net_sysctl_sz for all the
> > networking related files. Do this while making sure to mirror the NULL
> > assignments with a table_size of zero for the unprivileged users.
> >=20
> > We need to move to the new function in preparation for when we change
> > SIZE_MAX to ARRAY_SIZE() in the register_net_sysctl macro. Failing to do
> > so would erroneously allow ARRAY_SIZE() to be called on a pointer. We
> > hold off the SIZE_MAX to ARRAY_SIZE change until we have migrated all
> > the relevant net sysctl registering functions to register_net_sysctl_sz
> > in subsequent commits.
> >=20
> > An additional size function was added to the following files in order to
> > calculate the size of an array that is defined in another file:
> >      include/net/ipv6.h
> >      net/ipv6/icmp.c
> >      net/ipv6/route.c

=2E..

> > diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> > index 64e873f5895f..51c6cdae8723 100644
> > --- a/net/ipv6/route.c
> > +++ b/net/ipv6/route.c
> > @@ -6447,14 +6447,19 @@ struct ctl_table * __net_init ipv6_route_sysctl=
_init(struct net *net)
> >   		table[8].data =3D &net->ipv6.sysctl.ip6_rt_min_advmss;
> >   		table[9].data =3D &net->ipv6.sysctl.ip6_rt_gc_min_interval;
> >   		table[10].data =3D &net->ipv6.sysctl.skip_notify_on_dev_down;
> > -
> > -		/* Don't export sysctls to unprivileged users */
> > -		if (net->user_ns !=3D &init_user_ns)
> > -			table[1].procname =3D NULL;
Here I remove the setting of the procname to NULL for ipv6 sysctl
registers in route.c and I do not replace that assignment anywhere.
This means that we will export sysctls to unprivilged users for ipv6.
I'll correct this in V3.

> >   	}
> >   	return table;
> >   }
> > +
> > +size_t ipv6_route_sysctl_table_size(struct net *net)
> > +{
> > +	/* Don't export sysctls to unprivileged users */
> > +	if (net->user_ns !=3D &init_user_ns)
> > +		return 0;
> > +
> > +	return ARRAY_SIZE(ipv6_route_table_template);
> > +}
> >   #endif
> >   static int __net_init ip6_route_net_init(struct net *net)

--=20

Joel Granados

--ry2jlv6i2gzplzus
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQGzBAABCgAdFiEErkcJVyXmMSXOyyeQupfNUreWQU8FAmTSXfgACgkQupfNUreW
QU9uhwv/YNoyTbkHH/5RMLpQdKDepd7w6f8Rtax3cD35VYfVbj2aNFy9lcELq0sL
WWEkcnq1tZav3I+it4as5M7BUfGePS1Zj/D2OYSS7sR0ehwJMaO19qvfuGLiQLP9
XQe6cyy071sk9U5fxmpZkZgfKtldzchYMt1GluPzw0/a1CRkUlQqaDkHS0/hiOAn
JCY8mDLWC5DZwVZjz1Ai3UZ3lSIoxFqZbIk8IWpB6E6r9j+ulQUBw6CnYpSu8HMg
JNHA2wqyYaNLKxwQzSDhG3E0AaK59dPzneyrLVRnpJhc4yMFY+yDSPAzAZTgr1Ny
+/lASH2c7d0obmafitPwIOhxg7xPPnp+AYKDP65ZMGp0olUCNYKqUhF0Mc8sWq75
1kzOSul2jqUCTCkODYWut1aoqApizX5phuRCj/wCorVWBazLV7J9fDNopmAtmTYY
MKPmbbgWQdQHKDCEN7aSL5GGY51bp1dl4M0G+rkmW3RXRPl1OJLTsxP6Vk7ZizpE
4CYHvD9R
=8NUh
-----END PGP SIGNATURE-----

--ry2jlv6i2gzplzus--
