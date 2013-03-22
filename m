From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: [PATCHv3 net-next 00/15] IPVS optimizations
Date: Fri, 22 Mar 2013 10:54:23 +0100
Message-ID: <1363946063.14162.20.camel@hawk.mlab.se>
References: <1363859892-9058-1-git-send-email-ja@ssi.bg>
Reply-To: hans@schillstrom.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="sha1"; protocol="application/x-pkcs7-signature";
	boundary="=-FsC8S4G5ZZkrRohmTqy9"
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1363859892-9058-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org


--=-FsC8S4G5ZZkrRohmTqy9
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hello Julian
Great work!

On Thu, 2013-03-21 at 11:57 +0200, Julian Anastasov wrote:
> 	This is a first patchset for IPVS optimizations.
> Another patchset will address the locking in schedulers
> and moving the global _bh disabling from LOCAL_OUT to all
> locks.
>=20
> 	All patches are for net-next and Simon can
> take them for ipvs-next.
>=20
> 	The changes in this patchset eliminate locks
> and dst refcnt operations from packet processing by
> using RCU. There are more details in the patches.

I've gone through all patches and tested them now
it looks very promising, all my tests have passed.

Signed-off by: Hans Schillstrom <hans@schillstrom.com>

> v3:
> * in "ipvs: consolidate all dst checks on transmit in one place"
>   preserve original skb dst even for local client, remove the
>   rt_is_input_route and skb->dev check. Call update_pmtu only for
>   local client by providing sk instead of skb.
> * in "ipvs: optimize dst usage for real server" use
>   rcu_dereference_protected for __ip_vs_dst_cache_reset instead of
>   rcu_dereference_raw. Use the new skb_dst_set_noref_force func.
> * in "ipvs: remove rs_lock by using RCU" prefer the port check in
>   ip_vs_has_real_service
> * "ipvs: convert locks used in persistence engines" needs only
>   synchronize_rcu, not rcu_barrier, we do not use rcu callbacks
>=20
> v2:
> * use "net: add skb_dst_set_unref" instead of
>   "net: add dst_get_noref and refdst_ptr helpers"
> * add "ipvs: no need to reroute anymore on DNAT over loopback"
> * add "ipvs: do not use skb_share_check"
> * add "ipvs: consolidate all dst checks on transmit in one place", so
>   that we can avoid the refdst games in next patch
> * after "ipvs: consolidate all dst checks on transmit in one place"
>   "ipvs: optimize dst usage for real server" is simpler and
>   uses the new skb_dst_set_unref function
> * extend "ipvs: reorder keys in connection structure" with
>   changes in ip_vs_ct_in_get
> * fix "ipvs: avoid kmem_cache_zalloc in ip_vs_conn_new" to use new
>   function ip_vs_addr_set, so that we reset all address fields
>   that are used for hashing by hash_conntrack_raw
>=20
> Julian Anastasov (15):
>   net: add skb_dst_set_noref_force
>   ipvs: avoid routing by TOS for real server
>   ipvs: prefer NETDEV_DOWN event to free cached dsts
>   ipvs: convert the IP_VS_XMIT macros to functions
>   ipvs: rename functions related to dst_cache reset
>   ipvs: no need to reroute anymore on DNAT over loopback
>   ipvs: do not use skb_share_check
>   ipvs: consolidate all dst checks on transmit in one place
>   ipvs: optimize dst usage for real server
>   ipvs: convert app locks
>   ipvs: remove rs_lock by using RCU
>   ipvs: convert locks used in persistence engines
>   ipvs: convert connection locking
>   ipvs: reorder keys in connection structure
>   ipvs: avoid kmem_cache_zalloc in ip_vs_conn_new
>=20
>  include/linux/skbuff.h                |   35 ++-
>  include/net/ip_vs.h                   |   71 ++-
>  net/core/dst.c                        |    9 +-
>  net/netfilter/ipvs/ip_vs_app.c        |   27 +-
>  net/netfilter/ipvs/ip_vs_conn.c       |  271 +++++----
>  net/netfilter/ipvs/ip_vs_core.c       |   16 +-
>  net/netfilter/ipvs/ip_vs_ctl.c        |  143 +++---
>  net/netfilter/ipvs/ip_vs_ftp.c        |    2 +
>  net/netfilter/ipvs/ip_vs_pe.c         |   43 +-
>  net/netfilter/ipvs/ip_vs_pe_sip.c     |    1 +
>  net/netfilter/ipvs/ip_vs_proto_sctp.c |   18 +-
>  net/netfilter/ipvs/ip_vs_proto_tcp.c  |   18 +-
>  net/netfilter/ipvs/ip_vs_proto_udp.c  |   19 +-
>  net/netfilter/ipvs/ip_vs_xmit.c       | 1046 ++++++++++++++-------------=
------
>  14 files changed, 810 insertions(+), 909 deletions(-)
>=20


--=-FsC8S4G5ZZkrRohmTqy9
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
hvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTMwMzIyMDk1NDIzWjAjBgkqhkiG
9w0BCQQxFgQUXE8TgxTOFNB25K6ld97Lup8zH+IwgaUGCSsGAQQBgjcQBDGBlzCBlDCBjDELMAkG
A1UEBhMCSUwxFjAUBgNVBAoTDVN0YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFs
IENlcnRpZmljYXRlIFNpZ25pbmcxODA2BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJ
bnRlcm1lZGlhdGUgQ2xpZW50IENBAgME/1UwgacGCyqGSIb3DQEJEAILMYGXoIGUMIGMMQswCQYD
VQQGEwJJTDEWMBQGA1UEChMNU3RhcnRDb20gTHRkLjErMCkGA1UECxMiU2VjdXJlIERpZ2l0YWwg
Q2VydGlmaWNhdGUgU2lnbmluZzE4MDYGA1UEAxMvU3RhcnRDb20gQ2xhc3MgMSBQcmltYXJ5IElu
dGVybWVkaWF0ZSBDbGllbnQgQ0ECAwT/VTANBgkqhkiG9w0BAQEFAASCAQArTKeFG0Vco134YNve
7ZNJTeDx8USLvhyHLJt+NfpErsbLMm6L7sG9FRF4QlIJSm4jxcLOMDTGFsE3oCCdzw2G4BXqNPTL
EV39QtUifJ5uD84/30Yr6/qAvq9vtZOfkXujO7l40HBi5stqEXTPiPvzIRRSQ21HGhWP0Cmt5eNq
i4g1in8dVOrDDh65KULct3qK83s4cN56JQSjmtF4Pndat5htyTYSAjUceKtS4m0scoh7mGKo/C4B
iFqY1XddczgYfCrM9TgWjGuaRf+73Pz361wFnLA2iwdkyvBg00C85wId/UYCgzz+zQpK9XEaiO46
/hcK9t72mPyYl3hgW9qxAAAAAAAA


--=-FsC8S4G5ZZkrRohmTqy9--

