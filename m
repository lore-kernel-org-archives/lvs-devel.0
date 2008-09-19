From: "Julius Volz" <juliusv@google.com>
Subject: Re: Should we move IPVS out of net/ipv4 now?
Date: Fri, 19 Sep 2008 11:47:13 +0200
Message-ID: <f4845fc0809190247l631c2a56se956f46078b41ef3@mail.gmail.com>
References: <20080917.131445.19943427.davem@davemloft.net>
	 <f4845fc0809181304y25e3df07xfde0f23406b519a2@mail.gmail.com>
	 <20080918235220.GD13536@verge.net.au>
	 <20080918.170030.32445027.davem@davemloft.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1221817636; bh=iirCHKOKrHFzJTiIg2R/XP0E6dQ=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=MdF5XkbvEKoYIjMHEwCsTpmkM06He4IL
	OEY5XfA0Xffct+Ti7ElW0qj1XqyFujFErqVfcSA39oWZWJ8itb7jug==
In-Reply-To: <20080918.170030.32445027.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: David Miller <davem@davemloft.net>
Cc: horms@verge.net.au, csnook@redhat.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

On Fri, Sep 19, 2008 at 2:00 AM, David Miller wrote:
> From: Simon Horman <horms@verge.net.au>
> Date: Fri, 19 Sep 2008 09:52:22 +1000
>
>> On Thu, Sep 18, 2008 at 10:04:28PM +0200, Julius Volz wrote:
>> > On Wed, Sep 17, 2008 at 10:14 PM, David Miller wrote:
>> > > From: Chris Snook <csnook@redhat.com>
>> > > Date: Wed, 17 Sep 2008 14:37:33 -0400
>> > >
>> > >> Julius Volz wrote:
>> > >> > Since IPVS now does partial IPv6, should we finally move it from
>> > >> > "net/ipv4/ipvs" to "net" or to "net/netfilter"? I posted that patch a
>> > >> > long time ago, but that was before any of the actual v6 features, so
>> > >> > there was probably no interest.
>> > >>
>> > >> Whatever the netfilter people want is fine with me.
>> > >
>> > > I think, especially in the long term, putting IPVS under net/netfilter/
>> > > is the right thing to do.
>> >
>> > Ok thanks, I'll send the patch for that once lvs-next-2.6 or
>> > net-next-2.6 builds for ARCH=um again (there seems to be some breakage
>> > at the moment)...
>>
>> Once net-next-2.6 is working again, let me know and I'll pull it
>> into lvs-next-2.6.
>
> I can't fix this if people don't tell me what the problem is.

Sorry, I sent this from an environment where I didn't have the
information and just wanted to give a quick ACK on the IPVS move
decision.

The build with ARCH=um seems to have a problem with the
architecture-specific headers:

net/core/skb_dma_map.c: In function 'skb_dma_map':
net/core/skb_dma_map.c:20: error: implicit declaration of function
'dma_mapping_error'

The bad commit that introduces the skb_dma_map.c file (and this error)
is a40c24a1336. Previous versions build fine.

> Is there some upstream fix and cures this and all I need to do is
> sync net-next-2.6 up with Linus's tree?  Is there some external
> fix?

Linus' linux-2.6 (he doesn't have a linux-next-2.6, right?) works, but
that doesn't even contain the file that has the build problem.

> It's totally stupid to stall development because of an issue like this
> yet give no direction or diagnostics we can use as a path to resolve
> it.

Yes, I'll give a better report next time.

Julius

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
