From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH ipvs,v4 19/20] ipvs: use the new dest addr family field
Date: Wed, 10 Sep 2014 09:05:55 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1409100902310.6338@ja.home.ssi.bg>
References: <1409301549-5284-1-git-send-email-agartrell@fb.com> <1409301549-5284-20-git-send-email-agartrell@fb.com> <alpine.LFD.2.11.1408291259510.4876@ja.home.ssi.bg> <5400EE48.5060007@fb.com> <alpine.LFD.2.11.1409092229380.4943@ja.home.ssi.bg>
 <540F8BBE.9040808@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <540F8BBE.9040808@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Gartrell <agartrell@fb.com>
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, kernel-team@fb.com


	Hello,

On Tue, 9 Sep 2014, Alex Gartrell wrote:

> On 9/9/14 12:41 PM, Julian Anastasov wrote:
> 
> > 	Also, can you try my ipvsadm patches to check for
> > possible problems in the connection listing, so that we
> > can safely apply them to the ipvsadm tree.
> >
> 
> 
> All of the ipvsadm changes work as expected, but it needs an additional tweak:

	Thanks! I guess this is related to formatting of
output, you can submit it as official change, so that we
can apply all pending changes to the ipvsadm tree.

> diff --git a/ipvsadm.c b/ipvsadm.c
> index d12070e..ef19091 100644
> --- a/ipvsadm.c
> +++ b/ipvsadm.c
> @@ -1629,7 +1629,7 @@ print_service_entry(ipvs_service_entry_t *se, unsigned
> int format)
>                         fprintf(stderr, "addrport_to_anyname fails\n");
>                         exit(1);
>                 }
> -               if (!(format & FMT_RULE) && (se->af != AF_INET6))
> +               if (!(format & FMT_RULE) && (e->af != AF_INET6))
>                         dname[28] = '\0';
> 
>                 if (format & FMT_RULE) {
> 
> Thanks,
> -- 
> Alex Gartrell <agartrell@fb.com>

Regards

--
Julian Anastasov <ja@ssi.bg>
