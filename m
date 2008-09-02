From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCHv2 RFC 00/00] Add first IPv6 support to IPVS
Date: Tue, 2 Sep 2008 11:22:14 +0200
Message-ID: <f4845fc0809020222n30c13307xc930955dc73cdb12@mail.gmail.com>
References: <1220273782-19901-1-git-send-email-juliusv@google.com>
	 <20080902081841.GM13730@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220347338; bh=Vc1KDS4j4xGW55iTUeLqOKgxDb4=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=GhJLO/9gYZXf1dejqmuytSba2mNYYRDl
	JHrmVBBT2u/CHquOSRFsNXIRxmrjyATrHSIsNV/lR89SccwN6GxvmA==
In-Reply-To: <20080902081841.GM13730@verge.net.au>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com

On Tue, Sep 2, 2008 at 10:18 AM, Simon Horman <horms@verge.net.au> wrote:
> On Mon, Sep 01, 2008 at 02:55:57PM +0200, Julius Volz wrote:
>> I now managed to rework the IPVS IPv6 patches in a way that the kernel
>> builds after each patch in the series. Sometimes, this adds some
>> ugliness in the form of temporary constructs which are introduced in one
>> patch and deleted in the next ones. I've also integrated other small bug
>> fixes and cleanups from comments on the mailing lists.
>
> Thanks, I appreciate that. I think that these patches are starting
> to look quite nice. I've posted some coments (all relating to style I
> think) to some of the patches. Nothing else has caught my eye so far.

Great, thanks! I will now fix all the style issues you pointed out in
the other mails!

>> Note: these patches are not based on net-2.6 anymore, but on lvs-2.6:
>
> I've verified that these patches apply against the lvs-next-2.6 branch of
> of the lvs-2.6 tree. Which means they should also apply against Dave's
> net-next-2.6 tree (net-next-2.6 and lvs-next-2.6 are currently converged).
> Which would seem to be the most likely target for these changes at this
> time.

That would be awesome!

>> git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-2.6.git
>>
>> - Full kernel patch in one file:
>>   http://www-user.tu-chemnitz.de/~volz/ipvs_ipv6/ipvs_ipv6_v2.patch
>>
>> While not all IPv6 features are working or tested, existing IPv4 features
>> should still work as before. However, to use any of the new features, you
>> will need a new ipvsadm with support for genetlink and IPv6:
>
> I'm comfortable with merging things in that state.
>
> It seems quite reasonable to add IPv6 features in an iterative
> manner so long as IPv4 keeps working.

Yes, people should test especially if there are any problems with the
existing IPv4 features...

Julius

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
