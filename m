From: "Julius Volz" <juliusv@google.com>
Subject: Re: [GIT] Please pull updates for IPVS
Date: Fri, 15 Aug 2008 23:39:15 +0200
Message-ID: <f4845fc0808151439o6e97d26p70e1939c5e561f99@mail.gmail.com>
References: <20080814.172508.15803616.davem@davemloft.net>
	 <20080815010235.GD15825@verge.net.au>
	 <f4845fc0808150431l778618dcjf848774c38d86470@mail.gmail.com>
	 <20080815.141841.268348002.davem@davemloft.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1218836358; bh=EJbsQ3m0FSTbhTTL+BdZ4K9Sxx0=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=vR65xFF7zET89eH8GH5m/YffqKi009Wc
	6pt/0R6GA3XFHsAswJRA17vAcJHHc56ARTwSP5+QV+lvhb+pmeon/A==
In-Reply-To: <20080815.141841.268348002.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: David Miller <davem@davemloft.net>
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, sven.wegener@stealer.net, wensong@linux-vs.org, ja@ssi.bg

On Fri, Aug 15, 2008 at 11:18 PM, David Miller <davem@davemloft.net> wrote:
> From: "Julius Volz" <juliusv@google.com>
> Date: Fri, 15 Aug 2008 13:31:59 +0200
>
>> On Fri, Aug 15, 2008 at 3:02 AM, Simon Horman <horms@verge.net.au> wrote:
>> > thanks for the clarification. In that case I believe that
>> > all of these changes can wait.
>>
>> Ok, how does the process work? Do I send the patches again at a later
>> point or will they be pulled from your tree then?
>
> Simon can maintain a tree if he wants, and your feature patches can
> go into there.
>
> Later when I start accepting net-next-2.6 stuff, I can pull things in
> from him.
>
> Or Sven can maintain such a GIT tree, whoever wants to do it.

Ok, thanks!

Sorry, I was not fully aware about the process and what may go in
when. From reading about it, it seems that after an -rc1, only bug
fixes are accepted until after the stable release. So I guess you only
start accepting net-next-2.6 stuff after the official stable release,
too?

Julius

-- 
Google Switzerland GmbH
