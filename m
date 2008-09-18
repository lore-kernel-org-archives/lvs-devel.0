From: "Julius Volz" <juliusv@google.com>
Subject: Re: Should we move IPVS out of net/ipv4 now?
Date: Thu, 18 Sep 2008 22:04:28 +0200
Message-ID: <f4845fc0809181304y25e3df07xfde0f23406b519a2@mail.gmail.com>
References: <f4845fc0809170600s28495494l128f7dd6f00e34e3@mail.gmail.com>
	 <48D14E6D.4020407@redhat.com>
	 <20080917.131445.19943427.davem@davemloft.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1221768271; bh=nVPHorkIWfHJvXn5Mp/29Woq3zE=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=GBUDRXipZaysySvDb/bfvp9rLc3Z35Zw
	XOUe/Wc7yjC3ggAviEXHSg3+QZJNvAM8zdAg+tx+WNAdG1jdvEHn/Q==
In-Reply-To: <20080917.131445.19943427.davem@davemloft.net>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: David Miller <davem@davemloft.net>
Cc: csnook@redhat.com, horms@verge.net.au, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

On Wed, Sep 17, 2008 at 10:14 PM, David Miller wrote:
> From: Chris Snook <csnook@redhat.com>
> Date: Wed, 17 Sep 2008 14:37:33 -0400
>
>> Julius Volz wrote:
>> > Since IPVS now does partial IPv6, should we finally move it from
>> > "net/ipv4/ipvs" to "net" or to "net/netfilter"? I posted that patch a
>> > long time ago, but that was before any of the actual v6 features, so
>> > there was probably no interest.
>>
>> Whatever the netfilter people want is fine with me.
>
> I think, especially in the long term, putting IPVS under net/netfilter/
> is the right thing to do.

Ok thanks, I'll send the patch for that once lvs-next-2.6 or
net-next-2.6 builds for ARCH=um again (there seems to be some breakage
at the moment)...

Julius

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
