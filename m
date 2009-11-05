From: Simon Kirby <sim@hostway.ca>
Subject: Re: test
Date: Thu, 5 Nov 2009 02:11:18 -0800
Message-ID: <20091105101118.GG5244@hostway.ca>
References: <20091104202716.GE14821@hostway.ca> <Pine.LNX.4.58.0911051119190.2761@u.domain.uli>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0911051119190.2761@u.domain.uli>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org

On Thu, Nov 05, 2009 at 11:26:27AM +0200, Julian Anastasov wrote:

> 	If 'time to expire' is after current time then continue,
> i.e. current time didn't reached the limit, seems correct,
> no need to patch. For better reading and to match
> ip_vs_lblcr_check_expire() it can be converted to:
> 
> if (time_before(now, en->lastuse+sysctl_ip_vs_lblcr_expiration))
> 	continue;

D'oh.  I noticed the use of time_before() further down in
ip_vs_lblcr_check_expire(), but not the reversed arguments, hence my
confusion.

I still suspect there may be something not quite right, or which could
perhaps do with some tuning.  It's difficult to see exactly how it's
working internally, since there's currently nothing to get a summary of
the dest_sets to userspace.  I'll follow up if I find anything.

Simon-
