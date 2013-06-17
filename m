From: Alexander Frolkin <avf@eldamar.org.uk>
Subject: Re: [PATCH] Sloppy TCP, SH rebalancing, SHP scheduling
Date: Mon, 17 Jun 2013 09:32:04 +0100
Message-ID: <20130617083204.GA13101@eldamar.org.uk>
References: <20130607081252.GC11902@eldamar.org.uk>
 <alpine.LFD.2.00.1306102222380.1773@ja.ssi.bg>
 <20130611083806.GA25531@eldamar.org.uk>
 <alpine.LFD.2.00.1306112240280.1709@ja.ssi.bg>
 <20130612141018.GC29327@eldamar.org.uk>
 <alpine.LFD.2.00.1306122244020.1773@ja.ssi.bg>
 <20130613141804.GB31356@eldamar.org.uk>
 <alpine.LFD.2.00.1306132250560.1810@ja.ssi.bg>
 <20130614102210.GA31800@eldamar.org.uk>
 <alpine.LFD.2.00.1306160911001.1579@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1306160911001.1579@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

Hi,

> 	Add 'break' for this case when dest is NULL (no
> dests). Then we have to add {} for all branches as per
> CodingStyle:
> 
> 	if (!is_unavailable(dest))
> 		return dest;
> 	if (dest) {
> 		IP_VS_DBG_BUF
> 	} else {
> 		IP_VS_DBG
> 		break;
> 	}

So if dest is NULL, there is no point trying to choose a different
server?


Alex

