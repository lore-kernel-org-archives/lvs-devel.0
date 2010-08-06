From: Simon Horman <horms@verge.net.au>
Subject: Re: [rfc 13/13] [RFC 13/13] IPVS: sip persistence engine
Date: Fri, 6 Aug 2010 10:46:00 +0900
Message-ID: <20100806014600.GD12311@verge.net.au>
References: <20100805114755.118303531@vergenet.net>
 <20100805115242.056724322@vergenet.net>
 <alpine.LSU.2.01.1008051447100.13201@obet.zrqbmnf.qr>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.01.1008051447100.13201@obet.zrqbmnf.qr>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jan Engelhardt <jengelh@medozas.de>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

On Thu, Aug 05, 2010 at 02:50:11PM +0200, Jan Engelhardt wrote:
> On Thursday 2010-08-05 13:48, Simon Horman wrote:
> >+
> >+static const char *ip_vs_dbg_callid(char *buf, size_t buf_len,
> >+				    const char *callid, size_t callid_len,
> >+				    int *idx)
> >+{
> >+	size_t len = min(min(callid_len, (size_t)64), buf_len - *idx - 1);
> >+	memcpy(buf + *idx, callid, len);
> >+	*(buf + *idx + len) = '\0';
> 
> Nothing particular wrong, though I just noticed that I would have 
> personally, instinctively written
> 
> 	buf[*idx+len] = '\0';
> 
> instead. Sure you have your reasons ;-)

Actually, I had a bit of trouble writing that code clearly
(though I'm not sure why, perhaps it was late in the day).
I think your suggestion looks good.

> >+	/* RFC 2543 allows lines to be terminated with CR, LF or CRLF,
> >+	 * RFC 3261 allows only CRLF, we support both. */
> >+	if (*(dptr + *matchoff + *matchlen) != '\r' &&
> >+	    *(dptr + *matchoff + *matchlen) != '\n')
> >+		return -EINVAL;
