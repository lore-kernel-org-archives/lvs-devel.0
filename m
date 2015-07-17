From: Raducu Deaconu <rhadoo.io88@gmail.com>
Subject: Re: ovf scheduler
Date: Fri, 17 Jul 2015 14:15:27 +0300
Message-ID: <CAA0i4BrMtuVq6-dbBHH93M-wSoOQ+ckFoAr_Csv8sw3hBi4wgg@mail.gmail.com>
References: <CAA0i4Bp0n-PooNaUq=F7MgD2Ou8=hdA6w+B0te5tcWP4ODxTfw@mail.gmail.com>
	<alpine.LFD.2.11.1507132328500.1708@ja.home.ssi.bg>
	<CAA0i4Bph-Gw00+-kUovvvfSgEta6XEH2-hGtSnusuPNdro2nCA@mail.gmail.com>
	<alpine.LFD.2.11.1507142152450.1833@ja.home.ssi.bg>
	<CAA0i4Bo3w3msK9Tdn1T3BNa-ZyQ6mon=XeXFRkSfsWHRVEua=w@mail.gmail.com>
	<alpine.LFD.2.11.1507161044500.1681@ja.home.ssi.bg>
	<CAA0i4BrKP91wiFOWpPpmFP3L1ZdVCPTdDk6PkJrGYGPWkqpxxw@mail.gmail.com>
	<alpine.LFD.2.11.1507162119020.2164@ja.home.ssi.bg>
	<CAA0i4Bp6cXF9u9vSWoJkaG98KNro3FweW3t_Fp05TjqybW8vtA@mail.gmail.com>
	<alpine.LFD.2.11.1507170912230.1587@ja.home.ssi.bg>
	<20150717064311.GB7986@verge.net.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=047d7bfcf60623b9a6051b104e48
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:in-reply-to:references:date:message-id:subject:from:to
         :cc:content-type;
        bh=2vk/C2pwXY7ZLxSyxRaF5ov1tEVqykJ2TyQHf/cXTjY=;
        b=Cam8LVdiqOarTchw/qOfmOutyAyq59Atn3JwreZf58pc1j5d1lO5NFTrtuirMoPYlG
         gi2lFm4gAVlqFkKanGLE7u+n10bymEa2ZRaxPE28m+BZIufTpf21BvcmzSlL6k86oTDp
         hkhOs/GIKNQ4Xs+XtVslUz7WFEHMsFZdnhoILS5s60oBtu61IA0AXV8Ay4aVXeyafFTw
         sYkDWB1GcVbusk8aCtsWQ5c7ABrGyc2Ae69e1+CpkHPLLvvCprTeklt3UW1GVdmy1DYJ
         LsxqUle/TTuB1jfEa29rdh5Sit/wcxSwA9pkFjCzED5iSy7V2bLOZ2bvwM1r2j5mEJ3T
         +SRw==
In-Reply-To: <20150717064311.GB7986@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org

--047d7bfcf60623b9a6051b104e48
Content-Type: text/plain; charset=UTF-8

Hi,
I have added entry for changelog ,
Thank you


From 2bcbfa0261d5e1837b4dcb8060e4901ce7992fa9 Mon Sep 17 00:00:00 2001
From: Raducu Deaconu <rhadoo.io88@gmail.com>
Date: Fri, 17 Jul 2015 08:45:40 +0300
Subject: [PATCH] ipvs: Add ovf scheduler

The weighted overflow scheduling algorithm directs network connections
to the server with the highest weight that is currently available
and overflows to the next when active connections exceed the node's weight.
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

