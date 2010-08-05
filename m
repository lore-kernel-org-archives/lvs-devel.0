From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [rfc 13/13] [RFC 13/13] IPVS: sip persistence engine
Date: Thu, 5 Aug 2010 14:50:11 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1008051447100.13201@obet.zrqbmnf.qr>
References: <20100805114755.118303531@vergenet.net> <20100805115242.056724322@vergenet.net>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100805115242.056724322@vergenet.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

On Thursday 2010-08-05 13:48, Simon Horman wrote:
>+
>+static const char *ip_vs_dbg_callid(char *buf, size_t buf_len,
>+				    const char *callid, size_t callid_len,
>+				    int *idx)
>+{
>+	size_t len = min(min(callid_len, (size_t)64), buf_len - *idx - 1);
>+	memcpy(buf + *idx, callid, len);
>+	*(buf + *idx + len) = '\0';

Nothing particular wrong, though I just noticed that I would have 
personally, instinctively written

	buf[*idx+len] = '\0';

instead. Sure you have your reasons ;-)

>+	/* RFC 2543 allows lines to be terminated with CR, LF or CRLF,
>+	 * RFC 3261 allows only CRLF, we support both. */
>+	if (*(dptr + *matchoff + *matchlen) != '\r' &&
>+	    *(dptr + *matchoff + *matchlen) != '\n')
>+		return -EINVAL;

