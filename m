From: Simon Horman <horms@verge.net.au>
Subject: Re: Adapting LVS in order to allow Call-Id based persistence
Date: Thu, 3 Apr 2008 14:22:45 +0900
Message-ID: <20080403052243.GA1683@verge.net.au>
References: <c2f80c020804020703u6ebd4ed6oc430668daae94b30@mail.gmail.com> <Pine.LNX.4.64.0804020713370.25100@wm7d.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804020713370.25100@wm7d.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joseph Mack NA3T <jmack@wm7d.net>
Cc: pierrick grasland <pierrick.grasland@gmail.com>, lvs-devel@vger.kernel.org

Hi Pierrick, Hi Joe,

I'm a bit rusty on SIP as it is several years since I worked on it,
but I have found a local version of my patches and had a look over
them.

Basically my idea was to establish "persistence engines" inside LVS.
That is, to allow LVS to have modules that determine persistence -
kind of analogous to the scheduling modules that are already present in
LVS. This would in theory allow different persistence models to be
combined with each of the existing scheduling modules.

  [new connection rx] -> [persistence engine] -> [scheduler] -> [xmit]

I then implemented a SIP persistence module that did persistence
using the Caller-Id as the key rather than the usual ip:port key.

I can't actually remember how well it worked, all I can find in
my notes is a reference to the project being halted before it was
finished. (I do recall having a lot of trouble getting SIP to work
at all due to unreliable SIP software stacks, but as I mentioned,
it was a while ago.)

I should note that the patches I have are against a rather ancient
kernel - 2.4.26. But if there is interest in them I can talk to
the client for that project about releasing the code.

-- 
Horms

