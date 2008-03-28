From: "Julius Volz" <juliusv@google.com>
Subject: Making IPVS work with IPv6
Date: Fri, 28 Mar 2008 16:45:37 +0100
Message-ID: <f4845fc0803280845n6a4d8683gffe95c8d64572971@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1206719139; bh=6/g+wdTuR0ogjhpdhwo3MOxi00c=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:Content-Disposition; b=oFJL
	P5ZD6fF6GXdj/BWEpQAT7AzXNHEvKrmYC2ciQtvGZmqKBYIRvA2JMhQj5k8AZEDhDsw
	NGYehJH0sQarr7w==
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org

Hi LVS devs,

I'm currently interning at Google Zurich and we are very interested in
porting IPVS to IPv6. Indeed, I will probably dedicate 60-70% of my
time to that cause for the next 5 months to come.

Now to be honest, although I've read a lot of kernel code and mailing
lists, I've never done any major kernel coding myself. I think I know
most of the fundamentals and am very excited about this, but I will
need lots of help and ask stupid questions ;)

Here are some questions that came up regarding this. I'd be very
thankful if any of you want to share your ideas on them!

1) It looks as though there is no current effort on the way to do this
port, right?
2) Are there any serious technical or political roadblocks to this we
are not seeing?
3) Currently, IPVS lives under .../net/ipv4/ipvs in the kernel, but
much of the code is not IPv4-specific. Any ideas on how to best
refactor that common code to make it usable for both IPv4 or IPv6?
4) How could this work be best split up into manageable chunks that
could either be worked on serially or in parallel (by multiple
developers)?
5) Who else would be interested in parts of this effort or just in
helping out when questions come up?

So I've been looking at the code for a couple of days now and some
parts I understand well, others I don't get at all, but I hope to
change that soon ;)

Looking forward to your replies!

Kind Regards,
Julius Volz

-- 
Google Switzerland GmbH
