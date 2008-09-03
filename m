From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCHv3 00/24] Add first IPv6 support to IPVS
Date: Wed, 3 Sep 2008 11:03:59 +0200
Message-ID: <f4845fc0809030203hc59de33k15e35ba62a02be07@mail.gmail.com>
References: <1220363755-9854-1-git-send-email-juliusv@google.com>
	 <20080903004050.GA12550@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220432642; bh=VWZNfnqy3QcU+lnMP7xUteVwDvg=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=m0nXn1p6u9otYQ8mFqzO4z17hNs9yYRC
	aOm1tHy1nPmFQ2FUpxpOwXHVWUntcU2mV69YCNbpN+BDlQy9z+Gt8Q==
In-Reply-To: <20080903004050.GA12550@verge.net.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com

On Wed, Sep 3, 2008 at 2:40 AM, Simon Horman <horms@verge.net.au> wrote:
> On Tue, Sep 02, 2008 at 03:55:31PM +0200, Julius Volz wrote:
>> Hi Horms,
>>
>> Here comes the whole batch again! I've fixed almost all style issues
>> reported by checkpatch.pl, except for some little things which look like
>> they could stay like they are for now (down to 3 warnings and 2 errors).
>> I also integrated your other comments and removed the patch that
>> adds the changelog information (not needed anymore, according to
>> Stephen).
>
> Hi Julius,
>
> thanks once again, this series addresses all of the (minor) concerns that
> I had yesterday. I'd like to let them sit on netdev for another day or two,
> to give a chance for further review by others. If things are still
> clear at that time I think it would be a good time to merge things.

Yes, sounds good! Thanks!

Julius

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
