From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: [PATCH] ipvs: fix ipv6 icmp forwarding in natted services
Date: Wed, 19 Feb 2014 21:28:38 +0100
Message-ID: <1392841718.5821.437.camel@hawk.mlab.se>
References: <20140217153206.GC18029@telegraafnet.nl>
	 <20140217161601.GD18029@telegraafnet.nl>
	 <alpine.LFD.2.11.1402172321200.2420@ja.home.ssi.bg>
	 <20140218100533.GE18029@telegraafnet.nl>
	 <20140218133725.GA20771@telegraafnet.nl>
	 <20140218135439.GB20771@telegraafnet.nl>
	 <alpine.LFD.2.11.1402182225560.2011@ja.home.ssi.bg>
	 <20140219102751.GD20771@telegraafnet.nl>
	 <1392825857.5821.422.camel@hawk.mlab.se>
	 <20140219170505.GI20771@telegraafnet.nl>
Reply-To: hans@schillstrom.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="sha256";
	protocol="application/x-pkcs7-signature";
	boundary="=-ZToDxBMt9CAD8YK3gsKS"
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20140219170505.GI20771@telegraafnet.nl>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: Art -kwaak- van Breemen <ard@telegraafnet.nl>
Cc: Ansis Atteka <aatteka@nicira.com>, Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>


--=-ZToDxBMt9CAD8YK3gsKS
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: quoted-printable

Hello

