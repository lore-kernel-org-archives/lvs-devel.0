From: Andrey Utkin <andrey.krieger.utkin@gmail.com>
Subject: Re: [PATCH 3/5] net/netfilter/ipvs/ip_vs_ctl.c: drop argument range
 check just before the check for equality
Date: Sat, 19 Jul 2014 00:06:28 +0300
Message-ID: <CANZNk83dJCXAWrQ+i5rh=sdUuiiD5ZhzDua-rjJpBZCzzNGDJA@mail.gmail.com>
References: <1405697638-23767-1-git-send-email-andrey.krieger.utkin@gmail.com>
	<alpine.LFD.2.11.1407182339160.2273@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:in-reply-to:references:date:message-id:subject:from:to
         :cc:content-type;
        bh=xjWr8firBUKbaaNx/Kkhg4JbuKefYqnUdNXrVOjT9P4=;
        b=sgHXurVqCPwaZo+NgbIz2VjLjgWPtBjJKtf7SDQjaNZ2ycubD1hhYJ9gxYiTUWdkpl
         r4izykk2xrGpFQHuUggD7fQCiCsRYmv8SdN5yrPZ7BjME7BQTNVtjvkScLFlpQLE6s9A
         gtubk7WvaMdcFcVOluB7xHGLWEYn36WUvZmnHDZDM6VmN+g64yFPeZwcXqsII9Yfn6Rv
         O0zeeAOuqF5hnxDqQVcg3N1/HTohOA+O5LCbsNmSDPClKeFiUxNIoVinZ0lipfivB1AZ
         1v3I0txkgbRw6oOzv7b3jH0aL3og2j2gCfZ5FELdUOp8LZ5OIu3E+XqYoRw7sERq0hCF
         rk5A==
In-Reply-To: <alpine.LFD.2.11.1407182339160.2273@ja.home.ssi.bg>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, coreteam@netfilter.org, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, dcb314@hotmail.com, David Miller <davem@davemloft.net>, kadlec@blackhole.kfki.hu, Patrick McHardy <kaber@trash.net>, pablo@netfilter.org, Simon Horman <horms@verge.net.au>, wensong@linux-vs.org

2014-07-18 23:48 GMT+03:00 Julian Anastasov <ja@ssi.bg>:
>         The above check ensures the set_arglen[] value (some
> struct size) does not exceed the arg[MAX_ARG_LEN] space. You can check
> commit 04bcef2a83f40c ("ipvs: Add boundary check on ioctl arguments")
> for more info.

Thanks for info.
What about static check at compilation time?

#if (DAEMON_ARG_LEN > MAX_ARG_LEN) \
 || (SERVICE_ARG_LEN > MAX_ARG_LEN) \
 || (SVCDEST_ARG_LEN > MAX_ARG_LEN)
#error MAX_ARG_LEN exceeded in set_arglen table
#endif

-- 
Andrey Utkin
