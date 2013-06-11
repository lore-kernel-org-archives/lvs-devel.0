From: Alexander Frolkin <avf@eldamar.org.uk>
Subject: Re: [PATCH] Sloppy TCP, SH rebalancing, SHP scheduling
Date: Tue, 11 Jun 2013 09:38:06 +0100
Message-ID: <20130611083806.GA25531@eldamar.org.uk>
References: <20130524120935.GL264@eldamar.org.uk>
 <alpine.LFD.2.00.1305241633430.1636@ja.ssi.bg>
 <20130524151408.GM264@eldamar.org.uk>
 <alpine.LFD.2.00.1305272251170.1728@ja.ssi.bg>
 <20130607081252.GC11902@eldamar.org.uk>
 <alpine.LFD.2.00.1306102222380.1773@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1306102222380.1773@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

Hi,

> > Is there a reason why the SH fallback behaviour shouldn't be default?
> > That is, is there a reason why the current behaviour (client connection
> > gets reset if it is directed to a realserver with weight 0) is
> > desirable?
> I don't know, the authors preferred this behaviour.

Is it worth looking at changing this?  Or is this going to be too
difficult a change to push through?

I just don't understand why rejecting a client connection when there are
servers available is desirable behaviour.


Alex

