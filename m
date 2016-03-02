From: Marco Angaroni <marcoangaroni@gmail.com>
Subject: [PATCH] ipvs: SIP persistence engine - incorrect search of callid header
Date: Wed, 2 Mar 2016 13:54:49 +0100
Message-ID: <CANHHuCXHPbMvmURbgFViLw0Oon4tS9uhpe_DwPM5h_hOCiiHVw@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:date:message-id:subject:from:to;
        bh=3TT5RzCG9tjW6bzB7b8PQjOB6b/zDXYFdYsLqO4k1RE=;
        b=0ZJyWdMuTQeV2E/KwEJOprwZwsATH6SfCwY+9pwBMN2CKCLPDB1B+aHB66WrMxHuDD
         X1Vv2owubHEZu18TsafY/JRTvfCJEylUC9U5tVHPASBmyh8TxvB/M5xjvT15UxCe0Qr5
         lgtPvdHQyOB3I+N8aR+Bwdhw1/4O6a0LTdieraJRO1aCknsUuFVDg4eflQEMPZDEv7C7
         ayg9sl0spm8i/jfJeDjSGrTU+LKA9QV3/X+F9A2JSviJJ+UNqHpNOidjtIHf3QEqvESI
         snv7BYbxVU1T2/El3qPUmHnRYJmHFxBEAw0nXUbdttx0YTt1QWNVQYWc2hAQ4XmK3GfT
         ot6g==
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org

Hello,

issue description is in my previous e-mail:
http://archive.linuxvirtualserver.org/html/lvs-devel/2016-02/msg00001.html

Below the patch formatted as requested by Julian, applied and tested
on the latest stable kernel (v4.4.2). Hope this time will be ok.

Thanks,
Marco Angaroni


Signed-off-by: Marco Angaroni <marcoangaroni@gmail.com>
---
 net/netfilter/ipvs/ip_vs_pe_sip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_pe_sip.c
b/net/netfilter/ipvs/ip_vs_pe_sip.c
index 1b8d594..b3e0e5b 100644
--- a/net/netfilter/ipvs/ip_vs_pe_sip.c
+++ b/net/netfilter/ipvs/ip_vs_pe_sip.c
@@ -88,7 +88,7 @@ ip_vs_sip_fill_param(struct ip_vs_conn_param *p,
struct sk_buff *skb)
        dptr = skb->data + dataoff;
        datalen = skb->len - dataoff;

-       if (get_callid(dptr, dataoff, datalen, &matchoff, &matchlen))
+       if (get_callid(dptr, 0, datalen, &matchoff, &matchlen))
                return -EINVAL;

        /* N.B: pe_data is only set on success,
--
1.8.3.1
