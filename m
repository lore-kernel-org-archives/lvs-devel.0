From: Raducu Deaconu <rhadoo.io88@gmail.com>
Subject: Re: ovf scheduler
Date: Thu, 16 Jul 2015 14:06:08 +0300
Message-ID: <CAA0i4BrKP91wiFOWpPpmFP3L1ZdVCPTdDk6PkJrGYGPWkqpxxw@mail.gmail.com>
References: <CAA0i4Bp0n-PooNaUq=F7MgD2Ou8=hdA6w+B0te5tcWP4ODxTfw@mail.gmail.com>
	<alpine.LFD.2.11.1507132328500.1708@ja.home.ssi.bg>
	<CAA0i4Bph-Gw00+-kUovvvfSgEta6XEH2-hGtSnusuPNdro2nCA@mail.gmail.com>
	<alpine.LFD.2.11.1507142152450.1833@ja.home.ssi.bg>
	<CAA0i4Bo3w3msK9Tdn1T3BNa-ZyQ6mon=XeXFRkSfsWHRVEua=w@mail.gmail.com>
	<alpine.LFD.2.11.1507161044500.1681@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=089e0158b6c8f668b8051afc0e1b
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:in-reply-to:references:date:message-id:subject:from:to
         :cc:content-type;
        bh=OF4oU8LY6BuBN3CDJPOafORWmfKO1vWyQD4gwp32gnY=;
        b=AHbzwms/eq/8Q+NX41WdqK0Wu4Kn7RKmdJJfpIRheCVO1sjRRExmYZTtufhHpVwdMq
         ROhdUEY+7t7a5g97WpYpnezy02oUjCOIpTTOEudKSjWLhCO3MqK3UofMJPUhfrMdpMQ9
         dhLi1/UwaYr7/ne4oNsQKjQG0tGeCe9h4rbHKsayGRuyQ5eHbC8SM+ykT4+odinAJvqu
         bcTv/C0BDMMwsDmG1Fdek4KpaRRkuL27QLnJwvkqXrDsV4t9n9d5NbQgKPTBqw+uFQNT
         BmWVeA104iaslrTc14XXKegBK/v+L59imTULf8vGkV6YtEoglaD+g20hT0zN/uyppe7y
         GHsw==
In-Reply-To: <alpine.LFD.2.11.1507161044500.1681@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

--089e0158b6c8f668b8051afc0e1b
Content-Type: text/plain; charset=UTF-8

Hello,

I have readjusted the patch, sorry for the code style issues, this is
my first attempt at a contribution.




Subject: [PATCH] ipvs: Add ovf scheduler

Signed-off-by: Raducu Deaconu <rhadoo.io88@gmail.com>
---
 net/netfilter/ipvs/Kconfig     |   11 +++++
 net/netfilter/ipvs/Makefile    |    1 +
 net/netfilter/ipvs/ip_vs_ovf.c |   86 ++++++++++++++++++++++++++++++++++++++++
 3 files changed, 98 insertions(+)
 create mode 100644 net/netfilter/ipvs/ip_vs_ovf.c

diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
index 3b6929d..b32fb0d 100644
--- a/net/netfilter/ipvs/Kconfig
+++ b/net/netfilter/ipvs/Kconfig
@@ -162,6 +162,17 @@ config  IP_VS_FO
          If you want to compile it in kernel, say Y. To compile it as a
          module, choose M here. If unsure, say N.

+config  IP_VS_OVF
+       tristate "weighted overflow scheduling"
+       ---help---
+         The weighted overflow scheduling algorithm directs network
+         connections to the server with the highest weight that is
+         currently available and overflows to the next when active
+         connections exceed the node's weight.
+
+         If you want to compile it in kernel, say Y. To compile it as a
+         module, choose M here. If unsure, say N.
+
 config IP_VS_LBLC
        tristate "locality-based least-connection scheduling"
        ---help---
