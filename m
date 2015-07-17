From: Raducu Deaconu <rhadoo.io88@gmail.com>
Subject: Re: ovf scheduler
Date: Fri, 17 Jul 2015 08:53:52 +0300
Message-ID: <CAA0i4Bp6cXF9u9vSWoJkaG98KNro3FweW3t_Fp05TjqybW8vtA@mail.gmail.com>
References: <CAA0i4Bp0n-PooNaUq=F7MgD2Ou8=hdA6w+B0te5tcWP4ODxTfw@mail.gmail.com>
	<alpine.LFD.2.11.1507132328500.1708@ja.home.ssi.bg>
	<CAA0i4Bph-Gw00+-kUovvvfSgEta6XEH2-hGtSnusuPNdro2nCA@mail.gmail.com>
	<alpine.LFD.2.11.1507142152450.1833@ja.home.ssi.bg>
	<CAA0i4Bo3w3msK9Tdn1T3BNa-ZyQ6mon=XeXFRkSfsWHRVEua=w@mail.gmail.com>
	<alpine.LFD.2.11.1507161044500.1681@ja.home.ssi.bg>
	<CAA0i4BrKP91wiFOWpPpmFP3L1ZdVCPTdDk6PkJrGYGPWkqpxxw@mail.gmail.com>
	<alpine.LFD.2.11.1507162119020.2164@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=047d7b34391a0fd458051b0bd0d4
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:in-reply-to:references:date:message-id:subject:from:to
         :cc:content-type;
        bh=txuyozadiqxedk6uLp7s2yhvMwdBXcJG+y5amGH/hMY=;
        b=KoYHzCfgvX60tqXJ+jlcbttEvEFOPo8Wj91+TBYMADFalcqtTEyWyx9FqNv/KYBa7E
         gNedGSORHZkaEA6IsSycfnIdHWbUiJupf8jN2ZNQNGjEuvJPsPnNCpNXXIu6zOKnfK40
         xNamSJNryS30LQeS/C2J3d2NesEeNCYVKFUN0qbF0QOhuo+XGiPSwKPTEElwKWihmGZm
         BPee9zkJhwY/eOfjDSq5JuGu20aexoFMTRYNXJApkK228AxAAbdVKLQlJVyV821pYvJU
         5kKdY/vA3CE8reXDfkoQP3VeA84PSXw8rHiHnaamwxppO7MneuqSVpL7/yRX6rD0O0E3
         OJMw==
In-Reply-To: <alpine.LFD.2.11.1507162119020.2164@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

--047d7b34391a0fd458051b0bd0d4
Content-Type: text/plain; charset=UTF-8

Hello,

I have done the corrections.


Subject: [PATCH] Add ovf scheduler

Signed-off-by: Raducu Deaconu <rhadoo.io88@gmail.com>
---
 net/netfilter/ipvs/Kconfig     |   11 +++++
 net/netfilter/ipvs/Makefile    |    1 +
 net/netfilter/ipvs/ip_vs_ovf.c |   86
++++++++++++++++++++++++++++++++++++++++
 3 files changed, 98 insertions(+)
 create mode 100644 net/netfilter/ipvs/ip_vs_ovf.c

diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
index 3b6929d..b32fb0d 100644
--- a/net/netfilter/ipvs/Kconfig
+++ b/net/netfilter/ipvs/Kconfig
@@ -162,6 +162,17 @@ config  IP_VS_FO
          If you want to compile it in kernel, say Y. To compile it as
a
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
index 0000000..f7d62c3
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
+       if (h) {
+               IP_VS_DBG_BUF(6, "OVF: server %s:%u active %d w %d\n",
+                             IP_VS_DBG_ADDR(h->af, &h->addr),
+                             ntohs(h->port),
+                             atomic_read(&h->activeconns),
+                             atomic_read(&h->weight));
+               return h;
+       }
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