On Wed, 2014-02-19 at 18:05 +0100, Art -kwaak- van Breemen wrote:
> Hi Hans,
>=20
> On Wed, Feb 19, 2014 at 05:04:17PM +0100, Hans Schillstrom wrote:
> > The problem is if icmp6 is not the first header it will not work...
> > i.e. it can be other headers before icmp and if you have -1 you will no=
t
> > always get the icmp header.
>=20
> Ah bah, I thought they move every extra header after the payload.
>=20
> > The patch that broke it was:
> > commit 9195bb8e381d81d5a315f911904cdf0cfcc919b8
> > Author: Ansis Atteka <aatteka@nicira.com>
>=20
> I will take a hard look into that one :-).
>=20
> > --- a/net/ipv6/exthdrs_core.c     2014-02-19 16:36:22.031686037 +0100
> > +++ b/net/ipv6/exthdrs_core.c     2014-02-19 16:37:28.838082168 +0100
>=20
> If I patch my kernel:
> ard@freeze8dev:/mnt/source/kernels/build-hp-ws/l-3.13.3$ diff -u net/netf=
ilter/ipvs/ip_vs_core.c{.org,} ;diff -u net/ipv6/exthdrs_core.c{.org,}
> --- net/netfilter/ipvs/ip_vs_core.c.org 2014-01-22 14:46:53.222738221 +01=
00
> +++ net/netfilter/ipvs/ip_vs_core.c     2014-02-19 17:48:09.306379357 +01=
00
> @@ -735,7 +735,10 @@
>         struct ipv6hdr *ciph;
>         unsigned short fragoffs;
> =20
> -       ipv6_find_hdr(skb, &icmp_offset, IPPROTO_ICMPV6, &fragoffs, NULL)=
;
> +       EnterFunction(10);
> +       protocol=3Dipv6_find_hdr(skb, &icmp_offset, IPPROTO_ICMPV6, &frag=
offs, NULL);
> +       //ipv6_find_hdr(skb, &icmp_offset, -1, &fragoffs, NULL);
> +       IP_VS_DBG(15,"icmp_offset=3D%d,protocol=3D%d\n",icmp_offset,proto=
col);
>         icmph =3D (struct icmp6hdr *)(skb_network_header(skb) + icmp_offs=
et);
>         offs =3D icmp_offset + sizeof(struct icmp6hdr);
>         ciph =3D (struct ipv6hdr *)(skb_network_header(skb) + offs);
> @@ -780,6 +783,7 @@
>                 IP_VS_DBG_PKT(11, AF_INET6, pp, skb,
>                               (void *)ciph - (void *)iph,
>                               "Forwarding altered incoming ICMPv6");
> +       LeaveFunction(10);
>  }
>  #endif
> =20
> --- net/ipv6/exthdrs_core.c.org 2013-11-06 13:32:34.653688901 +0100
> +++ net/ipv6/exthdrs_core.c     2014-02-19 17:49:38.771351902 +0100
> @@ -211,6 +211,8 @@
>                 unsigned int hdrlen;
>                 found =3D (nexthdr =3D=3D target);
> =20
> +               if (found && (target > 0))
> +                       break;
>                 if ((!ipv6_ext_hdr(nexthdr)) || nexthdr =3D=3D NEXTHDR_NO=
NE) {
>                         if (target < 0)
>                                 break;
>=20
> I get this again:
> Feb 19 18:02:36 c43236 kernel: [106578.432947] IPVS: Enter: ip_vs_out, ne=
t/netfilter/ipvs/ip_vs_core.c line 1120
> Feb 19 18:02:36 c43236 kernel: [106578.432950] IPVS: Outgoing ICMPv6 (2,0=
) 2001:7b8:2ff:6f::1->2a02:310:0:1013::1005
> Feb 19 18:02:36 c43236 kernel: [106578.432954] IPVS: lookup/out TCP [2001=
:7b8:32d:0:1864:b6ff:febf:3636]:39993->[2a02:310:0:1013::1005]:80 not hit
> Feb 19 18:02:36 c43236 kernel: [106578.432956] IPVS: Incoming ICMPv6 (2,0=
) 2001:7b8:2ff:6f::1->2a02:310:0:1013::1005
> Feb 19 18:02:36 c43236 kernel: [106578.432960] IPVS: lookup/in TCP [2001:=
7b8:32d:0:1864:b6ff:febf:3636]:39993->[2a02:310:0:1013::1005]:80 hit
> Feb 19 18:02:36 c43236 kernel: [106578.432962] IPVS: Enter: ip_vs_icmp_xm=
it_v6, net/netfilter/ipvs/ip_vs_xmit.c line 1186
> Feb 19 18:02:36 c43236 kernel: [106578.432964] IPVS: Enter: ip_vs_nat_icm=
p_v6, net/netfilter/ipvs/ip_vs_core.c line 738
> Feb 19 18:02:36 c43236 kernel: [106578.432965] IPVS: icmp_offset=3D0,prot=
ocol=3D-2

This one bothers me,
Why does it returns -ENOENT ???

When enter ipv6_find_hdr() the initial nexthdr should be 0x3a ICMPv6=20
  u8 nexthdr =3D ipv6_hdr(skb)->nexthdr;
and target also 0x3a i.e. found is true and target > 0
 then break and return 3a

That didn't happen  why ?
 - Just a check did you rebuild ipv6 or if not a module the kernel ?=20


> Feb 19 18:02:36 c43236 kernel: [106578.432966] IPv6 header not found
> Feb 19 18:02:36 c43236 kernel: [106578.432969] IPVS: Leave: ip_vs_nat_icm=
p_v6, net/netfilter/ipvs/ip_vs_core.c line 786
> Feb 19 18:02:36 c43236 kernel: [106578.432974] IPVS: Leave: ip_vs_icmp_xm=
it_v6, net/netfilter/ipvs/ip_vs_xmit.c line 1263
>=20
> I will take a closer look...
>=20
> Regards,
> Ard
>=20
>=20


--=-ZToDxBMt9CAD8YK3gsKS
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Disposition: attachment; filename="smime.p7s"
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExDzANBglghkgBZQMEAgEFADCABgkqhkiG9w0BBwEAAKCCEpQw
ggYqMIIFEqADAgECAgMHnoUwDQYJKoZIhvcNAQELBQAwgYwxCzAJBgNVBAYTAklMMRYwFAYDVQQK
Ew1TdGFydENvbSBMdGQuMSswKQYDVQQLEyJTZWN1cmUgRGlnaXRhbCBDZXJ0aWZpY2F0ZSBTaWdu
aW5nMTgwNgYDVQQDEy9TdGFydENvbSBDbGFzcyAxIFByaW1hcnkgSW50ZXJtZWRpYXRlIENsaWVu
dCBDQTAeFw0xMzA5MjAwOTUwMzZaFw0xNDA5MjExNTA0MjBaMEQxHTAbBgNVBAMMFGhhbnNAc2No
aWxsc3Ryb20uY29tMSMwIQYJKoZIhvcNAQkBFhRoYW5zQHNjaGlsbHN0cm9tLmNvbTCCASIwDQYJ
KoZIhvcNAQEBBQADggEPADCCAQoCggEBALL/ObSAlvBNDHLa4GW7sNVKOHH4oKW9nE8hPTYZnlky
uV7k8LgWLMr3RMp1Pr7o6UYJj0/yCE1Wx2CzhKaj8nNTpjJ6D+QAgRdwUOVKo/dpvgq1cikSt3Ch
hY0xWkQwIem1KOwRN+sYsS1zUe5S/AnebnnYB4F55LusNcwMptmx4Yh/k1ZOaE/HdvCNJkHu86oR
qjk3pxPkfSOKUIMJB8douOAg60/l9vKL71ekDm8XNhldWlRr/oOLC0+I8KaYAbWOGCJxERurJVq+
dvt0yccMTTdcuk7qYRjPuaePoPPTKkVlAQ+wD2dNpVtlZvgvS4Cpj3+OMK/HO2kjoB5ipXUCAwEA
AaOCAtowggLWMAkGA1UdEwQCMAAwCwYDVR0PBAQDAgSwMB0GA1UdJQQWMBQGCCsGAQUFBwMCBggr
BgEFBQcDBDAdBgNVHQ4EFgQUTYliswCkaO+khvZJnUKknZWVOsEwHwYDVR0jBBgwFoAUU3Ltkpzg
2ssBXHx+ljVO8tS4UYIwHwYDVR0RBBgwFoEUaGFuc0BzY2hpbGxzdHJvbS5jb20wggFMBgNVHSAE
ggFDMIIBPzCCATsGCysGAQQBgbU3AQIDMIIBKjAuBggrBgEFBQcCARYiaHR0cDovL3d3dy5zdGFy
dHNzbC5jb20vcG9saWN5LnBkZjCB9wYIKwYBBQUHAgIwgeowJxYgU3RhcnRDb20gQ2VydGlmaWNh
dGlvbiBBdXRob3JpdHkwAwIBARqBvlRoaXMgY2VydGlmaWNhdGUgd2FzIGlzc3VlZCBhY2NvcmRp
bmcgdG8gdGhlIENsYXNzIDEgVmFsaWRhdGlvbiByZXF1aXJlbWVudHMgb2YgdGhlIFN0YXJ0Q29t
IENBIHBvbGljeSwgcmVsaWFuY2Ugb25seSBmb3IgdGhlIGludGVuZGVkIHB1cnBvc2UgaW4gY29t
cGxpYW5jZSBvZiB0aGUgcmVseWluZyBwYXJ0eSBvYmxpZ2F0aW9ucy4wNgYDVR0fBC8wLTAroCmg
J4YlaHR0cDovL2NybC5zdGFydHNzbC5jb20vY3J0dTEtY3JsLmNybDCBjgYIKwYBBQUHAQEEgYEw
fzA5BggrBgEFBQcwAYYtaHR0cDovL29jc3Auc3RhcnRzc2wuY29tL3N1Yi9jbGFzczEvY2xpZW50
L2NhMEIGCCsGAQUFBzAChjZodHRwOi8vYWlhLnN0YXJ0c3NsLmNvbS9jZXJ0cy9zdWIuY2xhc3Mx
LmNsaWVudC5jYS5jcnQwIwYDVR0SBBwwGoYYaHR0cDovL3d3dy5zdGFydHNzbC5jb20vMA0GCSqG
SIb3DQEBCwUAA4IBAQA/9pux3rgOrVzQlIi5fjPmQ3QmAB+kTA8MO3svePCgfjBmMA2W1bCwehTz
KdQLNuLMqA3/u1k3MKzVLyb8MCPilSBreuAal1akiV0C4aXebZ2gw5t0h1R88ux5b73Dtmo8K+d1
1IUiAO9KdWDbc4u4lj5jENpN5k4QiIRaxuARY3+aTF0dlgmrN8n6jPoHaGGz4OcGMua+kgnZvfEz
0BRG5L+P8BmO024qTZvsM2sxAO87aw9EK/iTkgZ+kcrSkc5uC14Tzenc0bu3yc6OdTusrzNuNBuu
U7uNT9XIz6NqJ4veoC7U0K5VQGkTm8YH6qhVARCZCPOTOAHDfOVcHYANMIIGKjCCBRKgAwIBAgID
B56FMA0GCSqGSIb3DQEBCwUAMIGMMQswCQYDVQQGEwJJTDEWMBQGA1UEChMNU3RhcnRDb20gTHRk
LjErMCkGA1UECxMiU2VjdXJlIERpZ2l0YWwgQ2VydGlmaWNhdGUgU2lnbmluZzE4MDYGA1UEAxMv
U3RhcnRDb20gQ2xhc3MgMSBQcmltYXJ5IEludGVybWVkaWF0ZSBDbGllbnQgQ0EwHhcNMTMwOTIw
MDk1MDM2WhcNMTQwOTIxMTUwNDIwWjBEMR0wGwYDVQQDDBRoYW5zQHNjaGlsbHN0cm9tLmNvbTEj
MCEGCSqGSIb3DQEJARYUaGFuc0BzY2hpbGxzdHJvbS5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IB
DwAwggEKAoIBAQCy/zm0gJbwTQxy2uBlu7DVSjhx+KClvZxPIT02GZ5ZMrle5PC4FizK90TKdT6+
6OlGCY9P8ghNVsdgs4Smo/JzU6Yyeg/kAIEXcFDlSqP3ab4KtXIpErdwoYWNMVpEMCHptSjsETfr
GLEtc1HuUvwJ3m552AeBeeS7rDXMDKbZseGIf5NWTmhPx3bwjSZB7vOqEao5N6cT5H0jilCDCQfH
aLjgIOtP5fbyi+9XpA5vFzYZXVpUa/6DiwtPiPCmmAG1jhgicREbqyVavnb7dMnHDE03XLpO6mEY
z7mnj6Dz0ypFZQEPsA9nTaVbZWb4L0uAqY9/jjCvxztpI6AeYqV1AgMBAAGjggLaMIIC1jAJBgNV
HRMEAjAAMAsGA1UdDwQEAwIEsDAdBgNVHSUEFjAUBggrBgEFBQcDAgYIKwYBBQUHAwQwHQYDVR0O
BBYEFE2JYrMApGjvpIb2SZ1CpJ2VlTrBMB8GA1UdIwQYMBaAFFNy7ZKc4NrLAVx8fpY1TvLUuFGC
MB8GA1UdEQQYMBaBFGhhbnNAc2NoaWxsc3Ryb20uY29tMIIBTAYDVR0gBIIBQzCCAT8wggE7Bgsr
BgEEAYG1NwECAzCCASowLgYIKwYBBQUHAgEWImh0dHA6Ly93d3cuc3RhcnRzc2wuY29tL3BvbGlj
eS5wZGYwgfcGCCsGAQUFBwICMIHqMCcWIFN0YXJ0Q29tIENlcnRpZmljYXRpb24gQXV0aG9yaXR5
MAMCAQEagb5UaGlzIGNlcnRpZmljYXRlIHdhcyBpc3N1ZWQgYWNjb3JkaW5nIHRvIHRoZSBDbGFz
cyAxIFZhbGlkYXRpb24gcmVxdWlyZW1lbnRzIG9mIHRoZSBTdGFydENvbSBDQSBwb2xpY3ksIHJl
bGlhbmNlIG9ubHkgZm9yIHRoZSBpbnRlbmRlZCBwdXJwb3NlIGluIGNvbXBsaWFuY2Ugb2YgdGhl
IHJlbHlpbmcgcGFydHkgb2JsaWdhdGlvbnMuMDYGA1UdHwQvMC0wK6ApoCeGJWh0dHA6Ly9jcmwu
c3RhcnRzc2wuY29tL2NydHUxLWNybC5jcmwwgY4GCCsGAQUFBwEBBIGBMH8wOQYIKwYBBQUHMAGG
LWh0dHA6Ly9vY3NwLnN0YXJ0c3NsLmNvbS9zdWIvY2xhc3MxL2NsaWVudC9jYTBCBggrBgEFBQcw
AoY2aHR0cDovL2FpYS5zdGFydHNzbC5jb20vY2VydHMvc3ViLmNsYXNzMS5jbGllbnQuY2EuY3J0
MCMGA1UdEgQcMBqGGGh0dHA6Ly93d3cuc3RhcnRzc2wuY29tLzANBgkqhkiG9w0BAQsFAAOCAQEA
P/absd64Dq1c0JSIuX4z5kN0JgAfpEwPDDt7L3jwoH4wZjANltWwsHoU8ynUCzbizKgN/7tZNzCs
1S8m/DAj4pUga3rgGpdWpIldAuGl3m2doMObdIdUfPLseW+9w7ZqPCvnddSFIgDvSnVg23OLuJY+
YxDaTeZOEIiEWsbgEWN/mkxdHZYJqzfJ+oz6B2hhs+DnBjLmvpIJ2b3xM9AURuS/j/AZjtNuKk2b
7DNrMQDvO2sPRCv4k5IGfpHK0pHObgteE83p3NG7t8nOjnU7rK8zbjQbrlO7jU/VyM+jaieL3qAu
1NCuVUBpE5vGB+qoVQEQmQjzkzgBw3zlXB2ADTCCBjQwggQcoAMCAQICAR4wDQYJKoZIhvcNAQEF
BQAwfTELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3Vy
ZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcxKTAnBgNVBAMTIFN0YXJ0Q29tIENlcnRpZmlj
YXRpb24gQXV0aG9yaXR5MB4XDTA3MTAyNDIxMDE1NVoXDTE3MTAyNDIxMDE1NVowgYwxCzAJBgNV
BAYTAklMMRYwFAYDVQQKEw1TdGFydENvbSBMdGQuMSswKQYDVQQLEyJTZWN1cmUgRGlnaXRhbCBD
ZXJ0aWZpY2F0ZSBTaWduaW5nMTgwNgYDVQQDEy9TdGFydENvbSBDbGFzcyAxIFByaW1hcnkgSW50
ZXJtZWRpYXRlIENsaWVudCBDQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMcJg8zO
LdgasSmkLhOrlr6KMoOMpohBllVHrdRvEg/q6r8jR+EK75xCGhR8ToREoqe7zM9/UnC6TS2y9UKT
pT1v7RSMzR0t6ndl0TWBuUr/UXBhPk+Kmy7bI4yW4urC+y7P3/1/X7U8ocb8VpH/Clt+4iq7nirM
cNh6qJR+xjOhV+VHzQMALuGYn5KZmc1NbJQYclsGkDxDz2UbFqE2+6vIZoL+jb9x4Pa5gNf1TwSD
kOkikZB1xtB4ZqtXThaABSONdfmv/Z1pua3FYxnCFmdr/+N2JLKutIxMYqQOJebr/f/h5t95m4Jg
rM3Y/w7YX9d7YAL9jvN4SydHsU6n65cCAwEAAaOCAa0wggGpMA8GA1UdEwEB/wQFMAMBAf8wDgYD
VR0PAQH/BAQDAgEGMB0GA1UdDgQWBBRTcu2SnODaywFcfH6WNU7y1LhRgjAfBgNVHSMEGDAWgBRO
C+8apEBbpRdphzDKNGhD0EGu8jBmBggrBgEFBQcBAQRaMFgwJwYIKwYBBQUHMAGGG2h0dHA6Ly9v
Y3NwLnN0YXJ0c3NsLmNvbS9jYTAtBggrBgEFBQcwAoYhaHR0cDovL3d3dy5zdGFydHNzbC5jb20v
c2ZzY2EuY3J0MFsGA1UdHwRUMFIwJ6AloCOGIWh0dHA6Ly93d3cuc3RhcnRzc2wuY29tL3Nmc2Nh
LmNybDAnoCWgI4YhaHR0cDovL2NybC5zdGFydHNzbC5jb20vc2ZzY2EuY3JsMIGABgNVHSAEeTB3
MHUGCysGAQQBgbU3AQIBMGYwLgYIKwYBBQUHAgEWImh0dHA6Ly93d3cuc3RhcnRzc2wuY29tL3Bv
bGljeS5wZGYwNAYIKwYBBQUHAgEWKGh0dHA6Ly93d3cuc3RhcnRzc2wuY29tL2ludGVybWVkaWF0
ZS5wZGYwDQYJKoZIhvcNAQEFBQADggIBAAqDCH14qywGXLhjjF6uHLkjd02hcdh9hrw+VUsv+q1e
eQWB21jWj3kJ96AUlPCoEGZ/ynJNScWy6QMVQjbbMXltUfO4n4bGGdKo3awPWp61tjAFgraLJgDk
+DsSvUD6EowjMTNx25GQgyYJ5RPIzKKR9tQW8gGK+2+RHxkUCTbYFnL6kl8Ch507rUdPPipJ9CgJ
Fws3kDS3gOS5WFMxcjO5DwKfKSETEPrHh7p5shuuNktvsv6hxHTLhiMKX893gxdT3XLS9OKmCv87
vkINQcNEcIIoFWbP9HORz9v3vQwR4e3ksLc2JZOAFK+ssS5XMEoznzpihEP0PLc4dCBYjbvSD7kx
gDwZ+Aj8Q9PkbvE9sIPP7ON0fz095HdThKjiVJe6vofq+n6b1NBc8XdrQvBmunwxD5nvtTW4vtN6
VY7mUCmxsCieuoBJ9OlqmsVWQvifIYf40dJPZkk9YgGTzWLpXDSfLSplbY2LL9C9U0ptvjcDjefL
TvqSFc7tw1sEhF0n/qpA2r0GpvkLRDmcSwVyPvmjFBGqUp/pNy8ZuPGQmHwFi2/14+xeSUDG2bwn
sYJQG2EdJCB6luQ57GEnTA/yKZSTKI8dDQa8Sd3zfXb19mOgSF0bBdXbuKhEpuP9wirslFe6fQ1t
5j5R0xi72MZ8ikMu1RQZKCyDbMwazlHiMYIDfzCCA3sCAQEwgZQwgYwxCzAJBgNVBAYTAklMMRYw
FAYDVQQKEw1TdGFydENvbSBMdGQuMSswKQYDVQQLEyJTZWN1cmUgRGlnaXRhbCBDZXJ0aWZpY2F0
ZSBTaWduaW5nMTgwNgYDVQQDEy9TdGFydENvbSBDbGFzcyAxIFByaW1hcnkgSW50ZXJtZWRpYXRl
IENsaWVudCBDQQIDB56FMA0GCWCGSAFlAwQCAQUAoIIBuzAYBgkqhkiG9w0BCQMxCwYJKoZIhvcN
AQcBMBwGCSqGSIb3DQEJBTEPFw0xNDAyMTkyMDI4MzhaMC8GCSqGSIb3DQEJBDEiBCAs9tV70hai
7epUvaNH+gWSKEN14qhLf4gDGd/RiQebfjCBpQYJKwYBBAGCNxAEMYGXMIGUMIGMMQswCQYDVQQG
EwJJTDEWMBQGA1UEChMNU3RhcnRDb20gTHRkLjErMCkGA1UECxMiU2VjdXJlIERpZ2l0YWwgQ2Vy
dGlmaWNhdGUgU2lnbmluZzE4MDYGA1UEAxMvU3RhcnRDb20gQ2xhc3MgMSBQcmltYXJ5IEludGVy
bWVkaWF0ZSBDbGllbnQgQ0ECAweehTCBpwYLKoZIhvcNAQkQAgsxgZeggZQwgYwxCzAJBgNVBAYT
AklMMRYwFAYDVQQKEw1TdGFydENvbSBMdGQuMSswKQYDVQQLEyJTZWN1cmUgRGlnaXRhbCBDZXJ0
aWZpY2F0ZSBTaWduaW5nMTgwNgYDVQQDEy9TdGFydENvbSBDbGFzcyAxIFByaW1hcnkgSW50ZXJt
ZWRpYXRlIENsaWVudCBDQQIDB56FMA0GCSqGSIb3DQEBAQUABIIBABXIcesmQerfPOFDbLl58lzn
yKh+Rn6zY50FyzfyYufWOvuAsBhI9kDiU/up7Fra9+/gW1miafVHZAmnZydoAJvOtCjbNLSz30wy
51q7pDGt261VuAM5DjTx+HGuDe/QISDn13bl9gkYoektpzwS6oTLDlSCw9NuJA1dJgCmn6pj4k9M
UkhG9N1H+MsuLH1dGCw/8804GlE5eC2unOEdOBG3jVf4ppdsNmvPLMEqg2S3qqo94d1JhG7YkHz+
CWXNfb7a8x48zv4pmLtpDgM8fAObkWZBW41SgmETXK0c9SZksQXvdp3Is9nF351A0fNpgZ1zUQeR
C2yDIA5HGzdkiAcAAAAAAAA=


--=-ZToDxBMt9CAD8YK3gsKS--

