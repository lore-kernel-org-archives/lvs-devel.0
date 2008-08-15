From: "Julius Volz" <juliusv@google.com>
Subject: Re: [GIT] Please pull updates for IPVS
Date: Fri, 15 Aug 2008 13:31:59 +0200
Message-ID: <f4845fc0808150431l778618dcjf848774c38d86470@mail.gmail.com>
References: <20080815001250.GC15825@verge.net.au>
	 <20080814.172508.15803616.davem@davemloft.net>
	 <20080815010235.GD15825@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1218799924; bh=Rqd2e67ixlZzOn1/gUuPVbMtwi0=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=W/CRBn585zTKaBxPChBCG5gNR2tMvlzr
	DaoeHZ4QEIh3/w7/X6K2BFz8uZi3izHQTNNESvYjgicX+6QOgkT+Jg==
In-Reply-To: <20080815010235.GD15825@verge.net.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: David Miller <davem@davemloft.net>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, sven.wegener@stealer.net, wensong@linux-vs.org, ja@ssi.bg

On Fri, Aug 15, 2008 at 3:02 AM, Simon Horman <horms@verge.net.au> wrote:
> On Thu, Aug 14, 2008 at 05:25:08PM -0700, David Miller wrote:
>> From: Simon Horman <horms@verge.net.au>
>> Date: Fri, 15 Aug 2008 10:12:52 +1000
>>
>> > Julius, Sven and I would particularly like Julius' two changes to go
>> > in. They add a new interface which is currently unused and thus the
>> > likelihood of breakage seems low.
>>
>> Actually these are the two changes that should not go in at this
>> time.  This netlink stuff is a new feature, therefore not appropriate
>> to merge outside of the merge window.
>>
>> Bug fixes only now, please.
>
> Hi Dave,
>
> thanks for the clarification. In that case I believe that
> all of these changes can wait.

Ok, how does the process work? Do I send the patches again at a later
point or will they be pulled from your tree then?

Julius

-- 
Google Switzerland GmbH
