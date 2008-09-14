From: "Julius Volz" <juliusv@google.com>
Subject: Re: Adding SNAT support to LVS/NAT
Date: Sun, 14 Sep 2008 02:41:30 +0200
Message-ID: <f4845fc0809131741w15fd73d7w298b7e7c5dd4956a@mail.gmail.com>
References: <f4845fc0809130412n41967d79l1240558492c84cb7@mail.gmail.com>
	 <Pine.LNX.4.64.0809131100320.20936@wm7d.net>
	 <1221332109.4327.25.camel@ernie.internal.graemef.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1221352891; bh=VCh/iE+8glhIz3459g6Ublz1uUE=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=NJGGWIR8MwNkG4YfKsbcT+l47aU2nh28
	RdtZdFAjSS8RBotLLG2pxlMG+tfsN/d4n7h8XEBeU5cdPSHqyNkZMw==
In-Reply-To: <1221332109.4327.25.camel@ernie.internal.graemef.net>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Graeme Fowler <graeme@graemef.net>
Cc: Joseph Mack NA3T <jmack@wm7d.net>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, j.stubbs@linkthink.co.jp

On Sat, Sep 13, 2008 at 8:55 PM, Graeme Fowler <graeme@graemef.net> wrote:
> Hi
>
> On Sat, 2008-09-13 at 11:17 -0700, Joseph Mack NA3T wrote:
>> when we've discussed it before, the packets will appear to
>> come from the DIP, a private IP (or whatever IP the servers
>> were using for their default route before they were put into
>> an LVS).
>
> I'm a bit late to the party, but...
>
> Ideally, the packets would appear to come from the "inside face" of the
> director - usually (and in the most basic case) the NIC with an address
> on the same layer 3 network as the real servers. This way the default
> route would be ignored as there would normally be a more specific route
> for that network, namely straight out of the device the packets arrived
> on. Of course, if that coincides with the default gateway address, it'll
> still work anyway.

Yes. I think this is what I meant in my previous answer to Joe.

>> more importantly, people who are bound by serious IT rules
>> setup by managers, can duplicate their (real) servers only
>> with a change in RIP on each server and can keep the default
>> route.
>
> This is the single most compelling thing about this setup.
>
> It's simultaneously a problem in that for (say) an HTTP server, all the
> requests will appear to be sourced from the director's internal address.
> For many applications this won't be acceptable, not least in that for
> the webserver case log processing will be an irrelevance!
>
> Anyone know how the F5 hardware gets around this? I can't get my hands
> on any to test...

Yes, this is a known issue that is usually handled by injecting
something like an X-User-IP header into the HTTP request. Hard to do
in IPVS (could be done in an app helper though, I assume).

Julius

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
