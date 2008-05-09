From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH] Move IPVS from net/ipv4/ipvs to net/netfilter/ipvs in preparation for IPv6 support
Date: Fri, 9 May 2008 15:46:58 +0200
Message-ID: <f4845fc0805090646i6ff5d7e8p3d52775419dc44a4@mail.gmail.com>
References: <f4845fc0805070732v516fc8c6y2cdddfd4f99c8f96@mail.gmail.com>
	 <Pine.LNX.4.64.0805070734580.6164@wm7d.net>
	 <f4845fc0805070851y7f1f00d0xd2dfcc7feb79c173@mail.gmail.com>
	 <Pine.LNX.4.64.0805090536120.22107@wm7d.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1210340821; bh=dTjzpIF7H8+C4gb4DRSm9jIGDDA=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=cSjLfAq5ap/lE40Y/4ent2hqQpjcT6MK
	rDDjctYqOlK+eLlxZ5w5kB8CcQQUlWKtfK9gYvHQUatIoxRD1oaohg==
In-Reply-To: <Pine.LNX.4.64.0805090536120.22107@wm7d.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Joseph Mack NA3T <jmack@wm7d.net>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Horms <horms@vergenet.net>

On Fri, May 9, 2008, Joseph Mack NA3T wrote:
> are you at a stage where it's all split up, after which you'll only be
> working on the ipv6 part and leaving the ipv4 untouched? Have you tested the
> ipv4 part to make sure it's still OK. ie the code is reorthogonalised but
> with no change in functionality?

No, I'm not at this stage yet, I'm approaching the problem from the
other direction, following your earlier advice: try to come up with
something that actually does something (hopefully in a couple of
weeks, due to other obligations), then worry about separation /
cleanup and more features. So everything is pretty hacky with lots of
open TODOs and stupid questions. It compiles, but running it wouldn't
make much sense (partially because of lacking userspace ipsvadm
support for the changes). I'm not even #ifdef-ing away my IPv6 code at
the moment...

What I did:

I basically copied lots of IPVS functions (yep, too much duplication,
unfortunately) that depend on the IP version and made corresponding
IPv6 versions of the function. A lot of this duplication could
probably be avoided by doing some heavy refactoring, but I tried to
stay away from that to minimize the chances of breaking the existing
code. Some few, not often called functions now handle both IP versions
in one function. The multiplexing of IPv4/IPv6 code is done either by
implicitly knowing which code path we're in (different paths resulting
from different NF hooks for IPv4/IPv6) or by looking at the new "af"
address family (AF_INET or AF_INET6) field introduced into all the
relevant IPVS data structures.

I didn't duplicate any data structures, even the actual hash tables
contain both IPv4 and IPv6 entries (differentiation done via the "af"
field). So far, this seems to work quite well... what I don't like
about this is that you have an additional space-taking IPv6 address
field in all data structures, even when it is not used. E.g., when
IPv6 support is compiled as a module, but it is not loaded. A later
move to use different structs for the cases that actually matter
(probably only the table of active connections) should be pretty easy,
though.

> One of the things I worry about (from personal experience) is people working
> on projects and getting stuck for time and later having to drop the work. If
> you can submit the reorthogonalised code, and have to stop sometime later,
> at least we've got that far down the road.

Yes, let's hope that will not happen. But sadly, I'm not at the stage
of having cleanly separated code, so submitting code isn't possible
yet :(

Julius

-- 
Google Switzerland GmbH
