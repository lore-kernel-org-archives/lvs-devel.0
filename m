From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH ipvs-next] ipvs: Remove
 rcu_read_unlock();rcu_read_lock();
Date: Thu, 25 Apr 2013 07:04:03 -0700
Message-ID: <1366898643.8964.139.camel@edumazet-glaptop>
References: <1366852353-32561-1-git-send-email-horms@verge.net.au>
	 <alpine.LFD.2.00.1304251038541.1752@ja.ssi.bg>
	 <1366880726.2628.177.camel@hawk.mlab.se>
	 <20130425133639.GC10898@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=x-received:message-id:subject:from:to:cc:date:in-reply-to
         :references:content-type:x-mailer:content-transfer-encoding
         :mime-version;
        bh=0b5e+x5vOXfR52zOPW36orfZO9dPsb+qTHxXmZfSBIA=;
        b=U6VR+geKK0k+oAxy1u/RWWO234ObAK0o2/9YSLv7Zrut1L8qNghw3GvA9A1k8HPvGL
         WudhejJ00iBjkoFeOBrqdd9aeAW28+9QboQUb2RKLAwZu5CVjr+KMjItLyYdqnaeNAAi
         TvJPKrWTnydEJXtVpl1vc7JwgZy+Io67nqF/i7WVia886e/z+KH2W73WgMK//atXAXM8
         iF3+w2yf1vfeJIY096aRs8t1m3EJXuCXvHB+uCmjdcemseCrkpA//RyQ+e90LpE6527o
         eIgtcO02r0tLOUpuBBCBf4aVjtYLaAdpi/C1n+KgqlklUy90nhRG2pgXyUB+s0dCiwY1
         I5dg==
In-Reply-To: <20130425133639.GC10898@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: Hans Schillstrom <hans@schillstrom.com>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>

On Thu, 2013-04-25 at 22:36 +0900, Simon Horman wrote:

> Ok, leaving it seems reasonable.
> Pablo, do you have any objections?

I have objections.

I would _add_ a cond_resched() there to explicitly do what we want

Maybe a macro/inline doing this already exists.

static void inline cond_resched_rcu_lock(void)
{
	if (need_resched()) {
		rcu_read_unlock();
		cond_resched();
		rcu_read_lock();
	}
}





