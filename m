From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: [PATCH net-next 4/6] ipvs: fix sparse warnings for sync msg size
Date: Mon, 22 Apr 2013 07:55:51 +0200
Message-ID: <1366610151.29441.3.camel@hawk.mlab.se>
References: <1366231850-22188-1-git-send-email-ja@ssi.bg>
	 <1366231850-22188-5-git-send-email-ja@ssi.bg>
	 <20130418114325.GA11486@verge.net.au>
	 <alpine.LFD.2.00.1304182215060.1842@ja.ssi.bg>
	 <20130419014952.GA25718@verge.net.au>
	 <alpine.LFD.2.00.1304192228380.1788@ja.ssi.bg>
	 <20130422040520.GK15680@verge.net.au>
Reply-To: hans@schillstrom.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="sha1"; protocol="application/x-pkcs7-signature";
	boundary="=-snFbAK1D3Dw5Mc+iXXyu"
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130422040520.GK15680@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>


--=-snFbAK1D3Dw5Mc+iXXyu
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hello Simon

On Mon, 2013-04-22 at 13:05 +0900, Simon Horman wrote:
> On Fri, Apr 19, 2013 at 10:35:04PM +0300, Julian Anastasov wrote:
> >=20
> > 	Hello,
> >=20
> > On Fri, 19 Apr 2013, Simon Horman wrote:
> >=20
> > > My idea is as follows:
> > >=20
> > > From: Simon Horman <horms@verge.net.au>
> > >=20
> > > ipvs: Use network byte order for sync message size
> > >=20
> > > struct ip_vs_sync_mesg is both sent across the wire and
> > > used internally to store IPVS synchronisation messages.
> > >=20
> > > Up until now the scheme used has been to convert the size field
> > > to network byte order before sending a message on the wire and
> > > convert it to host byte order when sending a message.
> > >=20
> > > This patch changes that scheme to always treat the field
> > > as being network byte order. This seems appropriate as
> > > the structure is sent across the wire. And by consistently
> > > treating the field has network byte order it is now possible
> > > to take advantage of sparse to flag any future miss-use.
> > >=20
> > > Signed-off-by: Simon Horman <horms@verge.net.au>
> > > ---
> > >  net/netfilter/ipvs/ip_vs_sync.c |   15 +++++----------
> > >  1 file changed, 5 insertions(+), 10 deletions(-)
> > >=20
> > > diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_=
vs_sync.c
> > > index 8e57077..c73778a 100644
> > > --- a/net/netfilter/ipvs/ip_vs_sync.c
> > > +++ b/net/netfilter/ipvs/ip_vs_sync.c
> > > @@ -255,7 +255,7 @@ struct ip_vs_sync_mesg_v0 {
> > >  struct ip_vs_sync_mesg {
> > >  	__u8			reserved;	/* must be zero */
> > >  	__u8			syncid;
> > > -	__u16			size;
> > > +	__be16			size;
> >=20
> > 	It seems v0 should be changed too,
> > ip_vs_send_sync_msg() handles both versions in sb->mesg.
>=20
> Thanks and sorry for missing that.
> How about this?
>=20
> From: Simon Horman <horms@verge.net.au>
>=20
> ipvs: Use network byte order for sync message size
>=20
> struct ip_vs_sync_mesg and ip_vs_sync_mesg_v0 are both sent across the wi=
re
> and used internally to store IPVS synchronisation messages.
>=20
> Up until now the scheme used has been to convert the size field
> to network byte order before sending a message on the wire and
> convert it to host byte order when sending a message.
>=20
> This patch changes that scheme to always treat the field
> as being network byte order. This seems appropriate as
> the structure is sent across the wire. And by consistently
> treating the field has network byte order it is now possible
> to take advantage of sparse to flag any future miss-use.
>=20
> Signed-off-by: Simon Horman <horms@verge.net.au>

It looks good=20

Ack-by: Hans Schillstrom <hans@schillstrom.com>

> ---
>=20
> v2
> * As suggested by Julian Anastasov,
>   update struct ip_vs_sync_mesg_v0  as well as struct ip_vs_sync_mesg.
> ---
>  net/netfilter/ipvs/ip_vs_sync.c | 21 ++++++++-------------
>  1 file changed, 8 insertions(+), 13 deletions(-)
>=20
> diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_s=
ync.c
> index 8e57077..f6046d9 100644
> --- a/net/netfilter/ipvs/ip_vs_sync.c
> +++ b/net/netfilter/ipvs/ip_vs_sync.c
> @@ -246,7 +246,7 @@ struct ip_vs_sync_thread_data {
>  struct ip_vs_sync_mesg_v0 {
>  	__u8                    nr_conns;
>  	__u8                    syncid;
> -	__u16                   size;
> +	__be16                  size;
> =20
>  	/* ip_vs_sync_conn entries start here */
>  };
> @@ -255,7 +255,7 @@ struct ip_vs_sync_mesg_v0 {
>  struct ip_vs_sync_mesg {
>  	__u8			reserved;	/* must be zero */
>  	__u8			syncid;
> -	__u16			size;
> +	__be16			size;
>  	__u8			nr_conns;
>  	__s8			version;	/* SYNC_PROTO_VER  */
>  	__u16			spare;
> @@ -335,7 +335,7 @@ ip_vs_sync_buff_create(struct netns_ipvs *ipvs)
>  	sb->mesg->reserved =3D 0;  /* old nr_conns i.e. must be zero now */
>  	sb->mesg->version =3D SYNC_PROTO_VER;
>  	sb->mesg->syncid =3D ipvs->master_syncid;
> -	sb->mesg->size =3D sizeof(struct ip_vs_sync_mesg);
> +	sb->mesg->size =3D htons(sizeof(struct ip_vs_sync_mesg));
>  	sb->mesg->nr_conns =3D 0;
>  	sb->mesg->spare =3D 0;
>  	sb->head =3D (unsigned char *)sb->mesg + sizeof(struct ip_vs_sync_mesg)=
;
> @@ -418,7 +418,7 @@ ip_vs_sync_buff_create_v0(struct netns_ipvs *ipvs)
>  	mesg =3D (struct ip_vs_sync_mesg_v0 *)sb->mesg;
>  	mesg->nr_conns =3D 0;
>  	mesg->syncid =3D ipvs->master_syncid;
> -	mesg->size =3D sizeof(struct ip_vs_sync_mesg_v0);
> +	mesg->size =3D htons(sizeof(struct ip_vs_sync_mesg_v0));
>  	sb->head =3D (unsigned char *)mesg + sizeof(struct ip_vs_sync_mesg_v0);
>  	sb->end =3D (unsigned char *)mesg + ipvs->send_mesg_maxlen;
>  	sb->firstuse =3D jiffies;
> @@ -582,7 +582,7 @@ static void ip_vs_sync_conn_v0(struct net *net, struc=
t ip_vs_conn *cp,
>  	}
> =20
>  	m->nr_conns++;
> -	m->size +=3D len;
> +	m->size =3D htons(ntohs(m->size) + len);
>  	buff->head +=3D len;
> =20
>  	/* check if there is a space for next one */
> @@ -693,7 +693,7 @@ sloop:
> =20
>  	p =3D buff->head;
>  	buff->head +=3D pad + len;
> -	m->size +=3D pad + len;
> +	m->size =3D htons(ntohs(m->size) + pad + len);
>  	/* Add ev. padding from prev. sync_conn */
>  	while (pad--)
>  		*(p++) =3D 0;
> @@ -1175,10 +1175,8 @@ static void ip_vs_process_message(struct net *net,=
 __u8 *buffer,
>  		IP_VS_DBG(2, "BACKUP, message header too short\n");
>  		return;
>  	}
> -	/* Convert size back to host byte order */
> -	m2->size =3D ntohs(m2->size);
> =20
> -	if (buflen !=3D m2->size) {
> +	if (buflen !=3D ntohs(m2->size)) {
>  		IP_VS_DBG(2, "BACKUP, bogus message size\n");
>  		return;
>  	}
> @@ -1544,10 +1542,7 @@ ip_vs_send_sync_msg(struct socket *sock, struct ip=
_vs_sync_mesg *msg)
>  	int msize;
>  	int ret;
> =20
> -	msize =3D msg->size;
> -
> -	/* Put size in network byte order */
> -	msg->size =3D htons(msg->size);
> +	msize =3D ntohs(msg->size);
> =20
>  	ret =3D ip_vs_send_async(sock, (char *)msg, msize);
>  	if (ret >=3D 0 || ret =3D=3D -EAGAIN)


--=-snFbAK1D3Dw5Mc+iXXyu
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
hvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTMwNDIyMDU1NTUxWjAjBgkqhkiG
9w0BCQQxFgQUkSaYSM9eJpudF2B591W51Ga30YgwgaUGCSsGAQQBgjcQBDGBlzCBlDCBjDELMAkG
A1UEBhMCSUwxFjAUBgNVBAoTDVN0YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFs
IENlcnRpZmljYXRlIFNpZ25pbmcxODA2BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJ
bnRlcm1lZGlhdGUgQ2xpZW50IENBAgME/1UwgacGCyqGSIb3DQEJEAILMYGXoIGUMIGMMQswCQYD
VQQGEwJJTDEWMBQGA1UEChMNU3RhcnRDb20gTHRkLjErMCkGA1UECxMiU2VjdXJlIERpZ2l0YWwg
Q2VydGlmaWNhdGUgU2lnbmluZzE4MDYGA1UEAxMvU3RhcnRDb20gQ2xhc3MgMSBQcmltYXJ5IElu
dGVybWVkaWF0ZSBDbGllbnQgQ0ECAwT/VTANBgkqhkiG9w0BAQEFAASCAQBvn/Vc/3oE/ETXxLAZ
dwAMZG0SrppZqBL4IM+V9a/G8GPyDSqyoZt5iRjowwO+AOcKTPPNgqwiBxM9lNDfbHPCegV0FPNb
F+T+H7rUY578xTT6mkXm4kWXe98Awqzc4yG/hbfQegutgcuONd+RT1U6g+/mMSKcQTlTzp6qXbXB
2d9d+pjVo7gdiprNIDZtOtZUCcgBnFIn538FGTY39Vhc2ghyvGwxCxeFporRXg4JJ5kM1wM+Lh5t
wN79H1HkTpn4D1sq2EF2hQnvIdsC7qGfEMBG1rBBMSdlGUyptGPn0DOcnD2QEo24ehx1o08pglui
RIIhMpfgo1kNLVByZ3U3AAAAAAAA


--=-snFbAK1D3Dw5Mc+iXXyu--

