From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPVS: Allow boot time change of hash size.
Date: Tue, 02 Dec 2008 14:51:29 -0800 (PST)
Message-ID: <20081202.145129.06176881.davem@davemloft.net>
References: <55785.91.201.80.240.1227862171.squirrel@mail.embedromix.ro>
	<Pine.LNX.4.64.0811280653570.21298@wm7d.net>
	<54783.91.201.80.240.1228232062.squirrel@mail.embedromix.ro>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <54783.91.201.80.240.1228232062.squirrel@mail.embedromix.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: catab@embedromix.ro
Cc: jmack@wm7d.net, netdev@vger.kernel.org, lvs-devel@vger.kernel.org

From: "Catalin(ux) M. BOIE" <catab@embedromix.ro>
Date: Tue, 2 Dec 2008 08:34:22 -0700 (MST)

> Hello, Joe!
> 
> > On Fri, 28 Nov 2008, Catalin(ux) M. BOIE wrote:
> >
> >> Hello, Joe!
> >>
> >> No, I did not measure it, but, I read the help text:
> > .
> > .
> >> The help is wrong or I am missing something?
> >
> > there's a bit somewhere else in the same section saying not
> > to change the hash size unless you know more than we do :-)
> 
> Where, exactly?
> 
> So, should I not change it at all even if I have a great number of
> simultaneously connections?

You should only ever change something like this if you actually
observe a specific performance problem.

This is the part that is driving everybody crazy about your
report.  You seem to be changing this without having observed
a measurable performance problem first, and then tracked it down
specifically to this hash table's size.

You seem to want to change it because it seems to you like that is
what should be done.  You don't really know if it even matters or not
for your workload.