On Fri, Jul 17, 2015 at 9:43 AM, Simon Horman <horms@verge.net.au> wrote:
> On Fri, Jul 17, 2015 at 09:16:40AM +0300, Julian Anastasov wrote:
>>
>>       Hello,
>>
>> On Fri, 17 Jul 2015, Raducu Deaconu wrote:
>>
>> > Hello,
>> >
>> > I have done the corrections.
>> >
>> >
>> > Subject: [PATCH] Add ovf scheduler
>> >
>> > Signed-off-by: Raducu Deaconu <rhadoo.io88@gmail.com>
>>
>>       Thanks!
>>
>> Acked-by: Julian Anastasov <ja@ssi.bg>
>>
>>       Simon, please apply the attached patch to -next
>> tree after adding the "ipvs: " prefix.
>
> I am happy to do so, but Raducu, could you flesh out the changelog to
> describe what the new scheduler does. The Kconfig text (bellow) seems to
> provide the necessary information but I'd really like it in the changelog
> too.
>
> Thanks.
>
>>
>> > ---
>> >  net/netfilter/ipvs/Kconfig     |   11 +++++
>> >  net/netfilter/ipvs/Makefile    |    1 +
>> >  net/netfilter/ipvs/ip_vs_ovf.c |   86
>> > ++++++++++++++++++++++++++++++++++++++++
>> >  3 files changed, 98 insertions(+)
>> >  create mode 100644 net/netfilter/ipvs/ip_vs_ovf.c
>> >
>> > diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
>> > index 3b6929d..b32fb0d 100644
>> > --- a/net/netfilter/ipvs/Kconfig
>> > +++ b/net/netfilter/ipvs/Kconfig
>> > @@ -162,6 +162,17 @@ config  IP_VS_FO
>> >           If you want to compile it in kernel, say Y. To compile it as
>> > a
>> >           module, choose M here. If unsure, say N.
>> >
>> > +config  IP_VS_OVF
>> > +       tristate "weighted overflow scheduling"
>> > +       ---help---
>> > +         The weighted overflow scheduling algorithm directs network
>> > +         connections to the server with the highest weight that is
>> > +         currently available and overflows to the next when active
>> > +         connections exceed the node's weight.
>> > +
>> > +         If you want to compile it in kernel, say Y. To compile it as a
>> > +         module, choose M here. If unsure, say N.
>> > +
>> >  config IP_VS_LBLC
>> >         tristate "locality-based least-connection scheduling"
>> >         ---help---
>
> [snip]

--047d7bfcf60623b9a6051b104e48
Content-Type: text/x-patch; charset=US-ASCII; name="addovf.patch"
Content-Disposition: attachment; filename="addovf.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ic7j3cqy0

