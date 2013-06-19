From: Aleksey Chudov <aleksey.chudov@gmail.com>
Subject: Re: [PATCH] Sloppy TCP, SH rebalancing, SHP scheduling
Date: Wed, 19 Jun 2013 23:44:51 +0300
Message-ID: <51C21843.80304@gmail.com>
References: <20130524120935.GL264@eldamar.org.uk> <alpine.LFD.2.00.1305241633430.1636@ja.ssi.bg> <20130524151408.GM264@eldamar.org.uk> <519F92EB.4080509@gmail.com> <alpine.LFD.2.00.1305280011490.1728@ja.ssi.bg> <51A4B3ED.4070809@gmail.com> <alpine.LFD.2.00.1306191153590.2077@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=message-id:date:from:user-agent:mime-version:to:cc:subject
         :references:in-reply-to:content-type:content-transfer-encoding;
        bh=ITwGc7eMUI4S5hN7P/DdiWocnIBb/jpXouR/m1DKOtk=;
        b=1C2ObVh8gfQgV7H274Xkjf5yAFcY7WkdsnoFUsDGkRhRLU8z/Kyv/7D/bJy4OIrDnB
         iFRUQh4Xv486ycKMU260ohYzMwmW1hpPr2AnqtVBqW4Tuwf34XowClFMmXyxV/8DAfww
         jkW5NEhITVM4a6qZCq8pdjAd+c68arHBFqAjWvL6hLvh0504lNQcR0dtXktaQwRNu4FC
         eaJoyHOLmukKIensBFa7K3yML9UVCLJMgAATTgzA8J3o3P/3Ldkiu3z10JcB/kt3ysDR
         Hzn9/WPcbZNXO6jzoXVDLHtMnZbCknqxbtkMoBhPFqZJpDHQ7siB0v0dEhHrNEu89lLY
         uRWA==
In-Reply-To: <alpine.LFD.2.00.1306191153590.2077@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

Hello,

On 19.06.2013 12:03, Julian Anastasov wrote:
> 	Here is something that is compile-tested. You
> will need the "ipvs: sloppy TCP and SCTP" patch by
> Alexander Frolkin posted on 13 Jun. Let me know if
> you need more help in applying and testing such patches,
> so that we can be more confident when releasing such
> optimization officially.
>
> From: Julian Anastasov <ja@ssi.bg>
> [PATCH] ipvs: add sync_persist_mode flag
>
> Add sync_persist_mode flag to reduce sync traffic
> by syncing only persistent templates.
>
>

On 19.06.2013 22:25, Julian Anastasov wrote:
> On Wed, 19 Jun 2013, Julian Anastasov wrote:
>
>> >+static inline bool in_peristence(struct ip_vs_conn *cp)
> 	Ops
>
> s/in_peristence/in_persistence/


Thanks for the implementation. I applied sloppy_tcp and persist_mode 
patches manually to our kernel 2.6.39 considering your last ops :) Plan 
to start testing tomorrow.

Aleksey
