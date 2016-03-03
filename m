From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: SIP persistence engine - incorrect search of callid
 header
Date: Thu, 3 Mar 2016 16:56:28 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1603031633170.3193@ja.home.ssi.bg>
References: <CANHHuCXHPbMvmURbgFViLw0Oon4tS9uhpe_DwPM5h_hOCiiHVw@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <CANHHuCXHPbMvmURbgFViLw0Oon4tS9uhpe_DwPM5h_hOCiiHVw@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Marco Angaroni <marcoangaroni@gmail.com>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Wed, 2 Mar 2016, Marco Angaroni wrote:

> issue description is in my previous e-mail:
> http://archive.linuxvirtualserver.org/html/lvs-devel/2016-02/msg00001.html
> 
> Below the patch formatted as requested by Julian, applied and tested
> on the latest stable kernel (v4.4.2). Hope this time will be ok.

	Such explanations can go below the "---" line
but at this place you have to explain what the patch does
because only this text is going to be committed. You have
to put your original text, may be after editing.

	As this is a bugfix, you can also add here,
just before the Signed-off-by line, such info:

Fixes: 758ff0338722 ("IPVS: sip persistence engine")

> Signed-off-by: Marco Angaroni <marcoangaroni@gmail.com>
> ---
>  net/netfilter/ipvs/ip_vs_pe_sip.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_pe_sip.c
> b/net/netfilter/ipvs/ip_vs_pe_sip.c
> index 1b8d594..b3e0e5b 100644
> --- a/net/netfilter/ipvs/ip_vs_pe_sip.c
> +++ b/net/netfilter/ipvs/ip_vs_pe_sip.c
> @@ -88,7 +88,7 @@ ip_vs_sip_fill_param(struct ip_vs_conn_param *p,
> struct sk_buff *skb)
>         dptr = skb->data + dataoff;
>         datalen = skb->len - dataoff;
> 
> -       if (get_callid(dptr, dataoff, datalen, &matchoff, &matchlen))
> +       if (get_callid(dptr, 0, datalen, &matchoff, &matchlen))
>                 return -EINVAL;
> 
>         /* N.B: pe_data is only set on success,

Regards

--
Julian Anastasov <ja@ssi.bg>
