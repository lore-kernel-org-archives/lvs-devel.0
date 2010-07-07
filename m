From: xiaoyu Du <tingsrain@gmail.com>
Subject: wensong@linux-vs.org, horms@verge.net.au
Date: Wed, 7 Jul 2010 17:19:06 +0800
Message-ID: <AANLkTinEKn_UBpjf3k2DZn1euMM6z2UM_yeDPvdEQkav@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:mime-version:received:received:date:message-id
         :subject:from:to:content-type:content-transfer-encoding;
        bh=7ZYw2/sqW2Yi6kM4iDe84GkKBRnz9fGOrxC47c6UYfA=;
        b=TNhen6M/BDGsrP9Jw0mgkP6i3iBCVnNQEnSEiVp/RUE1GTemnNc+BOvm1XTT5ffpk4
         aKbEXE1czMYs4xLpOV1yi/GptRsO1X0OjoMyUw2b+QiqoGfhy2YzOhIdqqndXCRKPJV7
         gVveog5h8Shgsaqza0enRVWtGEmjuzgmqkOdI=
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="windows-1252"
To: lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org

Hi=EF=BC=8Call

After I compared the sctp with tcp and udp, I thinkt his a bug that
sctp_dnat_handler Incorrectly invoked ip_vs_app_pkt_out.
below is the patch.

---
 net/netfilter/ipvs/ip_vs_proto_sctp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c
b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index c9a3f7a..db55759 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -173,7 +173,7 @@ sctp_dnat_handler(struct sk_buff *skb,
                       return 0;

               /* Call application helper if needed */
-               if (!ip_vs_app_pkt_out(cp, skb))
+               if (!ip_vs_app_pkt_in(cp, skb))
                       return 0;
       }

--
