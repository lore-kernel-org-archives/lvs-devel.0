From: Alex Gartrell <alexgartrell@gmail.com>
Subject: Re: [PATCH,v2 net-next] ipvs: skb_orphan in case of forwarding
Date: Sun, 5 Jul 2015 21:14:38 -0700
Message-ID: <CALCkm3d4Xqq+eWryejKhi84rM_fS4QRyu8Fn_Z7RHZv+zbv3_Q@mail.gmail.com>
References: <1436131706-1559824-1-git-send-email-agartrell@fb.com>
 <alpine.LFD.2.11.1507060105470.12815@ja.home.ssi.bg> <CALCkm3eyEbHpzfF1zk0OUnGaSf51=r9DmZs_2Xq4fTtOed3nNQ@mail.gmail.com>
 <20150706035019.GA9155@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:in-reply-to:references:from:date:message-id:subject:to
         :cc:content-type;
        bh=z0TTsldpk+MFqqWjB5xwIcqrg99Dobd4B37T8zhfXaQ=;
        b=DAFLe4sIdsSzGyrAC2nHlDLYpOmYPCfsQY5LfyrPuOhRKQLZQ9FY3YT0A7DMwc0Vlv
         7UssGwaBQJAJ2B+CHko9TcAd+rwmLQTzbS6gaOLH1bmOj1GGZ589Qly6Pr7cYjHyg9Xh
         +vibocNJpKYyolrgi4DyKOTtYwVoUGYnei2uR8Umw4L8QCwoRronqVhPf3lLs+owe9Um
         Va8oWfKPUER//5fwGxweuHK25xG9xG5l64xTeRDR3lF3nYMXUxDBKpg8+rZYdoAu5HCg
         NJtbc1ntgbGtpJDA+2hAuykpcbZnMrDSR95QWHm/KwtrsiNlU1ZjtiKvRTKc5zKdwgLH
         gWsg==
In-Reply-To: <20150706035019.GA9155@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>, Alex Gartrell <agartrell@fb.com>, lvs-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>, kernel-team <kernel-team@fb.com>

On Sun, Jul 5, 2015 at 8:50 PM, Simon Horman <horms@verge.net.au> wrote:
> Is it possible to get a 'Fixes:' tag?

I suppose it'd be appropriate to say

Fixes: 41063e9dd119 ("ipv4: Early TCP socket demux.")

As that is what introduces tcp early_demux, but that's just a guess as
I haven't bisected it (not even sure my test would run on that code
base).

-- 
Alex Gartrell <agartrell@fb.com>
