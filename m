From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: [PATCH net-next] ipvs: provide iph to schedulers
Date: Sun, 16 Jun 2013 11:23:30 +0200
Message-ID: <1371374610.3718.277.camel@hawk.mlab.se>
References: <1371362976-5665-1-git-send-email-ja@ssi.bg>
Reply-To: hans@schillstrom.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="sha1"; protocol="application/x-pkcs7-signature";
	boundary="=-V6iMlC9OgkJ25NWSqiqE"
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1371362976-5665-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, Alexander Frolkin <avf@eldamar.org.uk>


--=-V6iMlC9OgkJ25NWSqiqE
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: quoted-printable



On Sun, 2013-06-16 at 09:09 +0300, Julian Anastasov wrote:
> Before now the schedulers needed access only to IP
> addresses and it was easy to get them from skb by
> using ip_vs_fill_iph_addr_only.
>=20
> New changes for the SH scheduler will need the protocol
> and ports which is difficult to get from skb for the
> IPv6 case. As we have all the data in the iph structure,
> to avoid the same slow lookups provide the iph to schedulers.
>=20
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Looks good to me.

Acked-by: Hans Schillstrom <hans@schillstrom.com>

> ---
>  include/net/ip_vs.h              |   28 ++--------------------------
>  net/netfilter/ipvs/ip_vs_core.c  |    4 ++--
>  net/netfilter/ipvs/ip_vs_dh.c    |   10 ++++------
>  net/netfilter/ipvs/ip_vs_lblc.c  |   12 +++++-------
>  net/netfilter/ipvs/ip_vs_lblcr.c |   12 +++++-------
>  net/netfilter/ipvs/ip_vs_lc.c    |    3 ++-
>  net/netfilter/ipvs/ip_vs_nq.c    |    3 ++-
>  net/netfilter/ipvs/ip_vs_rr.c    |    3 ++-
>  net/netfilter/ipvs/ip_vs_sed.c   |    3 ++-
>  net/netfilter/ipvs/ip_vs_sh.c    |   10 ++++------
>  net/netfilter/ipvs/ip_vs_wlc.c   |    3 ++-
>  net/netfilter/ipvs/ip_vs_wrr.c   |    3 ++-
>  12 files changed, 34 insertions(+), 60 deletions(-)
>=20
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index 22bea5d..95860df 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -197,31 +197,6 @@ ip_vs_fill_iph_skb(int af, const struct sk_buff *skb=
, struct ip_vs_iphdr *iphdr)
>  	}
>  }
> =20
> -/* This function is a faster version of ip_vs_fill_iph_skb().
> - * Where we only populate {s,d}addr (and avoid calling ipv6_find_hdr()).
> - * This is used by the some of the ip_vs_*_schedule() functions.
> - * (Mostly done to avoid ABI breakage of external schedulers)
> - */
> -static inline void
> -ip_vs_fill_iph_addr_only(int af, const struct sk_buff *skb,
> -			 struct ip_vs_iphdr *iphdr)
> -{
> -#ifdef CONFIG_IP_VS_IPV6
> -	if (af =3D=3D AF_INET6) {
> -		const struct ipv6hdr *iph =3D
> -			(struct ipv6hdr *)skb_network_header(skb);
> -		iphdr->saddr.in6 =3D iph->saddr;
> -		iphdr->daddr.in6 =3D iph->daddr;
> -	} else
> -#endif
> -	{
> -		const struct iphdr *iph =3D
> -			(struct iphdr *)skb_network_header(skb);
> -		iphdr->saddr.ip =3D iph->saddr;
> -		iphdr->daddr.ip =3D iph->daddr;
> -	}
> -}
> -
>  static inline void ip_vs_addr_copy(int af, union nf_inet_addr *dst,
>  				   const union nf_inet_addr *src)
>  {
> @@ -814,7 +789,8 @@ struct ip_vs_scheduler {
> =20
>  	/* selecting a server from the given service */
>  	struct ip_vs_dest* (*schedule)(struct ip_vs_service *svc,
> -				       const struct sk_buff *skb);
> +				       const struct sk_buff *skb,
> +				       struct ip_vs_iphdr *iph);
>  };
> =20
>  /* The persistence engine object */
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_c=
ore.c
> index 05565d2..e9b0330 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -305,7 +305,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
>  		 * return *ignored=3D0 i.e. ICMP and NF_DROP
>  		 */
>  		sched =3D rcu_dereference(svc->scheduler);
> -		dest =3D sched->schedule(svc, skb);
> +		dest =3D sched->schedule(svc, skb, iph);
>  		if (!dest) {
>  			IP_VS_DBG(1, "p-schedule: no dest found.\n");
>  			kfree(param.pe_data);
> @@ -452,7 +452,7 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_b=
uff *skb,
>  	}
> =20
>  	sched =3D rcu_dereference(svc->scheduler);
> -	dest =3D sched->schedule(svc, skb);
> +	dest =3D sched->schedule(svc, skb, iph);
>  	if (dest =3D=3D NULL) {
>  		IP_VS_DBG(1, "Schedule: no dest found.\n");
>  		return NULL;
> diff --git a/net/netfilter/ipvs/ip_vs_dh.c b/net/netfilter/ipvs/ip_vs_dh.=
c
> index ccab120..c3b8454 100644
> --- a/net/netfilter/ipvs/ip_vs_dh.c
> +++ b/net/netfilter/ipvs/ip_vs_dh.c
> @@ -214,18 +214,16 @@ static inline int is_overloaded(struct ip_vs_dest *=
dest)
>   *      Destination hashing scheduling
>   */
>  static struct ip_vs_dest *
> -ip_vs_dh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
> +ip_vs_dh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
> +		  struct ip_vs_iphdr *iph)
>  {
>  	struct ip_vs_dest *dest;
>  	struct ip_vs_dh_state *s;
> -	struct ip_vs_iphdr iph;
> -
> -	ip_vs_fill_iph_addr_only(svc->af, skb, &iph);
> =20
>  	IP_VS_DBG(6, "%s(): Scheduling...\n", __func__);
> =20
>  	s =3D (struct ip_vs_dh_state *) svc->sched_data;
> -	dest =3D ip_vs_dh_get(svc->af, s, &iph.daddr);
> +	dest =3D ip_vs_dh_get(svc->af, s, &iph->daddr);
>  	if (!dest
>  	    || !(dest->flags & IP_VS_DEST_F_AVAILABLE)
>  	    || atomic_read(&dest->weight) <=3D 0
> @@ -235,7 +233,7 @@ ip_vs_dh_schedule(struct ip_vs_service *svc, const st=
ruct sk_buff *skb)
>  	}
> =20
>  	IP_VS_DBG_BUF(6, "DH: destination IP address %s --> server %s:%d\n",
> -		      IP_VS_DBG_ADDR(svc->af, &iph.daddr),
> +		      IP_VS_DBG_ADDR(svc->af, &iph->daddr),
>  		      IP_VS_DBG_ADDR(svc->af, &dest->addr),
>  		      ntohs(dest->port));
> =20
> diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_l=
blc.c
> index 5ea26bd..04b8710 100644
> --- a/net/netfilter/ipvs/ip_vs_lblc.c
> +++ b/net/netfilter/ipvs/ip_vs_lblc.c
> @@ -487,19 +487,17 @@ is_overloaded(struct ip_vs_dest *dest, struct ip_vs=
_service *svc)
>   *    Locality-Based (weighted) Least-Connection scheduling
>   */
>  static struct ip_vs_dest *
> -ip_vs_lblc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb=
)
> +ip_vs_lblc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb=
,
> +		    struct ip_vs_iphdr *iph)
>  {
>  	struct ip_vs_lblc_table *tbl =3D svc->sched_data;
> -	struct ip_vs_iphdr iph;
>  	struct ip_vs_dest *dest =3D NULL;
>  	struct ip_vs_lblc_entry *en;
> =20
> -	ip_vs_fill_iph_addr_only(svc->af, skb, &iph);
> -
>  	IP_VS_DBG(6, "%s(): Scheduling...\n", __func__);
> =20
>  	/* First look in our cache */
> -	en =3D ip_vs_lblc_get(svc->af, tbl, &iph.daddr);
> +	en =3D ip_vs_lblc_get(svc->af, tbl, &iph->daddr);
>  	if (en) {
>  		/* We only hold a read lock, but this is atomic */
>  		en->lastuse =3D jiffies;
> @@ -529,12 +527,12 @@ ip_vs_lblc_schedule(struct ip_vs_service *svc, cons=
t struct sk_buff *skb)
>  	/* If we fail to create a cache entry, we'll just use the valid dest */
>  	spin_lock_bh(&svc->sched_lock);
>  	if (!tbl->dead)
> -		ip_vs_lblc_new(tbl, &iph.daddr, dest);
> +		ip_vs_lblc_new(tbl, &iph->daddr, dest);
>  	spin_unlock_bh(&svc->sched_lock);
> =20
>  out:
>  	IP_VS_DBG_BUF(6, "LBLC: destination IP address %s --> server %s:%d\n",
> -		      IP_VS_DBG_ADDR(svc->af, &iph.daddr),
> +		      IP_VS_DBG_ADDR(svc->af, &iph->daddr),
>  		      IP_VS_DBG_ADDR(svc->af, &dest->addr), ntohs(dest->port));
> =20
>  	return dest;
> diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_=
lblcr.c
> index 50123c2..a5122ad 100644
> --- a/net/netfilter/ipvs/ip_vs_lblcr.c
> +++ b/net/netfilter/ipvs/ip_vs_lblcr.c
> @@ -655,19 +655,17 @@ is_overloaded(struct ip_vs_dest *dest, struct ip_vs=
_service *svc)
>   *    Locality-Based (weighted) Least-Connection scheduling
>   */
>  static struct ip_vs_dest *
> -ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *sk=
b)
> +ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *sk=
b,
> +		     struct ip_vs_iphdr *iph)
>  {
>  	struct ip_vs_lblcr_table *tbl =3D svc->sched_data;
> -	struct ip_vs_iphdr iph;
>  	struct ip_vs_dest *dest;
>  	struct ip_vs_lblcr_entry *en;
> =20
> -	ip_vs_fill_iph_addr_only(svc->af, skb, &iph);
> -
>  	IP_VS_DBG(6, "%s(): Scheduling...\n", __func__);
> =20
>  	/* First look in our cache */
> -	en =3D ip_vs_lblcr_get(svc->af, tbl, &iph.daddr);
> +	en =3D ip_vs_lblcr_get(svc->af, tbl, &iph->daddr);
>  	if (en) {
>  		en->lastuse =3D jiffies;
> =20
> @@ -718,12 +716,12 @@ ip_vs_lblcr_schedule(struct ip_vs_service *svc, con=
st struct sk_buff *skb)
>  	/* If we fail to create a cache entry, we'll just use the valid dest */
>  	spin_lock_bh(&svc->sched_lock);
>  	if (!tbl->dead)
> -		ip_vs_lblcr_new(tbl, &iph.daddr, dest);
> +		ip_vs_lblcr_new(tbl, &iph->daddr, dest);
>  	spin_unlock_bh(&svc->sched_lock);
> =20
>  out:
>  	IP_VS_DBG_BUF(6, "LBLCR: destination IP address %s --> server %s:%d\n",
> -		      IP_VS_DBG_ADDR(svc->af, &iph.daddr),
> +		      IP_VS_DBG_ADDR(svc->af, &iph->daddr),
>  		      IP_VS_DBG_ADDR(svc->af, &dest->addr), ntohs(dest->port));
> =20
>  	return dest;
> diff --git a/net/netfilter/ipvs/ip_vs_lc.c b/net/netfilter/ipvs/ip_vs_lc.=
c
> index 5128e33..2bdcb1c 100644
> --- a/net/netfilter/ipvs/ip_vs_lc.c
> +++ b/net/netfilter/ipvs/ip_vs_lc.c
> @@ -26,7 +26,8 @@
>   *	Least Connection scheduling
>   */
>  static struct ip_vs_dest *
> -ip_vs_lc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
> +ip_vs_lc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
> +		  struct ip_vs_iphdr *iph)
>  {
>  	struct ip_vs_dest *dest, *least =3D NULL;
>  	unsigned int loh =3D 0, doh;
> diff --git a/net/netfilter/ipvs/ip_vs_nq.c b/net/netfilter/ipvs/ip_vs_nq.=
c
> index 646cfd4..d8d9860 100644
> --- a/net/netfilter/ipvs/ip_vs_nq.c
> +++ b/net/netfilter/ipvs/ip_vs_nq.c
> @@ -55,7 +55,8 @@ ip_vs_nq_dest_overhead(struct ip_vs_dest *dest)
>   *	Weighted Least Connection scheduling
>   */
>  static struct ip_vs_dest *
> -ip_vs_nq_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
> +ip_vs_nq_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
> +		  struct ip_vs_iphdr *iph)
>  {
>  	struct ip_vs_dest *dest, *least =3D NULL;
>  	unsigned int loh =3D 0, doh;
> diff --git a/net/netfilter/ipvs/ip_vs_rr.c b/net/netfilter/ipvs/ip_vs_rr.=
c
> index c35986c..176b87c 100644
> --- a/net/netfilter/ipvs/ip_vs_rr.c
> +++ b/net/netfilter/ipvs/ip_vs_rr.c
> @@ -55,7 +55,8 @@ static int ip_vs_rr_del_dest(struct ip_vs_service *svc,=
 struct ip_vs_dest *dest)
>   * Round-Robin Scheduling
>   */
>  static struct ip_vs_dest *
> -ip_vs_rr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
> +ip_vs_rr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
> +		  struct ip_vs_iphdr *iph)
>  {
>  	struct list_head *p;
>  	struct ip_vs_dest *dest, *last;
> diff --git a/net/netfilter/ipvs/ip_vs_sed.c b/net/netfilter/ipvs/ip_vs_se=
d.c
> index f320592..a5284cc 100644
> --- a/net/netfilter/ipvs/ip_vs_sed.c
> +++ b/net/netfilter/ipvs/ip_vs_sed.c
> @@ -59,7 +59,8 @@ ip_vs_sed_dest_overhead(struct ip_vs_dest *dest)
>   *	Weighted Least Connection scheduling
>   */
>  static struct ip_vs_dest *
> -ip_vs_sed_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
> +ip_vs_sed_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
> +		   struct ip_vs_iphdr *iph)
>  {
>  	struct ip_vs_dest *dest, *least;
>  	unsigned int loh, doh;
> diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.=
c
> index a65edfe4..e0d5d16 100644
> --- a/net/netfilter/ipvs/ip_vs_sh.c
> +++ b/net/netfilter/ipvs/ip_vs_sh.c
> @@ -227,18 +227,16 @@ static inline int is_overloaded(struct ip_vs_dest *=
dest)
>   *      Source Hashing scheduling
>   */
>  static struct ip_vs_dest *
> -ip_vs_sh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
> +ip_vs_sh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
> +		  struct ip_vs_iphdr *iph)
>  {
>  	struct ip_vs_dest *dest;
>  	struct ip_vs_sh_state *s;
> -	struct ip_vs_iphdr iph;
> -
> -	ip_vs_fill_iph_addr_only(svc->af, skb, &iph);
> =20
>  	IP_VS_DBG(6, "ip_vs_sh_schedule(): Scheduling...\n");
> =20
>  	s =3D (struct ip_vs_sh_state *) svc->sched_data;
> -	dest =3D ip_vs_sh_get(svc->af, s, &iph.saddr);
> +	dest =3D ip_vs_sh_get(svc->af, s, &iph->saddr);
>  	if (!dest
>  	    || !(dest->flags & IP_VS_DEST_F_AVAILABLE)
>  	    || atomic_read(&dest->weight) <=3D 0
> @@ -248,7 +246,7 @@ ip_vs_sh_schedule(struct ip_vs_service *svc, const st=
ruct sk_buff *skb)
>  	}
> =20
>  	IP_VS_DBG_BUF(6, "SH: source IP address %s --> server %s:%d\n",
> -		      IP_VS_DBG_ADDR(svc->af, &iph.saddr),
> +		      IP_VS_DBG_ADDR(svc->af, &iph->saddr),
>  		      IP_VS_DBG_ADDR(svc->af, &dest->addr),
>  		      ntohs(dest->port));
> =20
> diff --git a/net/netfilter/ipvs/ip_vs_wlc.c b/net/netfilter/ipvs/ip_vs_wl=
c.c
> index c60a81c..6dc1fa1 100644
> --- a/net/netfilter/ipvs/ip_vs_wlc.c
> +++ b/net/netfilter/ipvs/ip_vs_wlc.c
> @@ -31,7 +31,8 @@
>   *	Weighted Least Connection scheduling
>   */
>  static struct ip_vs_dest *
> -ip_vs_wlc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
> +ip_vs_wlc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
> +		   struct ip_vs_iphdr *iph)
>  {
>  	struct ip_vs_dest *dest, *least;
>  	unsigned int loh, doh;
> diff --git a/net/netfilter/ipvs/ip_vs_wrr.c b/net/netfilter/ipvs/ip_vs_wr=
r.c
> index 0e68555..0546cd5 100644
> --- a/net/netfilter/ipvs/ip_vs_wrr.c
> +++ b/net/netfilter/ipvs/ip_vs_wrr.c
> @@ -162,7 +162,8 @@ static int ip_vs_wrr_dest_changed(struct ip_vs_servic=
e *svc,
>   *    Weighted Round-Robin Scheduling
>   */
>  static struct ip_vs_dest *
> -ip_vs_wrr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
> +ip_vs_wrr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
> +		   struct ip_vs_iphdr *iph)
>  {
>  	struct ip_vs_dest *dest, *last, *stop =3D NULL;
>  	struct ip_vs_wrr_mark *mark =3D svc->sched_data;


--=-V6iMlC9OgkJ25NWSqiqE
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Disposition: attachment; filename="smime.p7s"
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIUdDCCBjQw
ggQcoAMCAQICAR4wDQYJKoZIhvcNAQEFBQAwfTELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0YXJ0
Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcxKTAn
BgNVBAMTIFN0YXJ0Q29tIENlcnRpZmljYXRpb24gQXV0aG9yaXR5MB4XDTA3MTAyNDIxMDE1NVoX
DTE3MTAyNDIxMDE1NVowgYwxCzAJBgNVBAYTAklMMRYwFAYDVQQKEw1TdGFydENvbSBMdGQuMSsw
KQYDVQQLEyJTZWN1cmUgRGlnaXRhbCBDZXJ0aWZpY2F0ZSBTaWduaW5nMTgwNgYDVQQDEy9TdGFy
dENvbSBDbGFzcyAxIFByaW1hcnkgSW50ZXJtZWRpYXRlIENsaWVudCBDQTCCASIwDQYJKoZIhvcN
AQEBBQADggEPADCCAQoCggEBAMcJg8zOLdgasSmkLhOrlr6KMoOMpohBllVHrdRvEg/q6r8jR+EK
75xCGhR8ToREoqe7zM9/UnC6TS2y9UKTpT1v7RSMzR0t6ndl0TWBuUr/UXBhPk+Kmy7bI4yW4urC
+y7P3/1/X7U8ocb8VpH/Clt+4iq7nirMcNh6qJR+xjOhV+VHzQMALuGYn5KZmc1NbJQYclsGkDxD
z2UbFqE2+6vIZoL+jb9x4Pa5gNf1TwSDkOkikZB1xtB4ZqtXThaABSONdfmv/Z1pua3FYxnCFmdr
/+N2JLKutIxMYqQOJebr/f/h5t95m4JgrM3Y/w7YX9d7YAL9jvN4SydHsU6n65cCAwEAAaOCAa0w
ggGpMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgEGMB0GA1UdDgQWBBRTcu2SnODaywFc
fH6WNU7y1LhRgjAfBgNVHSMEGDAWgBROC+8apEBbpRdphzDKNGhD0EGu8jBmBggrBgEFBQcBAQRa
MFgwJwYIKwYBBQUHMAGGG2h0dHA6Ly9vY3NwLnN0YXJ0c3NsLmNvbS9jYTAtBggrBgEFBQcwAoYh
aHR0cDovL3d3dy5zdGFydHNzbC5jb20vc2ZzY2EuY3J0MFsGA1UdHwRUMFIwJ6AloCOGIWh0dHA6
Ly93d3cuc3RhcnRzc2wuY29tL3Nmc2NhLmNybDAnoCWgI4YhaHR0cDovL2NybC5zdGFydHNzbC5j
b20vc2ZzY2EuY3JsMIGABgNVHSAEeTB3MHUGCysGAQQBgbU3AQIBMGYwLgYIKwYBBQUHAgEWImh0
dHA6Ly93d3cuc3RhcnRzc2wuY29tL3BvbGljeS5wZGYwNAYIKwYBBQUHAgEWKGh0dHA6Ly93d3cu
c3RhcnRzc2wuY29tL2ludGVybWVkaWF0ZS5wZGYwDQYJKoZIhvcNAQEFBQADggIBAAqDCH14qywG
XLhjjF6uHLkjd02hcdh9hrw+VUsv+q1eeQWB21jWj3kJ96AUlPCoEGZ/ynJNScWy6QMVQjbbMXlt
UfO4n4bGGdKo3awPWp61tjAFgraLJgDk+DsSvUD6EowjMTNx25GQgyYJ5RPIzKKR9tQW8gGK+2+R
HxkUCTbYFnL6kl8Ch507rUdPPipJ9CgJFws3kDS3gOS5WFMxcjO5DwKfKSETEPrHh7p5shuuNktv
sv6hxHTLhiMKX893gxdT3XLS9OKmCv87vkINQcNEcIIoFWbP9HORz9v3vQwR4e3ksLc2JZOAFK+s
sS5XMEoznzpihEP0PLc4dCBYjbvSD7kxgDwZ+Aj8Q9PkbvE9sIPP7ON0fz095HdThKjiVJe6vofq
+n6b1NBc8XdrQvBmunwxD5nvtTW4vtN6VY7mUCmxsCieuoBJ9OlqmsVWQvifIYf40dJPZkk9YgGT
zWLpXDSfLSplbY2LL9C9U0ptvjcDjefLTvqSFc7tw1sEhF0n/qpA2r0GpvkLRDmcSwVyPvmjFBGq
Up/pNy8ZuPGQmHwFi2/14+xeSUDG2bwnsYJQG2EdJCB6luQ57GEnTA/yKZSTKI8dDQa8Sd3zfXb1
9mOgSF0bBdXbuKhEpuP9wirslFe6fQ1t5j5R0xi72MZ8ikMu1RQZKCyDbMwazlHiMIIHGjCCBgKg
AwIBAgIDBP9VMA0GCSqGSIb3DQEBBQUAMIGMMQswCQYDVQQGEwJJTDEWMBQGA1UEChMNU3RhcnRD
b20gTHRkLjErMCkGA1UECxMiU2VjdXJlIERpZ2l0YWwgQ2VydGlmaWNhdGUgU2lnbmluZzE4MDYG
A1UEAxMvU3RhcnRDb20gQ2xhc3MgMSBQcmltYXJ5IEludGVybWVkaWF0ZSBDbGllbnQgQ0EwHhcN
MTIwOTI2MjMxOTExWhcNMTMwOTI3MjIzMzA5WjBfMRkwFwYDVQQNExBHUzBYNXRWbzdHME1DTTZ3
MR0wGwYDVQQDDBRoYW5zQHNjaGlsbHN0cm9tLmNvbTEjMCEGCSqGSIb3DQEJARYUaGFuc0BzY2hp
bGxzdHJvbS5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDQIAPtMSPPW7DtTcDP
ebYTwwB6CBHM5xDgn9MemqOCzycCRktsSEo56/3g89NtbsfbxpiqTpneSEZvMwwyoeLx/fxdXei/
BM2X873s+zj8kTz8tqwKvcEmzz/VafRyxaGrUPVOMojVnSj+bJOAGYLdqLLRNGX2nUsw9LxuRU5L
+jABJudead3Q+A93TrEpZSp75TIVBioMRiqonx1ogJEzRC+/K8q9dyOFyBl2nF/jO2FwfMGcqCKh
k8G7znu3KsrI2i7eq56+wDkDr9o5SCplbzjCmGBYsaXeBFqQeL3gxzjKhlFPnjTQ4Oq2Ly6xo1us
mS3lSQqVd9I8vOv0RybHAgMBAAGjggOvMIIDqzAJBgNVHRMEAjAAMAsGA1UdDwQEAwIEsDAdBgNV
HSUEFjAUBggrBgEFBQcDAgYIKwYBBQUHAwQwHQYDVR0OBBYEFN1lV6PcU4miFt2LEdwgL/mH8hhx
MB8GA1UdIwQYMBaAFFNy7ZKc4NrLAVx8fpY1TvLUuFGCMB8GA1UdEQQYMBaBFGhhbnNAc2NoaWxs
c3Ryb20uY29tMIICIQYDVR0gBIICGDCCAhQwggIQBgsrBgEEAYG1NwECAjCCAf8wLgYIKwYBBQUH
AgEWImh0dHA6Ly93d3cuc3RhcnRzc2wuY29tL3BvbGljeS5wZGYwNAYIKwYBBQUHAgEWKGh0dHA6
Ly93d3cuc3RhcnRzc2wuY29tL2ludGVybWVkaWF0ZS5wZGYwgfcGCCsGAQUFBwICMIHqMCcWIFN0
YXJ0Q29tIENlcnRpZmljYXRpb24gQXV0aG9yaXR5MAMCAQEagb5UaGlzIGNlcnRpZmljYXRlIHdh
cyBpc3N1ZWQgYWNjb3JkaW5nIHRvIHRoZSBDbGFzcyAxIFZhbGlkYXRpb24gcmVxdWlyZW1lbnRz
IG9mIHRoZSBTdGFydENvbSBDQSBwb2xpY3ksIHJlbGlhbmNlIG9ubHkgZm9yIHRoZSBpbnRlbmRl
ZCBwdXJwb3NlIGluIGNvbXBsaWFuY2Ugb2YgdGhlIHJlbHlpbmcgcGFydHkgb2JsaWdhdGlvbnMu
MIGcBggrBgEFBQcCAjCBjzAnFiBTdGFydENvbSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTADAgEC
GmRMaWFiaWxpdHkgYW5kIHdhcnJhbnRpZXMgYXJlIGxpbWl0ZWQhIFNlZSBzZWN0aW9uICJMZWdh
bCBhbmQgTGltaXRhdGlvbnMiIG9mIHRoZSBTdGFydENvbSBDQSBwb2xpY3kuMDYGA1UdHwQvMC0w
K6ApoCeGJWh0dHA6Ly9jcmwuc3RhcnRzc2wuY29tL2NydHUxLWNybC5jcmwwgY4GCCsGAQUFBwEB
BIGBMH8wOQYIKwYBBQUHMAGGLWh0dHA6Ly9vY3NwLnN0YXJ0c3NsLmNvbS9zdWIvY2xhc3MxL2Ns
aWVudC9jYTBCBggrBgEFBQcwAoY2aHR0cDovL2FpYS5zdGFydHNzbC5jb20vY2VydHMvc3ViLmNs
YXNzMS5jbGllbnQuY2EuY3J0MCMGA1UdEgQcMBqGGGh0dHA6Ly93d3cuc3RhcnRzc2wuY29tLzAN
BgkqhkiG9w0BAQUFAAOCAQEAmXkF0bt14z3+SVk5a0cA07I46LCwg/EJv2rB8rq11Ey1+eUAaGlm
zOjOyJybxuYjNeD9csnk/dwlhF4CY9X2q6imx/BSyraOHQT8iyDykAe7JLQv702A6Ath7SHGAZhf
x93IgZ7dS4IMvjJ8lB1kkyzZ1A5MxjF/BrihO1MYXp/29/+zWn2bvlg92hEOMkcs0yVnaUsiGWXa
EkSIqqkMgrf3g4X4btOWkoumKEu3jHPlii/4WT4Y0QLio0T0XLuo9X3nkvNBFz9DaSQP5Of+YFqR
imLRxnelbAJz8m0WOAKhLUweaJtSunLmabTzj733vQjyYsJkpaorDfXnEhI4ajCCBxowggYCoAMC
AQICAwT/VTANBgkqhkiG9w0BAQUFADCBjDELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0YXJ0Q29t
IEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcxODA2BgNV
BAMTL1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1lZGlhdGUgQ2xpZW50IENBMB4XDTEy
MDkyNjIzMTkxMVoXDTEzMDkyNzIyMzMwOVowXzEZMBcGA1UEDRMQR1MwWDV0Vm83RzBNQ002dzEd
MBsGA1UEAwwUaGFuc0BzY2hpbGxzdHJvbS5jb20xIzAhBgkqhkiG9w0BCQEWFGhhbnNAc2NoaWxs
c3Ryb20uY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0CAD7TEjz1uw7U3Az3m2
E8MAeggRzOcQ4J/THpqjgs8nAkZLbEhKOev94PPTbW7H28aYqk6Z3khGbzMMMqHi8f38XV3ovwTN
l/O97Ps4/JE8/LasCr3BJs8/1Wn0csWhq1D1TjKI1Z0o/myTgBmC3aiy0TRl9p1LMPS8bkVOS/ow
ASbnXmnd0PgPd06xKWUqe+UyFQYqDEYqqJ8daICRM0QvvyvKvXcjhcgZdpxf4zthcHzBnKgioZPB
u857tyrKyNou3quevsA5A6/aOUgqZW84wphgWLGl3gRakHi94Mc4yoZRT5400ODqti8usaNbrJkt
5UkKlXfSPLzr9EcmxwIDAQABo4IDrzCCA6swCQYDVR0TBAIwADALBgNVHQ8EBAMCBLAwHQYDVR0l
BBYwFAYIKwYBBQUHAwIGCCsGAQUFBwMEMB0GA1UdDgQWBBTdZVej3FOJohbdixHcIC/5h/IYcTAf
BgNVHSMEGDAWgBRTcu2SnODaywFcfH6WNU7y1LhRgjAfBgNVHREEGDAWgRRoYW5zQHNjaGlsbHN0
cm9tLmNvbTCCAiEGA1UdIASCAhgwggIUMIICEAYLKwYBBAGBtTcBAgIwggH/MC4GCCsGAQUFBwIB
FiJodHRwOi8vd3d3LnN0YXJ0c3NsLmNvbS9wb2xpY3kucGRmMDQGCCsGAQUFBwIBFihodHRwOi8v
d3d3LnN0YXJ0c3NsLmNvbS9pbnRlcm1lZGlhdGUucGRmMIH3BggrBgEFBQcCAjCB6jAnFiBTdGFy
dENvbSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTADAgEBGoG+VGhpcyBjZXJ0aWZpY2F0ZSB3YXMg
aXNzdWVkIGFjY29yZGluZyB0byB0aGUgQ2xhc3MgMSBWYWxpZGF0aW9uIHJlcXVpcmVtZW50cyBv
ZiB0aGUgU3RhcnRDb20gQ0EgcG9saWN5LCByZWxpYW5jZSBvbmx5IGZvciB0aGUgaW50ZW5kZWQg
cHVycG9zZSBpbiBjb21wbGlhbmNlIG9mIHRoZSByZWx5aW5nIHBhcnR5IG9ibGlnYXRpb25zLjCB
nAYIKwYBBQUHAgIwgY8wJxYgU3RhcnRDb20gQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkwAwIBAhpk
TGlhYmlsaXR5IGFuZCB3YXJyYW50aWVzIGFyZSBsaW1pdGVkISBTZWUgc2VjdGlvbiAiTGVnYWwg
YW5kIExpbWl0YXRpb25zIiBvZiB0aGUgU3RhcnRDb20gQ0EgcG9saWN5LjA2BgNVHR8ELzAtMCug
KaAnhiVodHRwOi8vY3JsLnN0YXJ0c3NsLmNvbS9jcnR1MS1jcmwuY3JsMIGOBggrBgEFBQcBAQSB
gTB/MDkGCCsGAQUFBzABhi1odHRwOi8vb2NzcC5zdGFydHNzbC5jb20vc3ViL2NsYXNzMS9jbGll
bnQvY2EwQgYIKwYBBQUHMAKGNmh0dHA6Ly9haWEuc3RhcnRzc2wuY29tL2NlcnRzL3N1Yi5jbGFz
czEuY2xpZW50LmNhLmNydDAjBgNVHRIEHDAahhhodHRwOi8vd3d3LnN0YXJ0c3NsLmNvbS8wDQYJ
KoZIhvcNAQEFBQADggEBAJl5BdG7deM9/klZOWtHANOyOOiwsIPxCb9qwfK6tdRMtfnlAGhpZszo
zsicm8bmIzXg/XLJ5P3cJYReAmPV9quopsfwUsq2jh0E/Isg8pAHuyS0L+9NgOgLYe0hxgGYX8fd
yIGe3UuCDL4yfJQdZJMs2dQOTMYxfwa4oTtTGF6f9vf/s1p9m75YPdoRDjJHLNMlZ2lLIhll2hJE
iKqpDIK394OF+G7TlpKLpihLt4xz5Yov+Fk+GNEC4qNE9Fy7qPV955LzQRc/Q2kkD+Tn/mBakYpi
0cZ3pWwCc/JtFjgCoS1MHmibUrpy5mm084+9970I8mLCZKWqKw315xISOGoxggNvMIIDawIBATCB
lDCBjDELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3Vy
ZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcxODA2BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDEg
UHJpbWFyeSBJbnRlcm1lZGlhdGUgQ2xpZW50IENBAgME/1UwCQYFKw4DAhoFAKCCAa8wGAYJKoZI
hvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTMwNjE2MDkyMzMwWjAjBgkqhkiG
9w0BCQQxFgQUCUmE6SctULmXQZ+0MDqqJSSjUTkwgaUGCSsGAQQBgjcQBDGBlzCBlDCBjDELMAkG
A1UEBhMCSUwxFjAUBgNVBAoTDVN0YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFs
IENlcnRpZmljYXRlIFNpZ25pbmcxODA2BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJ
bnRlcm1lZGlhdGUgQ2xpZW50IENBAgME/1UwgacGCyqGSIb3DQEJEAILMYGXoIGUMIGMMQswCQYD
VQQGEwJJTDEWMBQGA1UEChMNU3RhcnRDb20gTHRkLjErMCkGA1UECxMiU2VjdXJlIERpZ2l0YWwg
Q2VydGlmaWNhdGUgU2lnbmluZzE4MDYGA1UEAxMvU3RhcnRDb20gQ2xhc3MgMSBQcmltYXJ5IElu
dGVybWVkaWF0ZSBDbGllbnQgQ0ECAwT/VTANBgkqhkiG9w0BAQEFAASCAQCWoezFfUoKtKTKfZFV
IbLX2f7TFFfPqX8ahYxyK4lMru3fgjb5k6rZawZsOErCu+IfgAdnnoTW0pCgSYJmOG0MVcTvRAGS
UHMHbKWorAip+O+wbQHTWoT9YvcbfrUKOe5Mn8lNoRm7VbvWxcwXUKuq7gS0Lqyn0IooYfqLa2xA
DHDNu82aX9x37KZtqYBnekSN4e5gYCb+EKXEqcbsPE8jPHlD9kgwqh8WTIs8S567CljenxtnQIw3
ZK8wjSDDBd97OLVfRhlu/ePRRIfU3VsMpNim2EPzD5neM0kBk49U3H7ZAnDofE030X++fSFzHlIu
Diyn6FZZEUfZeI8zs1mvAAAAAAAA


--=-V6iMlC9OgkJ25NWSqiqE--

