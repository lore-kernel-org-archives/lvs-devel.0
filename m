From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: [PATCH net-next 11/12] ipvs: reorder keys in connection
 structure
Date: Wed, 06 Mar 2013 10:43:34 +0100
Message-ID: <1362563014.17102.63.camel@hawk.mlab.se>
References: <1362559342-18784-1-git-send-email-ja@ssi.bg>
	 <1362559342-18784-12-git-send-email-ja@ssi.bg>
Reply-To: hans@schillstrom.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="sha1"; protocol="application/x-pkcs7-signature";
	boundary="=-osn2b+chKMJUz0oQYucn"
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1362559342-18784-12-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org


--=-osn2b+chKMJUz0oQYucn
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Julian
Great job you have done !
I'll test it immediate...


On Wed, 2013-03-06 at 10:42 +0200, Julian Anastasov wrote:
> 	__ip_vs_conn_in_get and ip_vs_conn_out_get are
> hot places. Optimize them, so that ports are matched first.
> By moving net and fwmark below, on 32-bit arch we can fit
> caddr in 32-byte cache line and all addresses in 64-byte
> cache line.

Earlier I made some rearrangements like the one you have made.
My conclusion at that time was that the best gain was to have
fwmark and net within the first 64 bytes, and move daddr to the next
cache line.

I uesd UDP at ~7Gbit/sec and 256k source address into a x86_64 machine,
and a 50/50 mix of fwmarks and port in that tests.=20

I guess that you have made similar test, and even take
ip_vs_conn_out_get() into your calculations ?


Regards
Hans

>=20
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
>  include/net/ip_vs.h             |   12 ++++++------
>  net/netfilter/ipvs/ip_vs_conn.c |    8 ++++----
>  2 files changed, 10 insertions(+), 10 deletions(-)
>=20
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index 9059360..2bc30e6 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -566,20 +566,19 @@ struct ip_vs_conn_param {
>   */
>  struct ip_vs_conn {
>  	struct hlist_node	c_list;         /* hashed list heads */
> -#ifdef CONFIG_NET_NS
> -	struct net              *net;           /* Name space */
> -#endif
>  	/* Protocol, addresses and port numbers */
> -	u16                     af;             /* address family */
>  	__be16                  cport;
> -	__be16                  vport;
>  	__be16                  dport;
> -	__u32                   fwmark;         /* Fire wall mark from skb */
> +	__be16                  vport;
> +	u16			af;		/* address family */
>  	union nf_inet_addr      caddr;          /* client address */
>  	union nf_inet_addr      vaddr;          /* virtual address */
>  	union nf_inet_addr      daddr;          /* destination address */
>  	volatile __u32          flags;          /* status flags */
>  	__u16                   protocol;       /* Which protocol (TCP/UDP) */
> +#ifdef CONFIG_NET_NS
> +	struct net              *net;           /* Name space */
> +#endif
> =20
>  	/* counter and timer */
>  	atomic_t		refcnt;		/* reference count */
> @@ -593,6 +592,7 @@ struct ip_vs_conn {
>  						 * state transition triggerd
>  						 * synchronization
>  						 */
> +	__u32			fwmark;		/* Fire wall mark from skb */
>  	unsigned long		sync_endtime;	/* jiffies + sent_retries */
> =20
>  	/* Control members */
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_c=
onn.c
> index b0cd2be..a4d8ec5 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -265,8 +265,8 @@ __ip_vs_conn_in_get(const struct ip_vs_conn_param *p)
>  	rcu_read_lock();
> =20
>  	hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[hash], c_list) {
> -		if (cp->af =3D=3D p->af &&
> -		    p->cport =3D=3D cp->cport && p->vport =3D=3D cp->vport &&
> +		if (p->cport =3D=3D cp->cport && p->vport =3D=3D cp->vport &&
> +		    cp->af =3D=3D p->af &&
>  		    ip_vs_addr_equal(p->af, p->caddr, &cp->caddr) &&
>  		    ip_vs_addr_equal(p->af, p->vaddr, &cp->vaddr) &&
>  		    ((!p->cport) ^ (!(cp->flags & IP_VS_CONN_F_NO_CPORT))) &&
> @@ -404,8 +404,8 @@ struct ip_vs_conn *ip_vs_conn_out_get(const struct ip=
_vs_conn_param *p)
>  	rcu_read_lock();
> =20
>  	hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[hash], c_list) {
> -		if (cp->af =3D=3D p->af &&
> -		    p->vport =3D=3D cp->cport && p->cport =3D=3D cp->dport &&
> +		if (p->vport =3D=3D cp->cport && p->cport =3D=3D cp->dport &&
> +		    cp->af =3D=3D p->af &&
>  		    ip_vs_addr_equal(p->af, p->vaddr, &cp->caddr) &&
>  		    ip_vs_addr_equal(p->af, p->caddr, &cp->daddr) &&
>  		    p->protocol =3D=3D cp->protocol &&


--=-osn2b+chKMJUz0oQYucn
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
hvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTMwMzA2MDk0MzM0WjAjBgkqhkiG
9w0BCQQxFgQUiK2aIEewc5BHLnpaWlwVzWqxBdEwgaUGCSsGAQQBgjcQBDGBlzCBlDCBjDELMAkG
A1UEBhMCSUwxFjAUBgNVBAoTDVN0YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFs
IENlcnRpZmljYXRlIFNpZ25pbmcxODA2BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJ
bnRlcm1lZGlhdGUgQ2xpZW50IENBAgME/1UwgacGCyqGSIb3DQEJEAILMYGXoIGUMIGMMQswCQYD
VQQGEwJJTDEWMBQGA1UEChMNU3RhcnRDb20gTHRkLjErMCkGA1UECxMiU2VjdXJlIERpZ2l0YWwg
Q2VydGlmaWNhdGUgU2lnbmluZzE4MDYGA1UEAxMvU3RhcnRDb20gQ2xhc3MgMSBQcmltYXJ5IElu
dGVybWVkaWF0ZSBDbGllbnQgQ0ECAwT/VTANBgkqhkiG9w0BAQEFAASCAQCoiymhW6aEXzZxvmG+
DFZt93TFGx1B2GZDcXyI3KIZPpHZ+YTH2JuByH4YYhp6r5ZGeC+SmWXVA8LKmL5moJDB/eQe0xqR
RdXU8tSl8v+fpOZ5+jAM7g0AYt9Eo1tZxSt23Uh9nN+8jyT1923s04E0iFi1LlO4WbbJRYBrU4zq
yWjkydqUYMpNc+X1ww+Z8H36dyAfzvcivDileHAPNgGZ5Se1wEqfHUVvzyHSgB/0LXW/liuVc8iS
ZAE4iMWAlJQrNN2V1+h3+sCGAJD6v+xIcI78Gy+AQIWJnFqnhUff0usPAw2QSVfAuHS/WeEyRzoX
sEa7wsW7UfD4Xoezy05gAAAAAAAA


--=-osn2b+chKMJUz0oQYucn--

