From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: initialize 'ret' variable in do_ip_vs_set_ctl()
Date: Fri, 2 Dec 2022 13:26:26 +0200 (EET)
Message-ID: <7758482-42e8-9057-b568-3980858267f@ssi.bg>
References: <20221202032511.1435-1-liqiong@nfschina.com> <Y4nORiViTw0XlU2a@kadam> <9bc0af1a-3cf0-de4e-7073-0f7895b7f6eb@nfschina.com> <Y4nSu7D5T2jDkXGK@kadam>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="-1463811672-1864568413-1669980388=:40112"
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Y4nSu7D5T2jDkXGK@kadam>
List-ID: <lvs-devel.vger.kernel.org>
To: Dan Carpenter <error27@gmail.com>
Cc: liqiong <liqiong@nfschina.com>, Peilin Ye <yepeilin.cs@gmail.com>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, kernel-janitors@vger.kernel.org, Yu Zhe <yuzhe@nfschina.com>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-1864568413-1669980388=:40112
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit


	Hello,

On Fri, 2 Dec 2022, Dan Carpenter wrote:

> On Fri, Dec 02, 2022 at 06:18:37PM +0800, liqiong wrote:
> > 
> > 
> > 在 2022年12月02日 18:07, Dan Carpenter 写道:
> > > On Fri, Dec 02, 2022 at 11:25:11AM +0800, Li Qiong wrote:
> > >> The 'ret' should need to be initialized to 0, in case
> > >> return a uninitialized value because no default process
> > >> for "switch (cmd)".
> > >>
> > >> Signed-off-by: Li Qiong <liqiong@nfschina.com>
> > > If this is a real bug, then it needs a fixes tag.  The fixes tag helps
> > > us know whether to back port or not and it also helps in reviewing the
> > > patch.  Also get_maintainer.pl will CC the person who introduced the
> > > bug so they can review it.  They are normally the best person to review
> > > their own code.
> > >
> > > Here it would be:
> > > Fixes: c5a8a8498eed ("ipvs: Fix uninit-value in do_ip_vs_set_ctl()")
> > >
> > > Which is strange...  Also it suggest that the correct value is -EINVAL
> > > and not 0.
> > >
> > > The thing about uninitialized variable bugs is that Smatch and Clang
> > > both warn about them so they tend to get reported pretty quick.
> > > Apparently neither Nathan nor I sent forwarded this static checker
> > > warning.  :/
> > >
> > > regards,
> > > dan carpenter
> > 
> > It is not a real bug,   I  use tool (eg: smatch, sparse) to audit the
> > code,  got this warning and check it, found may be a real problem.
> 
> Yeah.  If it is a false positive just ignore it, do not bother to
> silence wrong static checker warnings.
> 
> The code in question here is:
> 
> 	if (len != set_arglen[CMDID(cmd)]) {
> 
> The only time that condition can be true is for the cases in the switch
> statement.  So Peilin's patch is correct.
> 
> Smatch is bad at understanding arrays so Smatch cannot parse the if
> statement above as a human reader can.

	Yes, no bug in current code. But it is better to return the 
default switch case with -EINVAL (not 0), in case new commands are added.
Such patch should target net-next, it is just for compilers/tools
that do not look into set_arglen[].

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-1864568413-1669980388=:40112--

