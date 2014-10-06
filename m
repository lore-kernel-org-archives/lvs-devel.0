From: Alex Gartrell <agartrell@fb.com>
Subject: Re: [PATCH net-next] ipvs: Avoid null-pointer deref in debug code
Date: Mon, 6 Oct 2014 08:56:40 -0700
Message-ID: <5432BBB8.9070206@fb.com>
References: <20141001174526.GA16206@mwanda> <1412556895-26891-1-git-send-email-agartrell@fb.com> <alpine.LFD.2.11.1410060940470.1738@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=message-id : date : from :
 mime-version : to : cc : subject : references : in-reply-to : content-type
 : content-transfer-encoding; s=facebook;
 bh=A8AgJT2PNpfZ8HX8RCchCyfIsaAHaZlKOmOe10PfSLA=;
 b=crRtXQoumHh2a6/bLXeaKOtkz6iKXIsoRvRDxz2lT5FDTXo5m0mM1TjhXjPBDpV4bliE
 OVD2Q/ij3JuPGzdr0xJKfN5J5/J7mRKd3w2ngVTpIb1Juft/KfB3qy5iBKa/YOB3p6Zg
 +9j5c/qb80DnLmiNjrztZ0Z60g8TdEL1NZs= 
In-Reply-To: <alpine.LFD.2.11.1410060940470.1738@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julian Anastasov <ja@ssi.bg>
Cc: horms@verge.net.au, dan.carpenter@oracle.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, kernel-team@fb.com

Hey Julian,

On 10/05/2014 11:49 PM, Julian Anastasov wrote:
>
> 	You have to print the "daddr" variable as
> it was done before your patchset in the
> "Stopping traffic to %s address, dest: %p..." message
> because dest is not present in all cases, for example,
> for *bypass_xmit. Other places provide cp->daddr but
> for backup server some conns can live without cp->dest.

I've sent an updated patch that does this but I have some questions 
about other stuff that I find mildly confusing.  Specifically I didn't 
realize until looking at the call sites that !dest || daddr = 
dest->addr.ip (but maybe I'm wrong?)

If that's the case, why do we have the following line in __ip_vs_get_out_rt?

                 daddr = dest->addr.ip;

If that's /always/ true then we should add the following line or a 
comment to the same effect to clarify

	BUG_ON(dest && dest->addr.ip != daddr);

If that's not intended to always be true, then should the patch be the 
following?

	...%pI4", dest ? &dest->addr.ip : &daddr);

Thanks,
-- 
Alex Gartrell <agartrell@fb.com>
