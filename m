From: Julius Volz <julius.volz@gmail.com>
Subject: Re: [bug] FWMARKs and persistence in IPVS: The Use of Unions
Date: Tue, 28 Apr 2009 12:57:51 +0200
Message-ID: <43ca39800904280357q25dd3ec4x50ee78b11a94ba3f@mail.gmail.com>
References: <20090428081509.GA746@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:mime-version:received:in-reply-to:references
         :date:message-id:subject:from:to:cc:content-type
         :content-transfer-encoding;
        bh=sQHA0Vhz1EF05DwzwOsHMIJgNPpiIVCZb+pwgNFO14o=;
        b=L7UlCAYRGGEhNcDP1B9d6Bf09DxTrn+nWY4SXqchPwXshvJ5K0ujPO2+xq7iDByQdc
         IyQRf1tVPCKjwPVOi6KPsJcfGzdcW1usT6/ssC4/BPA5y7tRIKeoA2Hl2hZntJ7KEzPK
         RgTO747Jxf5Mq1ExXT7PnYAKwYx3JDb/6Mo3g=
In-Reply-To: <20090428081509.GA746@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Simon Horman <horms@verge.net.au>
Cc: netfilter-devel <netfilter-devel@vger.kernel.org>, lvs-devel@vger.kernel.org, =?ISO-8859-1?Q?Fabien_Duch=EAne?= <fabien.duchene@student.uclouvain.be>, Joseph Mack NA3T <jmack@wm7d.net>

Hi,

On Tue, Apr 28, 2009 at 10:15 AM, Simon Horman <horms@verge.net.au> wro=
te:
> [ Moving to netfilter-devel / lvs-devel for discussion on how to reso=
lve this.
> =A0Added Julius Volz to Cc, he wrote most of the IPv6 portion of LVS.
> =A0Remove lvs-users from Cc, it is not an open list. ]

Thanks for the notice and sorry for the v4 breakage.

> A simple fix that comes to mind is to just store the fwmark in
> the first octet of .all, and set the other octets to zero.
> But is .ip always going to be the same as .all[0]?

I prefer this and would have assumed that it is ok, but maybe someone
else can answer that more confidently.

> Is a different approach required? For example, one where we know to c=
ompare
> .all or perhaps a single octet of .all in the case where fmarks are u=
sed.

I guess that could be done by only specializing the lookup comparisons
in __ip_vs_conn_in_get() and ip_vs_ct_in_get() when the ports are 0.
Would blow up those if-statements even more though...

> This particular change should be easy enough. I believe that fwmarks =
are
> only used in this way twice, both inside ip_vs_schedule(). But
> ip_vs_addr_equal() is more generic, so I'd prefer only to mangle it i=
f
> needed.

I agree.

Julius
