From: Dan Carpenter <error27@gmail.com>
Subject: Re: [PATCH] ipvs: initialize 'ret' variable in do_ip_vs_set_ctl()
Date: Fri, 2 Dec 2022 13:26:03 +0300
Message-ID: <Y4nSu7D5T2jDkXGK@kadam>
References: <20221202032511.1435-1-liqiong@nfschina.com>
 <Y4nORiViTw0XlU2a@kadam>
 <9bc0af1a-3cf0-de4e-7073-0f7895b7f6eb@nfschina.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date:from:to
         :cc:subject:date:message-id:reply-to;
        bh=jNLrMQiEM6rpQlVYEUNGp4QXPdu9DtLm7iUcNPRtKZw=;
        b=RjH3ddx6KxF5pUy3UjLPOERQnD+F6WxodSR7IxcB2vbYsVBWIF0hgjm6udRXUhASbv
         4ey8t12fwULfJ0ZMR7Vqs7oATPjSei7v6ZgPJuk9Kv9OS2To+YkgbLMQv4LrxVWRH4VF
         88tmGpuUvQbsilOQmRL3tjx3ac92rGJVLCfIeXsvIuJz0X4aAVCgv7r7h2LnQxxU/y2+
         qxkxdCs+pINgyJZ0MLkVe2YQDu3dIN0MY54rRDsM16GLwm5mXmyNZ0N3eZ0SwljbDcDB
         aMrzBeG3u6Ri0iEsQbiw0sF0xgGoP2SY03Os4t9dEQTsW++hnCVme8xZioDeSQsdiRWl
         9oNA==
Content-Disposition: inline
In-Reply-To: <9bc0af1a-3cf0-de4e-7073-0f7895b7f6eb@nfschina.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: liqiong <liqiong@nfschina.com>
Cc: Peilin Ye <yepeilin.cs@gmail.com>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, "David S . Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, kernel-janitors@vger.kernel.org, coreteam@netfilter.org, Yu Zhe <yuzhe@nfschina.com>

On Fri, Dec 02, 2022 at 06:18:37PM +0800, liqiong wrote:
> 
> 
> 在 2022年12月02日 18:07, Dan Carpenter 写道:
> > On Fri, Dec 02, 2022 at 11:25:11AM +0800, Li Qiong wrote:
> >> The 'ret' should need to be initialized to 0, in case
> >> return a uninitialized value because no default process
> >> for "switch (cmd)".
> >>
> >> Signed-off-by: Li Qiong <liqiong@nfschina.com>
> > If this is a real bug, then it needs a fixes tag.  The fixes tag helps
> > us know whether to back port or not and it also helps in reviewing the
> > patch.  Also get_maintainer.pl will CC the person who introduced the
> > bug so they can review it.  They are normally the best person to review
> > their own code.
> >
> > Here it would be:
> > Fixes: c5a8a8498eed ("ipvs: Fix uninit-value in do_ip_vs_set_ctl()")
> >
> > Which is strange...  Also it suggest that the correct value is -EINVAL
> > and not 0.
> >
> > The thing about uninitialized variable bugs is that Smatch and Clang
> > both warn about them so they tend to get reported pretty quick.
> > Apparently neither Nathan nor I sent forwarded this static checker
> > warning.  :/
> >
> > regards,
> > dan carpenter
> 
> It is not a real bug,   I  use tool (eg: smatch, sparse) to audit the
> code,  got this warning and check it, found may be a real problem.

Yeah.  If it is a false positive just ignore it, do not bother to
silence wrong static checker warnings.

The code in question here is:

	if (len != set_arglen[CMDID(cmd)]) {

The only time that condition can be true is for the cases in the switch
statement.  So Peilin's patch is correct.

Smatch is bad at understanding arrays so Smatch cannot parse the if
statement above as a human reader can.

regards,
dan carpenter

