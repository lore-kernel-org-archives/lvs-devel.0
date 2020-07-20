From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 24/24] net: pass a sockptr_t into ->setsockopt
Date: Mon, 20 Jul 2020 16:20:13 -0700 (PDT)
Message-ID: <20200720.162013.456211151711627380.davem@davemloft.net>
References: <20200720124737.118617-1-hch@lst.de>
        <20200720124737.118617-25-hch@lst.de>
        <deaedc6d-edde-68da-50e8-6474ca818191@datenfreihafen.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <deaedc6d-edde-68da-50e8-6474ca818191-OrPQZGeq07wqhVmZOOOmNx2eb7JE58TQ@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: stefan-OrPQZGeq07wqhVmZOOOmNx2eb7JE58TQ@public.gmane.org
Cc: hch-jcswGhMUV9g@public.gmane.org, kuba-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org, yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bpf-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-hams-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bridge-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dccp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-decnet-user-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mptcp-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org, lvs-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, linux-afs-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, tipc-discussion-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-x25-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

From: Stefan Schmidt <stefan-OrPQZGeq07wqhVmZOOOmNx2eb7JE58TQ@public.gmane.org>
Date: Mon, 20 Jul 2020 16:19:38 +0200

> For the ieee802154 part:
> 
> Acked-by: Stefan Schmidt <stefan-OrPQZGeq07wqhVmZOOOmNx2eb7JE58TQ@public.gmane.org>

Please do not quote an entire patch just to add an ACK, trim it just
to the commit message, or even less.

Thank you.
