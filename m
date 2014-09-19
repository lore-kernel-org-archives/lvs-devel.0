From: Alexey Andriyanov <alan@al-an.info>
Subject: Re: IPVS Health Checking Best Practices
Date: Fri, 19 Sep 2014 08:31:05 +0400
Message-ID: <541BB189.6050901@al-an.info>
References: <541B4E22.6080802@fb.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=al-an.info; s=mail; t=1411101065;
	bh=S2dWrZBf3WzgNS0epZK3yLLGiZSGYYMY1KMCyxxgPOw=;
	h=Message-ID:Date:From:User-Agent:MIME-Version:To:CC:Subject:
	 References:In-Reply-To:Content-Type:Content-Transfer-Encoding;
	b=rs9Rc3B5Fk9E1mYWSH0ySyVBavycsPdhX7s78lQ8aAIhDrDjc0SCPOVW1y5dBkVGL
	 kMK8+J+eUcOTK745niUnlX4Ju22hUGl1Ot7rETxGlEoUgge8NPuqDdPUDpRb4cPq8w
	 kG1phpH+WWqYYlsyoPecHSDmGk2V0fA8gnXSEcRg=
In-Reply-To: <541B4E22.6080802@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Alex Gartrell <agartrell@fb.com>, lvs-devel@vger.kernel.org
Cc: dsp@fb.com, kernel-team <Kernel-team@fb.com>, ps@fb.com

Hi, Alex.

We use tunnel checks to the host itself. The encapsulated packet looks like this:
CHK_SRC -> RS1 [ (IPIP) CHK_SRC -> VIP1 ].

This could be done without maintaining iptables rules or tunnel interfaces.
You simply apply fwmark corresponding to a proper RS to checker socket via SO_MARK. Then direct all marked packets in OUTPUT to the NFQUEUE, and encapsulate a packet in user-space, selecting tunnel endpoint based on fwmark.

We use keepalived + this little tool for that: https://github.com/andriyanov/check-tun


19.09.2014 01:26, Alex Gartrell wrote:
> Hello All,
> 
> Today, we run IPVS on a number of hosts.  Each of these hosts has a python process responsible for ensuring the health of pool members and then updating their weights as necessary.
> 
> We do these health checks via IPVS for two reasons:
> 1) Different VIPs have different listeners on our real servers, so we can't just use the regular host address
> 2) We want to ensure that decapsulation is happening appropriately.
> 
> The way we do this today is a giant hack.  We have a scheduler that we've not (yet) open sourced that does consistent hashing, and someone just wired in a couple additional sysctls that will allow you to do the following:
> 
> If a request is from $MAGIC_IP and the source port is >= $MAGIC_PORT, then send it to pool->members[($SRC_PORT - $MAGIC_PORT) % $N].
> 
> I'd like to solve this problem more generally.
> 
> The other solution I've heard of is using fwmarks, but that kind of sucks from a configuration perspective (because you have to add in all of the persistent vips and everything).
> 
> Here are some other ideas:
> 
> 1) Map the socket itself to a particular pool with a netlink invocation or something
> 
> 2) Provide a way to bind specific src addr, port tuples to specific destination (though this is a bummer because you have to reserve port space)
> 
> But I'm completely open to ideas and I think we're willing to do the work to make this happen.
> 
> 
> Thanks,
> 

-- 
Best regards,
Alexey 
