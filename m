From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: [PATCH] ipvs: fix ipv6 icmp forwarding in natted services
Date: Fri, 21 Feb 2014 06:46:41 +0100
Message-ID: <1392961601.5821.499.camel@hawk.mlab.se>
References: <alpine.LFD.2.11.1402172321200.2420@ja.home.ssi.bg>
	 <20140218100533.GE18029@telegraafnet.nl>
	 <20140218133725.GA20771@telegraafnet.nl>
	 <20140218135439.GB20771@telegraafnet.nl>
	 <alpine.LFD.2.11.1402182225560.2011@ja.home.ssi.bg>
	 <20140219102751.GD20771@telegraafnet.nl>
	 <1392825857.5821.422.camel@hawk.mlab.se>
	 <alpine.LFD.2.11.1402192254040.1889@ja.home.ssi.bg>
	 <1392847723.5821.474.camel@hawk.mlab.se>
	 <20140220131044.GP20771@telegraafnet.nl>
	 <20140220185619.GA4048@telegraafnet.nl>
	 <alpine.LFD.2.11.1402202350280.2732@ja.home.ssi.bg>
Reply-To: hans@schillstrom.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="sha256";
	protocol="application/x-pkcs7-signature";
	boundary="=-ICszbF9kSBiQh2mksVGz"
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.11.1402202350280.2732@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Cc: Art -kwaak- van Breemen <ard@telegraafnet.nl>, Ansis Atteka <aatteka@nicira.com>, lvs-devel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, Patrick McHardy <kaber@trash.net>


--=-ICszbF9kSBiQh2mksVGz
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: quoted-printable

Hello

On Fri, 2014-02-21 at 00:17 +0200, Julian Anastasov wrote:
> 	Hello,
>=20
> On Thu, 20 Feb 2014, Art -kwaak- van Breemen wrote:
>=20
> > I ack the working of that change for my specific case: passing
> > pmtud's correctly:
> > Feb 20 18:58:59 c43236 kernel: [  721.473388] IPVS: Enter: ip_vs_icmp_x=
mit_v6, net/netfilter/ipvs/ip_vs_xmit.c line 1186
> > Feb 20 18:58:59 c43236 kernel: [  721.473389] IPVS: Enter: ip_vs_nat_ic=
mp_v6, net/netfilter/ipvs/ip_vs_core.c line 738
> > Feb 20 18:58:59 c43236 kernel: [  721.473390] IPVS: icmp_offset=3D40,pr=
otocol=3D58
> > Feb 20 18:58:59 c43236 kernel: [  721.473391] IPVS: ip_vs_nat_icmp_v6()=
 changed port 80 to 80
> > Feb 20 18:58:59 c43236 kernel: [  721.473393] IPVS: Leave: ip_vs_nat_ic=
mp_v6, net/netfilter/ipvs/ip_vs_core.c line 786
> > Feb 20 18:58:59 c43236 kernel: [  721.473396] IPVS: Leave: ip_vs_icmp_x=
mit_v6, net/netfilter/ipvs/ip_vs_xmit.c line 1263
> >=20
> > and:
> > 18:58:59.067282 00:23:24:26:b4:5c > 00:23:24:26:b4:34, ethertype IPv6 (=
0x86dd), length 1294: 2001:7b8:2ff:6f::1 > 2a02:310:0:1013::1003: ICMP6, pa=
cket too big, mtu 1472, length 1240
> >=20
> > So the "|| found" sounds sane.
>=20
> 	Thanks for the confirmation. Then may be Hans
> can post a fix for this problem after checking the callers
> of ipv6_find_hdr.

I'll do that.

>=20
> > But now I'm going to be an ass by saying that maybe both patches must b=
e
> > applied because we only get into ip_vs_nat_icmp_v6 by ip_vs_fill_iph_sk=
b in
> > include/net/ip_vs.h, which determines the protocol and the start of the
> > protocol header by using -1 as target in ipv6_find_hdr.
> > Actually, before we reach that nat function we have traversed several c=
onstructs of:
> > protocol,offset =3D ipv6_find_hdr (target =3D -1 )
> > if ( protocol !=3D IPPROTO_ICMPV6)
> >   bail out (return NF_ACCEPT actually) .
>=20
> 	Yes, it is not expected, the protocol was
> already validated. May be we will save some cycles
> without such check...

We will save some cycles here, very few actually..
I'm not sure about the mobility header if it can break this.
Have not read the RFC :-)

The -1 is OK for me right now

> > (and maybe use offset)
> >=20
> > So I think it's clearer for the total code if we follow the exact same =
construct:
> > find a protocol, bail out if protocol wrong.
> > It should never happen at that point, but there are more things that ne=
ver
> > should happen :-).
> >=20
> > Anyway: whatever you guys decide, I owe you all beer. I think we are on=
e of the
> > few companies that assume a working pmtud for ipv6. Most of the top com=
panies
> > just use an mtu of 1280 because the "hardware" loadbalancer cannot hand=
le it
> > (yet) or just want to prevent the hassle. Thanks!
> >=20
> > Regards,
> >=20
> > Ard van Breemen
>=20
> Regards
>=20
> --
> Julian Anastasov <ja@ssi.bg>

Regards
Hans

--=-ICszbF9kSBiQh2mksVGz
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
AQcBMBwGCSqGSIb3DQEJBTEPFw0xNDAyMjEwNTQ2NDFaMC8GCSqGSIb3DQEJBDEiBCCPJ7p4C/C/
S+UVY9g+7SHoLmqJlTOXhWEgUiN/L9bG6DCBpQYJKwYBBAGCNxAEMYGXMIGUMIGMMQswCQYDVQQG
EwJJTDEWMBQGA1UEChMNU3RhcnRDb20gTHRkLjErMCkGA1UECxMiU2VjdXJlIERpZ2l0YWwgQ2Vy
dGlmaWNhdGUgU2lnbmluZzE4MDYGA1UEAxMvU3RhcnRDb20gQ2xhc3MgMSBQcmltYXJ5IEludGVy
bWVkaWF0ZSBDbGllbnQgQ0ECAweehTCBpwYLKoZIhvcNAQkQAgsxgZeggZQwgYwxCzAJBgNVBAYT
AklMMRYwFAYDVQQKEw1TdGFydENvbSBMdGQuMSswKQYDVQQLEyJTZWN1cmUgRGlnaXRhbCBDZXJ0
aWZpY2F0ZSBTaWduaW5nMTgwNgYDVQQDEy9TdGFydENvbSBDbGFzcyAxIFByaW1hcnkgSW50ZXJt
ZWRpYXRlIENsaWVudCBDQQIDB56FMA0GCSqGSIb3DQEBAQUABIIBAGBSAAE/kaVxIAAG4Rn9BKxd
rg4YXhiTnPT33ervdNh+N0xhGv/dp4/w5SX0qv3Os3Rri1zF70N4LE7HpAP8XNOWVMHO9IJc5yUu
fQEuL+A8C/CUzgQpx5i+NNVBSQJIl3fuX/bGVBbu70o5RhPuIRZ1rpvSjWqJUgy2Vbg7sW7vC+ww
Dq1O+OTbggheqgPxrXPUSAphB/8Xeu1sY9E+3gouRnDRg8nwOonFQVko1yr6LP39c1TCARL0iujY
W9li5j8+YOC/fQr4E68hXLpfrZfRv9tfvycvS63W+3EiUyHM0P1xHcYwVm9ln9V1PUUInO2bD9QQ
JWI4Jb+yYHs9rmEAAAAAAAA=


--=-ICszbF9kSBiQh2mksVGz--