On Thu, Jul 16, 2015 at 9:27 PM, Julian Anastasov <ja@ssi.bg> wrote:
>
>         Hello,
>
> On Thu, 16 Jul 2015, Raducu Deaconu wrote:
>
>> Hello,
>>
>> I have readjusted the patch, sorry for the code style issues, this is
>> my first attempt at a contribution.
>
>         No worries. But one new problem...
>
>> +               if (h) {
>> +                       IP_VS_DBG_BUF(6, "OVF: server %s:%u active %d w %d\n",
>> +                                     IP_VS_DBG_ADDR(svc->af, &h->addr),
>
>         Indentation of this 'if' block should be fixed.
> It was correct in first patch. Also, change svc->af to
> h->af in above line.
>
>> +                                     ntohs(h->port),
>> +                                     atomic_read(&h->activeconns),
>> +                                     atomic_read(&h->weight));
>> +               return h;
>> +               }
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>

--047d7b34391a0fd458051b0bd0d4
Content-Type: text/x-patch; charset=US-ASCII; name="addovf.patch"
Content-Disposition: attachment; filename="addovf.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ic77kvw70

RnJvbSAyYmNiZmEwMjYxZDVlMTgzN2I0ZGNiODA2MGU0OTAxY2U3OTkyZmE5IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBSYWR1Y3UgRGVhY29udSA8cmhhZG9vLmlvODhAZ21haWwuY29t
PgpEYXRlOiBGcmksIDE3IEp1bCAyMDE1IDA4OjQ1OjQwICswMzAwClN1YmplY3Q6IFtQQVRDSF0g
QWRkIG92ZiBzY2hlZHVsZXIKClNpZ25lZC1vZmYtYnk6IFJhZHVjdSBEZWFjb251IDxyaGFkb28u
aW84OEBnbWFpbC5jb20+Ci0tLQogbmV0L25ldGZpbHRlci9pcHZzL0tjb25maWcgICAgIHwgICAx
MSArKysrKwogbmV0L25ldGZpbHRlci9pcHZzL01ha2VmaWxlICAgIHwgICAgMSArCiBuZXQvbmV0
ZmlsdGVyL2lwdnMvaXBfdnNfb3ZmLmMgfCAgIDg2ICsrKysrKysrKysrKysrKysrKysrKysrKysr
KysrKysrKysrKysrKysKIDMgZmlsZXMgY2hhbmdlZCwgOTggaW5zZXJ0aW9ucygrKQogY3JlYXRl
IG1vZGUgMTAwNjQ0IG5ldC9uZXRmaWx0ZXIvaXB2cy9pcF92c19vdmYuYwoKZGlmZiAtLWdpdCBh
L25ldC9uZXRmaWx0ZXIvaXB2cy9LY29uZmlnIGIvbmV0L25ldGZpbHRlci9pcHZzL0tjb25maWcK
aW5kZXggM2I2OTI5ZC4uYjMyZmIwZCAxMDA2NDQKLS0tIGEvbmV0L25ldGZpbHRlci9pcHZzL0tj
b25maWcKKysrIGIvbmV0L25ldGZpbHRlci9pcHZzL0tjb25maWcKQEAgLTE2Miw2ICsxNjIsMTcg
QEAgY29uZmlnICBJUF9WU19GTwogCSAgSWYgeW91IHdhbnQgdG8gY29tcGlsZSBpdCBpbiBrZXJu
ZWwsIHNheSBZLiBUbyBjb21waWxlIGl0IGFzIGEKIAkgIG1vZHVsZSwgY2hvb3NlIE0gaGVyZS4g
SWYgdW5zdXJlLCBzYXkgTi4KIAorY29uZmlnICBJUF9WU19PVkYKKwl0cmlzdGF0ZSAid2VpZ2h0
ZWQgb3ZlcmZsb3cgc2NoZWR1bGluZyIKKwktLS1oZWxwLS0tCisJICBUaGUgd2VpZ2h0ZWQgb3Zl
cmZsb3cgc2NoZWR1bGluZyBhbGdvcml0aG0gZGlyZWN0cyBuZXR3b3JrCisJICBjb25uZWN0aW9u
cyB0byB0aGUgc2VydmVyIHdpdGggdGhlIGhpZ2hlc3Qgd2VpZ2h0IHRoYXQgaXMKKwkgIGN1cnJl
bnRseSBhdmFpbGFibGUgYW5kIG92ZXJmbG93cyB0byB0aGUgbmV4dCB3aGVuIGFjdGl2ZQorCSAg
Y29ubmVjdGlvbnMgZXhjZWVkIHRoZSBub2RlJ3Mgd2VpZ2h0LgorCisJICBJZiB5b3Ugd2FudCB0
byBjb21waWxlIGl0IGluIGtlcm5lbCwgc2F5IFkuIFRvIGNvbXBpbGUgaXQgYXMgYQorCSAgbW9k
dWxlLCBjaG9vc2UgTSBoZXJlLiBJZiB1bnN1cmUsIHNheSBOLgorCiBjb25maWcJSVBfVlNfTEJM
QwogCXRyaXN0YXRlICJsb2NhbGl0eS1iYXNlZCBsZWFzdC1jb25uZWN0aW9uIHNjaGVkdWxpbmci
CiAJLS0taGVscC0tLQpkaWZmIC0tZ2l0IGEvbmV0L25ldGZpbHRlci9pcHZzL01ha2VmaWxlIGIv
bmV0L25ldGZpbHRlci9pcHZzL01ha2VmaWxlCmluZGV4IDM4YjI3MjMuLjY3ZjNmNDMgMTAwNjQ0
Ci0tLSBhL25ldC9uZXRmaWx0ZXIvaXB2cy9NYWtlZmlsZQorKysgYi9uZXQvbmV0ZmlsdGVyL2lw
dnMvTWFrZWZpbGUKQEAgLTI3LDYgKzI3LDcgQEAgb2JqLSQoQ09ORklHX0lQX1ZTX1dSUikgKz0g
aXBfdnNfd3JyLm8KIG9iai0kKENPTkZJR19JUF9WU19MQykgKz0gaXBfdnNfbGMubwogb2JqLSQo
Q09ORklHX0lQX1ZTX1dMQykgKz0gaXBfdnNfd2xjLm8KIG9iai0kKENPTkZJR19JUF9WU19GTykg
Kz0gaXBfdnNfZm8ubworb2JqLSQoQ09ORklHX0lQX1ZTX09WRikgKz0gaXBfdnNfb3ZmLm8KIG9i
ai0kKENPTkZJR19JUF9WU19MQkxDKSArPSBpcF92c19sYmxjLm8KIG9iai0kKENPTkZJR19JUF9W
U19MQkxDUikgKz0gaXBfdnNfbGJsY3Iubwogb2JqLSQoQ09ORklHX0lQX1ZTX0RIKSArPSBpcF92
c19kaC5vCmRpZmYgLS1naXQgYS9uZXQvbmV0ZmlsdGVyL2lwdnMvaXBfdnNfb3ZmLmMgYi9uZXQv
bmV0ZmlsdGVyL2lwdnMvaXBfdnNfb3ZmLmMKbmV3IGZpbGUgbW9kZSAxMDA2NDQKaW5kZXggMDAw
MDAwMC4uZjdkNjJjMwotLS0gL2Rldi9udWxsCisrKyBiL25ldC9uZXRmaWx0ZXIvaXB2cy9pcF92
c19vdmYuYwpAQCAtMCwwICsxLDg2IEBACisvKgorICogSVBWUzogICAgICAgIE92ZXJmbG93LUNv
bm5lY3Rpb24gU2NoZWR1bGluZyBtb2R1bGUKKyAqCisgKiBBdXRob3JzOiAgICAgUmFkdWN1IERl
YWNvbnUgPHJoYWRvb19pb0B5YWhvby5jb20+CisgKgorICogICAgICAgICAgICAgIFRoaXMgcHJv
Z3JhbSBpcyBmcmVlIHNvZnR3YXJlOyB5b3UgY2FuIHJlZGlzdHJpYnV0ZSBpdCBhbmQvb3IKKyAq
ICAgICAgICAgICAgICBtb2RpZnkgaXQgdW5kZXIgdGhlIHRlcm1zIG9mIHRoZSBHTlUgR2VuZXJh
bCBQdWJsaWMgTGljZW5zZQorICogICAgICAgICAgICAgIGFzIHB1Ymxpc2hlZCBieSB0aGUgRnJl
ZSBTb2Z0d2FyZSBGb3VuZGF0aW9uOyBlaXRoZXIgdmVyc2lvbgorICogICAgICAgICAgICAgIDIg
b2YgdGhlIExpY2Vuc2UsIG9yIChhdCB5b3VyIG9wdGlvbikgYW55IGxhdGVyIHZlcnNpb24uCisg
KgorICogU2NoZWR1bGVyIGltcGxlbWVudHMgIm92ZXJmbG93IiBsb2FkYmFsYW5jaW5nIGFjY29y
ZGluZyB0byBudW1iZXIgb2YgYWN0aXZlCisgKiBjb25uZWN0aW9ucyAsIHdpbGwga2VlcCBhbGwg
Y29uZWN0aW9ucyB0byB0aGUgbm9kZSB3aXRoIHRoZSBoaWdoZXN0IHdlaWdodAorICogYW5kIG92
ZXJmbG93IHRvIHRoZSBuZXh0IG5vZGUgaWYgdGhlIG51bWJlciBvZiBjb25uZWN0aW9ucyBleGNl
ZWRzIHRoZSBub2RlJ3MKKyAqIHdlaWdodC4KKyAqIE5vdGUgdGhhdCB0aGlzIHNjaGVkdWxlciBt
aWdodCBub3QgYmUgc3VpdGFibGUgZm9yIFVEUCBiZWNhdXNlIGl0IG9ubHkgdXNlcworICogYWN0
aXZlIGNvbm5lY3Rpb25zCisgKgorICovCisKKyNkZWZpbmUgS01TR19DT01QT05FTlQgIklQVlMi
CisjZGVmaW5lIHByX2ZtdChmbXQpIEtNU0dfQ09NUE9ORU5UICI6ICIgZm10CisKKyNpbmNsdWRl
IDxsaW51eC9tb2R1bGUuaD4KKyNpbmNsdWRlIDxsaW51eC9rZXJuZWwuaD4KKworI2luY2x1ZGUg
PG5ldC9pcF92cy5oPgorCisvKiBPVkYgQ29ubmVjdGlvbiBzY2hlZHVsaW5nICAqLworc3RhdGlj
IHN0cnVjdCBpcF92c19kZXN0ICoKK2lwX3ZzX292Zl9zY2hlZHVsZShzdHJ1Y3QgaXBfdnNfc2Vy
dmljZSAqc3ZjLCBjb25zdCBzdHJ1Y3Qgc2tfYnVmZiAqc2tiLAorCQkgICBzdHJ1Y3QgaXBfdnNf
aXBoZHIgKmlwaCkKK3sKKwlzdHJ1Y3QgaXBfdnNfZGVzdCAqZGVzdCwgKmggPSBOVUxMOworCWlu
dCBodyA9IDAsIHc7CisKKwlJUF9WU19EQkcoNiwgImlwX3ZzX292Zl9zY2hlZHVsZSgpOiBTY2hl
ZHVsaW5nLi4uXG4iKTsKKwkvKiBzZWxlY3QgdGhlIG5vZGUgd2l0aCBoaWdoZXN0IHdlaWdodCwg
Z28gdG8gbmV4dCBpbiBsaW5lIGlmIGFjdGl2ZQorCSogY29ubmVjdGlvbnMgZXhjZWVkIHdlaWdo
dAorCSovCisJbGlzdF9mb3JfZWFjaF9lbnRyeV9yY3UoZGVzdCwgJnN2Yy0+ZGVzdGluYXRpb25z
LCBuX2xpc3QpIHsKKwkJdyA9IGF0b21pY19yZWFkKCZkZXN0LT53ZWlnaHQpOworCQlpZiAoKGRl
c3QtPmZsYWdzICYgSVBfVlNfREVTVF9GX09WRVJMT0FEKSB8fAorCQkgICAgYXRvbWljX3JlYWQo
JmRlc3QtPmFjdGl2ZWNvbm5zKSA+IHcgfHwKKwkJICAgIHcgPT0gMCkKKwkJCWNvbnRpbnVlOwor
CQlpZiAoIWggfHwgdyA+IGh3KSB7CisJCQloID0gZGVzdDsKKwkJCWh3ID0gdzsKKwkJfQorCX0K
KworCWlmIChoKSB7CisJCUlQX1ZTX0RCR19CVUYoNiwgIk9WRjogc2VydmVyICVzOiV1IGFjdGl2
ZSAlZCB3ICVkXG4iLAorCQkJICAgICAgSVBfVlNfREJHX0FERFIoaC0+YWYsICZoLT5hZGRyKSwK
KwkJCSAgICAgIG50b2hzKGgtPnBvcnQpLAorCQkJICAgICAgYXRvbWljX3JlYWQoJmgtPmFjdGl2
ZWNvbm5zKSwKKwkJCSAgICAgIGF0b21pY19yZWFkKCZoLT53ZWlnaHQpKTsKKwkJcmV0dXJuIGg7
CisJfQorCisJaXBfdnNfc2NoZWR1bGVyX2VycihzdmMsICJubyBkZXN0aW5hdGlvbiBhdmFpbGFi
bGUiKTsKKwlyZXR1cm4gTlVMTDsKK30KKworc3RhdGljIHN0cnVjdCBpcF92c19zY2hlZHVsZXIg
aXBfdnNfb3ZmX3NjaGVkdWxlciA9IHsKKwkubmFtZSA9CQkJIm92ZiIsCisJLnJlZmNudCA9CQlB
VE9NSUNfSU5JVCgwKSwKKwkubW9kdWxlID0JCVRISVNfTU9EVUxFLAorCS5uX2xpc3QgPQkJTElT
VF9IRUFEX0lOSVQoaXBfdnNfb3ZmX3NjaGVkdWxlci5uX2xpc3QpLAorCS5zY2hlZHVsZSA9CQlp
cF92c19vdmZfc2NoZWR1bGUsCit9OworCitzdGF0aWMgaW50IF9faW5pdCBpcF92c19vdmZfaW5p
dCh2b2lkKQoreworCXJldHVybiByZWdpc3Rlcl9pcF92c19zY2hlZHVsZXIoJmlwX3ZzX292Zl9z
Y2hlZHVsZXIpOworfQorCitzdGF0aWMgdm9pZCBfX2V4aXQgaXBfdnNfb3ZmX2NsZWFudXAodm9p
ZCkKK3sKKwl1bnJlZ2lzdGVyX2lwX3ZzX3NjaGVkdWxlcigmaXBfdnNfb3ZmX3NjaGVkdWxlcik7
CisJc3luY2hyb25pemVfcmN1KCk7Cit9CisKK21vZHVsZV9pbml0KGlwX3ZzX292Zl9pbml0KTsK
K21vZHVsZV9leGl0KGlwX3ZzX292Zl9jbGVhbnVwKTsKK01PRFVMRV9MSUNFTlNFKCJHUEwiKTsK
LS0gCjEuNy4xMC40Cgo=
--047d7b34391a0fd458051b0bd0d4--