diff --git a/net/netfilter/ipvs/Makefile b/net/netfilter/ipvs/Makefile
index 38b2723..67f3f43 100644
--- a/net/netfilter/ipvs/Makefile
+++ b/net/netfilter/ipvs/Makefile
@@ -27,6 +27,7 @@ obj-$(CONFIG_IP_VS_WRR) += ip_vs_wrr.o
 obj-$(CONFIG_IP_VS_LC) += ip_vs_lc.o
 obj-$(CONFIG_IP_VS_WLC) += ip_vs_wlc.o
 obj-$(CONFIG_IP_VS_FO) += ip_vs_fo.o
+obj-$(CONFIG_IP_VS_OVF) += ip_vs_ovf.o
 obj-$(CONFIG_IP_VS_LBLC) += ip_vs_lblc.o
 obj-$(CONFIG_IP_VS_LBLCR) += ip_vs_lblcr.o
 obj-$(CONFIG_IP_VS_DH) += ip_vs_dh.o
diff --git a/net/netfilter/ipvs/ip_vs_ovf.c b/net/netfilter/ipvs/ip_vs_ovf.c
new file mode 100644
index 0000000..3478b0d
--- /dev/null
+++ b/net/netfilter/ipvs/ip_vs_ovf.c
@@ -0,0 +1,86 @@
+/*
+ * IPVS:        Overflow-Connection Scheduling module
+ *
+ * Authors:     Raducu Deaconu <rhadoo_io@yahoo.com>
+ *
+ *              This program is free software; you can redistribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ *
+ * Scheduler implements "overflow" loadbalancing according to number of active
+ * connections , will keep all conections to the node with the highest weight
+ * and overflow to the next node if the number of connections exceeds
the node's
+ * weight.
+ * Note that this scheduler might not be suitable for UDP because it only uses
+ * active connections
+ *
+ */
+
+#define KMSG_COMPONENT "IPVS"
+#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+
+#include <net/ip_vs.h>
+
+/* OVF Connection scheduling  */
+static struct ip_vs_dest *
+ip_vs_ovf_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
+                  struct ip_vs_iphdr *iph)
+{
+       struct ip_vs_dest *dest, *h = NULL;
+       int hw = 0, w;
+
+       IP_VS_DBG(6, "ip_vs_ovf_schedule(): Scheduling...\n");
+       /* select the node with highest weight, go to next in line if active
+       * connections exceed weight
+       */
+       list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
+               w = atomic_read(&dest->weight);
+               if ((dest->flags & IP_VS_DEST_F_OVERLOAD) ||
+                   atomic_read(&dest->activeconns) > w ||
+                   w == 0)
+                       continue;
+               if (!h || w > hw) {
+                       h = dest;
+                       hw = w;
+               }
+       }
+
+               if (h) {
+                       IP_VS_DBG_BUF(6, "OVF: server %s:%u active %d w %d\n",
+                                     IP_VS_DBG_ADDR(svc->af, &h->addr),
+                                     ntohs(h->port),
+                                     atomic_read(&h->activeconns),
+                                     atomic_read(&h->weight));
+               return h;
+               }
+
+       ip_vs_scheduler_err(svc, "no destination available");
+       return NULL;
+}
+
+static struct ip_vs_scheduler ip_vs_ovf_scheduler = {
+       .name =                 "ovf",
+       .refcnt =               ATOMIC_INIT(0),
+       .module =               THIS_MODULE,
+       .n_list =               LIST_HEAD_INIT(ip_vs_ovf_scheduler.n_list),
+       .schedule =             ip_vs_ovf_schedule,
+};
+
+static int __init ip_vs_ovf_init(void)
+{
+       return register_ip_vs_scheduler(&ip_vs_ovf_scheduler);
+}
+
+static void __exit ip_vs_ovf_cleanup(void)
+{
+       unregister_ip_vs_scheduler(&ip_vs_ovf_scheduler);
+       synchronize_rcu();
+}
+
+module_init(ip_vs_ovf_init);
+module_exit(ip_vs_ovf_cleanup);
+MODULE_LICENSE("GPL");
-- 
1.7.10.4

