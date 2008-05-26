From: "Julius Volz" <juliusv@google.com>
Subject: Re: First IPv6 support for IPVS and ipvsadm
Date: Mon, 26 May 2008 17:39:35 +0200
Message-ID: <f4845fc0805260839v3bbe7fder2507cff8ef006c4@mail.gmail.com>
References: <f4845fc0805230659o5464eb15i131790df8443349d@mail.gmail.com>
	 <Pine.LNX.4.64.0805230835510.27885@wm7d.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1211816377; bh=7FI4rGfFvRt+BhjG6wdGlPBZBPE=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=oP6+T2xQXvGSKlq2WiVtDwoIOtMWJhU1
	67qidxkKIOx8aPptxQliPJjbCB6COiFg2ies7Z2F8qdHQB1wib7tOQ==
In-Reply-To: <Pine.LNX.4.64.0805230835510.27885@wm7d.net>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Joseph Mack NA3T <jmack@wm7d.net>
Cc: lvs-devel@vger.kernel.org, Vince Busam <vbusam@google.com>, Simon Horman <horms@verge.net.au>

On Fri, May 23, 2008 at 5:36 PM, Joseph Mack NA3T <jmack@wm7d.net> wrote:
> On Fri, 23 May 2008, Julius Volz wrote:
>
>> Since fragmentation and extension headers should not occur very often,
>> things should "mostly" work. I tested HTTP and DNS over NAT and DR
>> with various supported schedulers without encountering any problems.
>
> great step forward.

Thanks! I hope breaking the userspace<->kernel interface is ok for
this? It would get much messier otherwise. This just means that
starting with a kernel version that contains these patches, you'll
have to use the new ipvsadm version (ipvsadm already has provisions
for detecting this by comparing version numbers).

Now how to proceed further? It would probably be helpful if people
could test their existing v4 setups with the patches to make sure that
the old functionality still works identically. That seems like the
most important thing for getting it accepted from the functionality
standpoint, so anyone who can give it a try in their test lab would
help (I will contact the people who were once interested in a v6
version). I'll also try splitting up the patch into smaller pieces so
it becomes somewhat more reviewable. It would also be cool to hear
from Horms if the direction in which this code is going is acceptable
at all or if we have to do things really differently...

Julius

-- 
Google Switzerland GmbH
