From: Alex Gartrell <alexgartrell@gmail.com>
Subject: Re: [PATCH net-next 00/12] ipvs: Add icmp scheduling
Date: Wed, 19 Aug 2015 15:24:27 -0700
Message-ID: <CALCkm3f1osyzAqfRW52V11wzL4hmKWwb_p5uE=MnQCjzn5GaWw@mail.gmail.com>
References: <1439412430-1702375-1-git-send-email-agartrell@fb.com> <alpine.LFD.2.11.1508151815580.20236@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:in-reply-to:references:from:date:message-id:subject:to
         :cc:content-type;
        bh=JOi25n6exMz6zjVuQAfI60eONWRT6D2EK03hk5eL/QA=;
        b=CcqalhtXxiHNXFJxmRg4+xeMXxaB5igffaBPztcOpPBIq7wNl2CmEImOjr3D4sIyfs
         LCOs6owCHgebJYY3IK6oeBH9HAA1VUBCW6JimRw2baeOvLGzHOJ0QLUjGylAsQxTbh83
         +tDZt9cPCnldD4nrNeYCzyy3KeFJHI+VkvrjKp+Dw9GKagwZGE1Zm+j6wn1VCkMQXDI3
         dwBv62312NZlJtElYQ8rSKawhipIECX5SUobanna0W3F0QTfw/LJ3CTk7959irsViEjG
         GWqrcaFaLnCcMLth5u8NesJwf63IsDtSMDqVuQxoLpGSNcviz5zMc4PWSkfv4Tq9tZvN
         LS0A==
In-Reply-To: <alpine.LFD.2.11.1508151815580.20236@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Alex Gartrell <agartrell@fb.com>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, kernel-team <kernel-team@fb.com>

Thank you again for you comments, Julian

On Sat, Aug 15, 2015 at 8:18 AM, Julian Anastasov <ja@ssi.bg> wrote:
>
>         What is missing in this patchset is a change to ip_vs_sh.c

+1 -- I'll add it.

>
> Patch 1:
>         - we always provide offset 0 here:
> IP_VS_DBG_PKT(7, af, pp, skb, 0, "unhandled fragment");
>
>         We may need to add 'offset' field to struct ip_vs_iphdr,
> so that we can provide valid offset to the IP_VS_DBG_PKT and
> IP_VS_DBG_RL_PKT macros. We do not provide inverse flag to the
> pp->debug_packet handler but it is not so fatal.

I'll bump this to patch 3 and then add the offset field for these debug macros.

> Patch 2:
>
> - ip_vs_out_icmp_v6: first args of ip_vs_fill_iph_skb_off can be on
> same line

I'm used the other style, but I'll do this.

> - ip_vs_in_icmp: any good reason the ip_vs_fill_iph_skb_off call to
> be moved early? Better to keep it at the ip_vs_fill_ip4hdr's place.
> It is still before the conn_in_get call.

I misunderstand the offset/offset2 swapping that was happening here.

>
> - ip_vs_in_icmp: this line should not be removed:
>         "-      offset = ciph.len;"
>
>         because offset is used later as arg to ip_vs_icmp_xmit.
>         offset provides offset to header but we later need to
>         skip this header and to reach the ports in transport header.
>
> - ip_vs_in_icmp_v6: we better to rename offs_ciph to offset and
> later to use it where 'writable' is used, then code will look like
> ip_vs_in_icmp

I'll incorporate this

> Patch 3:
>
> - breaks compilation of net/netfilter/ipvs/ip_vs_pe_sip.c and
> net/netfilter/xt_ipvs.c
>
> - do not forget that net/netfilter/xt_ipvs.c has calls to
> ip_vs_fill_iph_skb and conn_out_get, include it in your .config
> for building:
>         make net/netfilter/ipvs/ net/netfilter/xt_ipvs.o
>
> - ip_vs_fill_iph_skb_off: if we later add more flags? Should we
> provide instead just a hdr_flags arg with IP_VS_HDR_* mask?

Yeah I went with the booleans at first because providing the flags I'll do this.

> - ip_vs_out_icmp_v6: first args for ip_vs_fill_iph_skb_icmp
> should be on same line
>
> - ip_vs_in_icmp_v6: first args for ip_vs_fill_iph_skb_icmp
> should be on same line
>
> - ip_vs_in_icmp_v6: I now see that this check from
> commit 2f74713d1436 ("ipvs: Complete IPv6 fragment handling for IPVS")
> '(hooknum == NF_INET_LOCAL_OUT) ? 0 : 1' is simply wrong for
> local clients, we should always use 'true' instead of
> (hooknum != NF_INET_LOCAL_OUT).

Ah cool, that makes a lot more sense.

>
> Patch 4:
>
> - breaks compilation of net/netfilter/xt_ipvs.c
>
> - ip_vs_schedule: first hunk shows that we provide inverse=1
> to conn_in_get. This is the only odd place that does such
> inverse check. May be we can change the bit before and after
> conn_in_get?:
>
>         if (!skb->dev || skb->dev->flags & IFF_LOOPBACK) {
>                 iph->hdr_flags ^= IP_VS_HDR_INVERSE;
>                 cp = pp->conn_in_get(svc->af, skb, iph);
>                 iph->hdr_flags ^= IP_VS_HDR_INVERSE;
>                 if (cp) {
>                         IP_VS_DBG_PKT(12, svc->af, pp, skb, 0,
>                                       "Not scheduling reply for existing "
>                                       "connection");
>                         __ip_vs_conn_put(cp);
>                         return NULL;
>                 }
>         }
>
> Patch 5:
>
> - ip_vs_schedule: we should provide iph->offset as arg to IP_VS_DBG_PKT
>
> Patch 6: OK
>
> Patch 7: OK
>
> Patch 8:
>
> - ip_vs_in_icmp: may be we can avoid 2nd !cp check as follows?:
>         if (!cp) {
>                 int v;
>
>                 if (!sysctl_schedule_icmp(net_ipvs(net)))
>                         return NF_ACCEPT;
>                 if (!ip_vs_try_to_schedule(AF_INET, skb, pd, &v, &cp, &ciph))
>                         return v;
>                 new_cp = true;
>         }
>
> - same for ip_vs_in_icmp_v6
>

Yeah I can do this.

new patch set coming.  Thanks again for the thorough review!

cheers,
-- 
Alex Gartrell <agartrell@fb.com>
