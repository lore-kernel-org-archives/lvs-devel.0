From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH] Move IPVS from net/ipv4/ipvs to net/netfilter/ipvs in preparation for IPv6 support
Date: Wed, 7 May 2008 17:51:54 +0200
Message-ID: <f4845fc0805070851y7f1f00d0xd2dfcc7feb79c173@mail.gmail.com>
References: <f4845fc0805070732v516fc8c6y2cdddfd4f99c8f96@mail.gmail.com>
	 <Pine.LNX.4.64.0805070734580.6164@wm7d.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1210175517; bh=ghuvFq8NgqKU2kFF+lWNh3NxefM=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=Hmi5EDjWg26lCiJKm5UgXo20eJG5PYFl
	bNgD1o7WL+0hBy2Dap44NmEhsNnHlei3LsTfRX/4To0csBNnOlLvgQ==
In-Reply-To: <Pine.LNX.4.64.0805070734580.6164@wm7d.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Joseph Mack NA3T <jmack@wm7d.net>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org

Hi Joe,

On Wed, May 7, 2008, Joseph Mack NA3T wrote:
>  With the little time lvs developers have had for ipv6 so far, you're not
> likely to get much feedback from people here I'm sorry to say.

Hm, ok. This patch doesn't touch any functionality though. It only
moves files from one directory to another, so it's merely cosmetics,
no IPv6 knowledge required. Of course, we could still do the move
later, after some IPv6 code is actually in IPVS. If there is no
reaction, I'll just continue working under net/ipv4/ipvs for now. No
big deal.

>  The people who are interested in ipv6 have posted to the mailing list. Some
> of them may still be interested in lvs-ipv6 and in testing patches. Looking
> for ipv6 in
>
>  http://marc.info/?l=linux-virtual-server&m=116664927421172&w=2
>
>  [addresses]

Thank you! Good to have interested people for testing later on. We
also have some, but different people and organizations have different
setups and edge cases to help testing.

The other code I have at the moment compiles (sometimes), but doesn't
do much more. It needs much more work to actually do something again
with either IP version.

>  Seiji Tsuchiike <tsuchiike () yggr-drasill ! com> #the original ipv6
> implementation for LVS, doesn't respond to e-mail and is not findable with
> google.

Yes, he and his code seem to have disappeared...

>  "Fernanda G Weiden" <fernanda@softwarelivre.org> #I think she's with you

Yes! :)

>  A pair of people working for a company installing gear at govt sites was
> interested enough in getting an ipv6 port of LVS to offer Horms some money
> for his time, but Horms didn't have time at any price. You'd think I'd be
> able to find the e-mail from these people, but apparently I can't think of
> the correct grep string.

Ok, thanks. Let me know in case you stumble over it!

>  You might e-mail all these people above and as well put out notices of new
> releases of code onto the regular LVS mailing list. Someone may be
> listening, or they'll pick it up from one of the archivers.

Yes, once there is code that does something useful! At the moment, it
seems like a hamburger too big to get a good first bite at. But I'm
working on it...

Thanks for responding once again, Joe!

Julius

-- 
Google Switzerland GmbH