RnJvbSAyYmNiZmEwMjYxZDVlMTgzN2I0ZGNiODA2MGU0OTAxY2U3OTkyZmE5IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBSYWR1Y3UgRGVhY29udSA8cmhhZG9vLmlvODhAZ21haWwuY29t
PgpEYXRlOiBGcmksIDE3IEp1bCAyMDE1IDA4OjQ1OjQwICswMzAwClN1YmplY3Q6IFtQQVRDSF0g
aXB2czogQWRkIG92ZiBzY2hlZHVsZXIKClRoZSB3ZWlnaHRlZCBvdmVyZmxvdyBzY2hlZHVsaW5n
IGFsZ29yaXRobSBkaXJlY3RzIG5ldHdvcmsgY29ubmVjdGlvbnMKdG8gdGhlIHNlcnZlciB3aXRo
IHRoZSBoaWdoZXN0IHdlaWdodCB0aGF0IGlzIGN1cnJlbnRseSBhdmFpbGFibGUgCmFuZCBvdmVy
Zmxvd3MgdG8gdGhlIG5leHQgd2hlbiBhY3RpdmUgY29ubmVjdGlvbnMgZXhjZWVkIHRoZSBub2Rl
J3Mgd2VpZ2h0LgpTaWduZWQtb2ZmLWJ5OiBSYWR1Y3UgRGVhY29udSA8cmhhZG9vLmlvODhAZ21h
aWwuY29tPgotLS0KIG5ldC9uZXRmaWx0ZXIvaXB2cy9LY29uZmlnICAgICB8ICAgMTEgKysrKysK
IG5ldC9uZXRmaWx0ZXIvaXB2cy9NYWtlZmlsZSAgICB8ICAgIDEgKwogbmV0L25ldGZpbHRlci9p
cHZzL2lwX3ZzX292Zi5jIHwgICA4NiArKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysr
KysrKysrCiAzIGZpbGVzIGNoYW5nZWQsIDk4IGluc2VydGlvbnMoKykKIGNyZWF0ZSBtb2RlIDEw
MDY0NCBuZXQvbmV0ZmlsdGVyL2lwdnMvaXBfdnNfb3ZmLmMKCmRpZmYgLS1naXQgYS9uZXQvbmV0
ZmlsdGVyL2lwdnMvS2NvbmZpZyBiL25ldC9uZXRmaWx0ZXIvaXB2cy9LY29uZmlnCmluZGV4IDNi
NjkyOWQuLmIzMmZiMGQgMTAwNjQ0Ci0tLSBhL25ldC9uZXRmaWx0ZXIvaXB2cy9LY29uZmlnCisr
KyBiL25ldC9uZXRmaWx0ZXIvaXB2cy9LY29uZmlnCkBAIC0xNjIsNiArMTYyLDE3IEBAIGNvbmZp
ZyAgSVBfVlNfRk8KIAkgIElmIHlvdSB3YW50IHRvIGNvbXBpbGUgaXQgaW4ga2VybmVsLCBzYXkg
WS4gVG8gY29tcGlsZSBpdCBhcyBhCiAJICBtb2R1bGUsIGNob29zZSBNIGhlcmUuIElmIHVuc3Vy
ZSwgc2F5IE4uCiAKK2NvbmZpZyAgSVBfVlNfT1ZGCisJdHJpc3RhdGUgIndlaWdodGVkIG92ZXJm
bG93IHNjaGVkdWxpbmciCisJLS0taGVscC0tLQorCSAgVGhlIHdlaWdodGVkIG92ZXJmbG93IHNj
aGVkdWxpbmcgYWxnb3JpdGhtIGRpcmVjdHMgbmV0d29yaworCSAgY29ubmVjdGlvbnMgdG8gdGhl
IHNlcnZlciB3aXRoIHRoZSBoaWdoZXN0IHdlaWdodCB0aGF0IGlzCisJICBjdXJyZW50bHkgYXZh
aWxhYmxlIGFuZCBvdmVyZmxvd3MgdG8gdGhlIG5leHQgd2hlbiBhY3RpdmUKKwkgIGNvbm5lY3Rp
b25zIGV4Y2VlZCB0aGUgbm9kZSdzIHdlaWdodC4KKworCSAgSWYgeW91IHdhbnQgdG8gY29tcGls
ZSBpdCBpbiBrZXJuZWwsIHNheSBZLiBUbyBjb21waWxlIGl0IGFzIGEKKwkgIG1vZHVsZSwgY2hv
b3NlIE0gaGVyZS4gSWYgdW5zdXJlLCBzYXkgTi4KKwogY29uZmlnCUlQX1ZTX0xCTEMKIAl0cmlz
dGF0ZSAibG9jYWxpdHktYmFzZWQgbGVhc3QtY29ubmVjdGlvbiBzY2hlZHVsaW5nIgogCS0tLWhl
bHAtLS0KZGlmZiAtLWdpdCBhL25ldC9uZXRmaWx0ZXIvaXB2cy9NYWtlZmlsZSBiL25ldC9uZXRm
aWx0ZXIvaXB2cy9NYWtlZmlsZQppbmRleCAzOGIyNzIzLi42N2YzZjQzIDEwMDY0NAotLS0gYS9u
ZXQvbmV0ZmlsdGVyL2lwdnMvTWFrZWZpbGUKKysrIGIvbmV0L25ldGZpbHRlci9pcHZzL01ha2Vm
aWxlCkBAIC0yNyw2ICsyNyw3IEBAIG9iai0kKENPTkZJR19JUF9WU19XUlIpICs9IGlwX3ZzX3dy
ci5vCiBvYmotJChDT05GSUdfSVBfVlNfTEMpICs9IGlwX3ZzX2xjLm8KIG9iai0kKENPTkZJR19J
UF9WU19XTEMpICs9IGlwX3ZzX3dsYy5vCiBvYmotJChDT05GSUdfSVBfVlNfRk8pICs9IGlwX3Zz
X2ZvLm8KK29iai0kKENPTkZJR19JUF9WU19PVkYpICs9IGlwX3ZzX292Zi5vCiBvYmotJChDT05G
SUdfSVBfVlNfTEJMQykgKz0gaXBfdnNfbGJsYy5vCiBvYmotJChDT05GSUdfSVBfVlNfTEJMQ1Ip
ICs9IGlwX3ZzX2xibGNyLm8KIG9iai0kKENPTkZJR19JUF9WU19ESCkgKz0gaXBfdnNfZGgubwpk
aWZmIC0tZ2l0IGEvbmV0L25ldGZpbHRlci9pcHZzL2lwX3ZzX292Zi5jIGIvbmV0L25ldGZpbHRl
ci9pcHZzL2lwX3ZzX292Zi5jCm5ldyBmaWxlIG1vZGUgMTAwNjQ0CmluZGV4IDAwMDAwMDAuLmY3
ZDYyYzMKLS0tIC9kZXYvbnVsbAorKysgYi9uZXQvbmV0ZmlsdGVyL2lwdnMvaXBfdnNfb3ZmLmMK
QEAgLTAsMCArMSw4NiBAQAorLyoKKyAqIElQVlM6ICAgICAgICBPdmVyZmxvdy1Db25uZWN0aW9u
IFNjaGVkdWxpbmcgbW9kdWxlCisgKgorICogQXV0aG9yczogICAgIFJhZHVjdSBEZWFjb251IDxy
aGFkb29faW9AeWFob28uY29tPgorICoKKyAqICAgICAgICAgICAgICBUaGlzIHByb2dyYW0gaXMg
ZnJlZSBzb2Z0d2FyZTsgeW91IGNhbiByZWRpc3RyaWJ1dGUgaXQgYW5kL29yCisgKiAgICAgICAg
ICAgICAgbW9kaWZ5IGl0IHVuZGVyIHRoZSB0ZXJtcyBvZiB0aGUgR05VIEdlbmVyYWwgUHVibGlj
IExpY2Vuc2UKKyAqICAgICAgICAgICAgICBhcyBwdWJsaXNoZWQgYnkgdGhlIEZyZWUgU29mdHdh
cmUgRm91bmRhdGlvbjsgZWl0aGVyIHZlcnNpb24KKyAqICAgICAgICAgICAgICAyIG9mIHRoZSBM
aWNlbnNlLCBvciAoYXQgeW91ciBvcHRpb24pIGFueSBsYXRlciB2ZXJzaW9uLgorICoKKyAqIFNj
aGVkdWxlciBpbXBsZW1lbnRzICJvdmVyZmxvdyIgbG9hZGJhbGFuY2luZyBhY2NvcmRpbmcgdG8g
bnVtYmVyIG9mIGFjdGl2ZQorICogY29ubmVjdGlvbnMgLCB3aWxsIGtlZXAgYWxsIGNvbmVjdGlv
bnMgdG8gdGhlIG5vZGUgd2l0aCB0aGUgaGlnaGVzdCB3ZWlnaHQKKyAqIGFuZCBvdmVyZmxvdyB0
byB0aGUgbmV4dCBub2RlIGlmIHRoZSBudW1iZXIgb2YgY29ubmVjdGlvbnMgZXhjZWVkcyB0aGUg
bm9kZSdzCisgKiB3ZWlnaHQuCisgKiBOb3RlIHRoYXQgdGhpcyBzY2hlZHVsZXIgbWlnaHQgbm90
IGJlIHN1aXRhYmxlIGZvciBVRFAgYmVjYXVzZSBpdCBvbmx5IHVzZXMKKyAqIGFjdGl2ZSBjb25u
ZWN0aW9ucworICoKKyAqLworCisjZGVmaW5lIEtNU0dfQ09NUE9ORU5UICJJUFZTIgorI2RlZmlu
ZSBwcl9mbXQoZm10KSBLTVNHX0NPTVBPTkVOVCAiOiAiIGZtdAorCisjaW5jbHVkZSA8bGludXgv
bW9kdWxlLmg+CisjaW5jbHVkZSA8bGludXgva2VybmVsLmg+CisKKyNpbmNsdWRlIDxuZXQvaXBf
dnMuaD4KKworLyogT1ZGIENvbm5lY3Rpb24gc2NoZWR1bGluZyAgKi8KK3N0YXRpYyBzdHJ1Y3Qg
aXBfdnNfZGVzdCAqCitpcF92c19vdmZfc2NoZWR1bGUoc3RydWN0IGlwX3ZzX3NlcnZpY2UgKnN2
YywgY29uc3Qgc3RydWN0IHNrX2J1ZmYgKnNrYiwKKwkJICAgc3RydWN0IGlwX3ZzX2lwaGRyICpp
cGgpCit7CisJc3RydWN0IGlwX3ZzX2Rlc3QgKmRlc3QsICpoID0gTlVMTDsKKwlpbnQgaHcgPSAw
LCB3OworCisJSVBfVlNfREJHKDYsICJpcF92c19vdmZfc2NoZWR1bGUoKTogU2NoZWR1bGluZy4u
LlxuIik7CisJLyogc2VsZWN0IHRoZSBub2RlIHdpdGggaGlnaGVzdCB3ZWlnaHQsIGdvIHRvIG5l
eHQgaW4gbGluZSBpZiBhY3RpdmUKKwkqIGNvbm5lY3Rpb25zIGV4Y2VlZCB3ZWlnaHQKKwkqLwor
CWxpc3RfZm9yX2VhY2hfZW50cnlfcmN1KGRlc3QsICZzdmMtPmRlc3RpbmF0aW9ucywgbl9saXN0
KSB7CisJCXcgPSBhdG9taWNfcmVhZCgmZGVzdC0+d2VpZ2h0KTsKKwkJaWYgKChkZXN0LT5mbGFn
cyAmIElQX1ZTX0RFU1RfRl9PVkVSTE9BRCkgfHwKKwkJICAgIGF0b21pY19yZWFkKCZkZXN0LT5h
Y3RpdmVjb25ucykgPiB3IHx8CisJCSAgICB3ID09IDApCisJCQljb250aW51ZTsKKwkJaWYgKCFo
IHx8IHcgPiBodykgeworCQkJaCA9IGRlc3Q7CisJCQlodyA9IHc7CisJCX0KKwl9CisKKwlpZiAo
aCkgeworCQlJUF9WU19EQkdfQlVGKDYsICJPVkY6IHNlcnZlciAlczoldSBhY3RpdmUgJWQgdyAl
ZFxuIiwKKwkJCSAgICAgIElQX1ZTX0RCR19BRERSKGgtPmFmLCAmaC0+YWRkciksCisJCQkgICAg
ICBudG9ocyhoLT5wb3J0KSwKKwkJCSAgICAgIGF0b21pY19yZWFkKCZoLT5hY3RpdmVjb25ucyks
CisJCQkgICAgICBhdG9taWNfcmVhZCgmaC0+d2VpZ2h0KSk7CisJCXJldHVybiBoOworCX0KKwor
CWlwX3ZzX3NjaGVkdWxlcl9lcnIoc3ZjLCAibm8gZGVzdGluYXRpb24gYXZhaWxhYmxlIik7CisJ
cmV0dXJuIE5VTEw7Cit9CisKK3N0YXRpYyBzdHJ1Y3QgaXBfdnNfc2NoZWR1bGVyIGlwX3ZzX292
Zl9zY2hlZHVsZXIgPSB7CisJLm5hbWUgPQkJCSJvdmYiLAorCS5yZWZjbnQgPQkJQVRPTUlDX0lO
SVQoMCksCisJLm1vZHVsZSA9CQlUSElTX01PRFVMRSwKKwkubl9saXN0ID0JCUxJU1RfSEVBRF9J
TklUKGlwX3ZzX292Zl9zY2hlZHVsZXIubl9saXN0KSwKKwkuc2NoZWR1bGUgPQkJaXBfdnNfb3Zm
X3NjaGVkdWxlLAorfTsKKworc3RhdGljIGludCBfX2luaXQgaXBfdnNfb3ZmX2luaXQodm9pZCkK
K3sKKwlyZXR1cm4gcmVnaXN0ZXJfaXBfdnNfc2NoZWR1bGVyKCZpcF92c19vdmZfc2NoZWR1bGVy
KTsKK30KKworc3RhdGljIHZvaWQgX19leGl0IGlwX3ZzX292Zl9jbGVhbnVwKHZvaWQpCit7CisJ
dW5yZWdpc3Rlcl9pcF92c19zY2hlZHVsZXIoJmlwX3ZzX292Zl9zY2hlZHVsZXIpOworCXN5bmNo
cm9uaXplX3JjdSgpOworfQorCittb2R1bGVfaW5pdChpcF92c19vdmZfaW5pdCk7Cittb2R1bGVf
ZXhpdChpcF92c19vdmZfY2xlYW51cCk7CitNT0RVTEVfTElDRU5TRSgiR1BMIik7Ci0tIAoxLjcu
MTAuNAoK
--047d7bfcf60623b9a6051b104e48--