On Thu, Jul 16, 2015 at 10:56 AM, Julian Anastasov <ja@ssi.bg> wrote:
>
>         Hello,
>
> On Thu, 16 Jul 2015, Raducu Deaconu wrote:
>
>> Hi,
>> I have updated the code and generated the patch, according to your indications.
>
>         When patch is attached it is difficult to
> comment it. Anyways, I'll try.
>
> - The Subject should include "ipvs: ",
> eg. Subject: [PATCH] ipvs: add ovf scheduler
>
> - In Kconfig the "tristate..." line has wrong indentation,
> one tab should be removed
>
> - When debugging is enabled (CONFIG_IP_VS_DEBUG=y) the module
> does not compile, you can also use short var names, eg:
>
>         struct ip_vs_dest *dest, *h = NULL;
>         int hw = 0, w;
>
> - the comment block "select the node..." has one empty line
> at end, should be removed
>
> - the 'if ...' blocks in the loop are not properly indented
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>

--089e0158b6c8f668b8051afc0e1b
Content-Type: text/x-patch; charset=US-ASCII; name="addovf.patch"
Content-Disposition: attachment; filename="addovf.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ic6332et0

RnJvbSA1ZWVjYWU3NWRkOThkMTZjMzBjMmFiOTgzZTgxNmVhOTRjMzA3ZmE4IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBSYWR1Y3UgRGVhY29udSA8cmhhZG9vLmlvODhAZ21haWwuY29t
PgpEYXRlOiBUaHUsIDE2IEp1bCAyMDE1IDEzOjU2OjIzICswMzAwClN1YmplY3Q6IFtQQVRDSF0g
aXB2czogQWRkIG92ZiBzY2hlZHVsZXIKClNpZ25lZC1vZmYtYnk6IFJhZHVjdSBEZWFjb251IDxy
aGFkb28uaW84OEBnbWFpbC5jb20+Ci0tLQogbmV0L25ldGZpbHRlci9pcHZzL0tjb25maWcgICAg
IHwgICAxMSArKysrKwogbmV0L25ldGZpbHRlci9pcHZzL01ha2VmaWxlICAgIHwgICAgMSArCiBu
ZXQvbmV0ZmlsdGVyL2lwdnMvaXBfdnNfb3ZmLmMgfCAgIDg2ICsrKysrKysrKysrKysrKysrKysr
KysrKysrKysrKysrKysrKysrKysKIDMgZmlsZXMgY2hhbmdlZCwgOTggaW5zZXJ0aW9ucygrKQog
Y3JlYXRlIG1vZGUgMTAwNjQ0IG5ldC9uZXRmaWx0ZXIvaXB2cy9pcF92c19vdmYuYwoKZGlmZiAt
LWdpdCBhL25ldC9uZXRmaWx0ZXIvaXB2cy9LY29uZmlnIGIvbmV0L25ldGZpbHRlci9pcHZzL0tj
b25maWcKaW5kZXggM2I2OTI5ZC4uYjMyZmIwZCAxMDA2NDQKLS0tIGEvbmV0L25ldGZpbHRlci9p
cHZzL0tjb25maWcKKysrIGIvbmV0L25ldGZpbHRlci9pcHZzL0tjb25maWcKQEAgLTE2Miw2ICsx
NjIsMTcgQEAgY29uZmlnICBJUF9WU19GTwogCSAgSWYgeW91IHdhbnQgdG8gY29tcGlsZSBpdCBp
biBrZXJuZWwsIHNheSBZLiBUbyBjb21waWxlIGl0IGFzIGEKIAkgIG1vZHVsZSwgY2hvb3NlIE0g
aGVyZS4gSWYgdW5zdXJlLCBzYXkgTi4KIAorY29uZmlnICBJUF9WU19PVkYKKwl0cmlzdGF0ZSAi
d2VpZ2h0ZWQgb3ZlcmZsb3cgc2NoZWR1bGluZyIKKwktLS1oZWxwLS0tCisJICBUaGUgd2VpZ2h0
ZWQgb3ZlcmZsb3cgc2NoZWR1bGluZyBhbGdvcml0aG0gZGlyZWN0cyBuZXR3b3JrCisJICBjb25u
ZWN0aW9ucyB0byB0aGUgc2VydmVyIHdpdGggdGhlIGhpZ2hlc3Qgd2VpZ2h0IHRoYXQgaXMKKwkg
IGN1cnJlbnRseSBhdmFpbGFibGUgYW5kIG92ZXJmbG93cyB0byB0aGUgbmV4dCB3aGVuIGFjdGl2
ZQorCSAgY29ubmVjdGlvbnMgZXhjZWVkIHRoZSBub2RlJ3Mgd2VpZ2h0LgorCisJICBJZiB5b3Ug
d2FudCB0byBjb21waWxlIGl0IGluIGtlcm5lbCwgc2F5IFkuIFRvIGNvbXBpbGUgaXQgYXMgYQor
CSAgbW9kdWxlLCBjaG9vc2UgTSBoZXJlLiBJZiB1bnN1cmUsIHNheSBOLgorCiBjb25maWcJSVBf
VlNfTEJMQwogCXRyaXN0YXRlICJsb2NhbGl0eS1iYXNlZCBsZWFzdC1jb25uZWN0aW9uIHNjaGVk
dWxpbmciCiAJLS0taGVscC0tLQpkaWZmIC0tZ2l0IGEvbmV0L25ldGZpbHRlci9pcHZzL01ha2Vm
aWxlIGIvbmV0L25ldGZpbHRlci9pcHZzL01ha2VmaWxlCmluZGV4IDM4YjI3MjMuLjY3ZjNmNDMg
MTAwNjQ0Ci0tLSBhL25ldC9uZXRmaWx0ZXIvaXB2cy9NYWtlZmlsZQorKysgYi9uZXQvbmV0Zmls
dGVyL2lwdnMvTWFrZWZpbGUKQEAgLTI3LDYgKzI3LDcgQEAgb2JqLSQoQ09ORklHX0lQX1ZTX1dS
UikgKz0gaXBfdnNfd3JyLm8KIG9iai0kKENPTkZJR19JUF9WU19MQykgKz0gaXBfdnNfbGMubwog
b2JqLSQoQ09ORklHX0lQX1ZTX1dMQykgKz0gaXBfdnNfd2xjLm8KIG9iai0kKENPTkZJR19JUF9W
U19GTykgKz0gaXBfdnNfZm8ubworb2JqLSQoQ09ORklHX0lQX1ZTX09WRikgKz0gaXBfdnNfb3Zm
Lm8KIG9iai0kKENPTkZJR19JUF9WU19MQkxDKSArPSBpcF92c19sYmxjLm8KIG9iai0kKENPTkZJ
R19JUF9WU19MQkxDUikgKz0gaXBfdnNfbGJsY3Iubwogb2JqLSQoQ09ORklHX0lQX1ZTX0RIKSAr
PSBpcF92c19kaC5vCmRpZmYgLS1naXQgYS9uZXQvbmV0ZmlsdGVyL2lwdnMvaXBfdnNfb3ZmLmMg
Yi9uZXQvbmV0ZmlsdGVyL2lwdnMvaXBfdnNfb3ZmLmMKbmV3IGZpbGUgbW9kZSAxMDA2NDQKaW5k
ZXggMDAwMDAwMC4uMzQ3OGIwZAotLS0gL2Rldi9udWxsCisrKyBiL25ldC9uZXRmaWx0ZXIvaXB2
cy9pcF92c19vdmYuYwpAQCAtMCwwICsxLDg2IEBACisvKgorICogSVBWUzogICAgICAgIE92ZXJm
bG93LUNvbm5lY3Rpb24gU2NoZWR1bGluZyBtb2R1bGUKKyAqCisgKiBBdXRob3JzOiAgICAgUmFk
dWN1IERlYWNvbnUgPHJoYWRvb19pb0B5YWhvby5jb20+CisgKgorICogICAgICAgICAgICAgIFRo
aXMgcHJvZ3JhbSBpcyBmcmVlIHNvZnR3YXJlOyB5b3UgY2FuIHJlZGlzdHJpYnV0ZSBpdCBhbmQv
b3IKKyAqICAgICAgICAgICAgICBtb2RpZnkgaXQgdW5kZXIgdGhlIHRlcm1zIG9mIHRoZSBHTlUg
R2VuZXJhbCBQdWJsaWMgTGljZW5zZQorICogICAgICAgICAgICAgIGFzIHB1Ymxpc2hlZCBieSB0
aGUgRnJlZSBTb2Z0d2FyZSBGb3VuZGF0aW9uOyBlaXRoZXIgdmVyc2lvbgorICogICAgICAgICAg
ICAgIDIgb2YgdGhlIExpY2Vuc2UsIG9yIChhdCB5b3VyIG9wdGlvbikgYW55IGxhdGVyIHZlcnNp
b24uCisgKgorICogU2NoZWR1bGVyIGltcGxlbWVudHMgIm92ZXJmbG93IiBsb2FkYmFsYW5jaW5n
IGFjY29yZGluZyB0byBudW1iZXIgb2YgYWN0aXZlCisgKiBjb25uZWN0aW9ucyAsIHdpbGwga2Vl
cCBhbGwgY29uZWN0aW9ucyB0byB0aGUgbm9kZSB3aXRoIHRoZSBoaWdoZXN0IHdlaWdodAorICog
YW5kIG92ZXJmbG93IHRvIHRoZSBuZXh0IG5vZGUgaWYgdGhlIG51bWJlciBvZiBjb25uZWN0aW9u
cyBleGNlZWRzIHRoZSBub2RlJ3MKKyAqIHdlaWdodC4KKyAqIE5vdGUgdGhhdCB0aGlzIHNjaGVk
dWxlciBtaWdodCBub3QgYmUgc3VpdGFibGUgZm9yIFVEUCBiZWNhdXNlIGl0IG9ubHkgdXNlcwor
ICogYWN0aXZlIGNvbm5lY3Rpb25zCisgKgorICovCisKKyNkZWZpbmUgS01TR19DT01QT05FTlQg
IklQVlMiCisjZGVmaW5lIHByX2ZtdChmbXQpIEtNU0dfQ09NUE9ORU5UICI6ICIgZm10CisKKyNp
bmNsdWRlIDxsaW51eC9tb2R1bGUuaD4KKyNpbmNsdWRlIDxsaW51eC9rZXJuZWwuaD4KKworI2lu
Y2x1ZGUgPG5ldC9pcF92cy5oPgorCisvKiBPVkYgQ29ubmVjdGlvbiBzY2hlZHVsaW5nICAqLwor
c3RhdGljIHN0cnVjdCBpcF92c19kZXN0ICoKK2lwX3ZzX292Zl9zY2hlZHVsZShzdHJ1Y3QgaXBf
dnNfc2VydmljZSAqc3ZjLCBjb25zdCBzdHJ1Y3Qgc2tfYnVmZiAqc2tiLAorCQkgICBzdHJ1Y3Qg
aXBfdnNfaXBoZHIgKmlwaCkKK3sKKwlzdHJ1Y3QgaXBfdnNfZGVzdCAqZGVzdCwgKmggPSBOVUxM
OworCWludCBodyA9IDAsIHc7CisKKwlJUF9WU19EQkcoNiwgImlwX3ZzX292Zl9zY2hlZHVsZSgp
OiBTY2hlZHVsaW5nLi4uXG4iKTsKKwkvKiBzZWxlY3QgdGhlIG5vZGUgd2l0aCBoaWdoZXN0IHdl
aWdodCwgZ28gdG8gbmV4dCBpbiBsaW5lIGlmIGFjdGl2ZQorCSogY29ubmVjdGlvbnMgZXhjZWVk
IHdlaWdodAorCSovCisJbGlzdF9mb3JfZWFjaF9lbnRyeV9yY3UoZGVzdCwgJnN2Yy0+ZGVzdGlu
YXRpb25zLCBuX2xpc3QpIHsKKwkJdyA9IGF0b21pY19yZWFkKCZkZXN0LT53ZWlnaHQpOworCQlp
ZiAoKGRlc3QtPmZsYWdzICYgSVBfVlNfREVTVF9GX09WRVJMT0FEKSB8fAorCQkgICAgYXRvbWlj
X3JlYWQoJmRlc3QtPmFjdGl2ZWNvbm5zKSA+IHcgfHwKKwkJICAgIHcgPT0gMCkKKwkJCWNvbnRp
bnVlOworCQlpZiAoIWggfHwgdyA+IGh3KSB7CisJCQloID0gZGVzdDsKKwkJCWh3ID0gdzsKKwkJ
fQorCX0KKworCQlpZiAoaCkgeworCQkJSVBfVlNfREJHX0JVRig2LCAiT1ZGOiBzZXJ2ZXIgJXM6
JXUgYWN0aXZlICVkIHcgJWRcbiIsCisJCQkJICAgICAgSVBfVlNfREJHX0FERFIoc3ZjLT5hZiwg
JmgtPmFkZHIpLAorCQkJCSAgICAgIG50b2hzKGgtPnBvcnQpLAorCQkJCSAgICAgIGF0b21pY19y
ZWFkKCZoLT5hY3RpdmVjb25ucyksCisJCQkJICAgICAgYXRvbWljX3JlYWQoJmgtPndlaWdodCkp
OworCQlyZXR1cm4gaDsKKwkJfQorCisJaXBfdnNfc2NoZWR1bGVyX2VycihzdmMsICJubyBkZXN0
aW5hdGlvbiBhdmFpbGFibGUiKTsKKwlyZXR1cm4gTlVMTDsKK30KKworc3RhdGljIHN0cnVjdCBp
cF92c19zY2hlZHVsZXIgaXBfdnNfb3ZmX3NjaGVkdWxlciA9IHsKKwkubmFtZSA9CQkJIm92ZiIs
CisJLnJlZmNudCA9CQlBVE9NSUNfSU5JVCgwKSwKKwkubW9kdWxlID0JCVRISVNfTU9EVUxFLAor
CS5uX2xpc3QgPQkJTElTVF9IRUFEX0lOSVQoaXBfdnNfb3ZmX3NjaGVkdWxlci5uX2xpc3QpLAor
CS5zY2hlZHVsZSA9CQlpcF92c19vdmZfc2NoZWR1bGUsCit9OworCitzdGF0aWMgaW50IF9faW5p
dCBpcF92c19vdmZfaW5pdCh2b2lkKQoreworCXJldHVybiByZWdpc3Rlcl9pcF92c19zY2hlZHVs
ZXIoJmlwX3ZzX292Zl9zY2hlZHVsZXIpOworfQorCitzdGF0aWMgdm9pZCBfX2V4aXQgaXBfdnNf
b3ZmX2NsZWFudXAodm9pZCkKK3sKKwl1bnJlZ2lzdGVyX2lwX3ZzX3NjaGVkdWxlcigmaXBfdnNf
b3ZmX3NjaGVkdWxlcik7CisJc3luY2hyb25pemVfcmN1KCk7Cit9CisKK21vZHVsZV9pbml0KGlw
X3ZzX292Zl9pbml0KTsKK21vZHVsZV9leGl0KGlwX3ZzX292Zl9jbGVhbnVwKTsKK01PRFVMRV9M
SUNFTlNFKCJHUEwiKTsKLS0gCjEuNy4xMC40Cgo=
--089e0158b6c8f668b8051afc0e1b--
