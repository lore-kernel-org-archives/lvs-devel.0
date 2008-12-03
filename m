From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPVS: Allow boot time change of hash size.
Date: Tue, 02 Dec 2008 16:37:29 -0800 (PST)
Message-ID: <20081202.163729.158874214.davem@davemloft.net>
References: <54783.91.201.80.240.1228232062.squirrel@mail.embedromix.ro>
	<20081202.145129.06176881.davem@davemloft.net>
	<49597.86.34.32.157.1228259764.squirrel@mail.embedromix.ro>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <49597.86.34.32.157.1228259764.squirrel@mail.embedromix.ro>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: catab@embedromix.ro
Cc: jmack@wm7d.net, netdev@vger.kernel.org, lvs-devel@vger.kernel.org

From: "Catalin(ux) M. BOIE" <catab@embedromix.ro>
Date: Tue, 2 Dec 2008 16:16:04 -0700 (MST)

> > From: "Catalin(ux) M. BOIE" <catab@embedromix.ro>
> > Date: Tue, 2 Dec 2008 08:34:22 -0700 (MST)
> >
> > This is the part that is driving everybody crazy about your
> > report.  You seem to be changing this without having observed
> > a measurable performance problem first, and then tracked it down
> > specifically to this hash table's size.
> 
> I was looking for anything that could get me past of 88.000 request per
> seconds.
> The help text told me to raise that value if I have big number of
> connections. I just needed an easy way to test.

You're just repeating what I said, you "think" it should be
changed and as a result you are wasting everyones time.

You don't actually "know", you're just guessing using random
snippets from documentation rather than good hard evidence of
a need.
