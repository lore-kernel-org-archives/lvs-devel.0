From: Alexander Frolkin <avf@eldamar.org.uk>
Subject: Re: [PATCH] Sloppy TCP, SH rebalancing, SHP scheduling
Date: Fri, 7 Jun 2013 08:53:04 +0100
Message-ID: <20130607075304.GB11902@eldamar.org.uk>
References: <20130524120935.GL264@eldamar.org.uk>
 <alpine.LFD.2.00.1305241633430.1636@ja.ssi.bg>
 <20130524151408.GM264@eldamar.org.uk>
 <519F92EB.4080509@gmail.com>
 <alpine.LFD.2.00.1305280011490.1728@ja.ssi.bg>
 <51A4B3ED.4070809@gmail.com>
 <alpine.LFD.2.00.1305300830100.1671@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1305300830100.1671@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Aleksey Chudov <aleksey.chudov@gmail.com>, lvs-devel@vger.kernel.org

Hi,

> 	May be the patch for Sloppy TCP mode should be
> extended to assume that old state is sSR if packet that
> creates the connection has no RST flag. This will allow
> connection to enter sES state if need, it will not stay
> always in sCL state.

I'll have to read the code a bit more to completely understand that, but
it seems to make sense!

> As for the initial check, it should be:
> 	if ((sysctl_sloppy_tcp(net_ipvs(net)) || th->syn) &&
> +	    !th->rst &&

Make sense.

> 	Also, one can enable Sloppy TCP mode for short
> time during switchover, it should be safer to run with
> disabled mode.

The problem is that switchover won't necessarily be controlled if a
server fails.


Alex

