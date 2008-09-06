From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH 2/2] ipvs: load balance ipv6 connections from a local process
Date: Sat, 6 Sep 2008 11:26:29 +0200
Message-ID: <f4845fc0809060226g4ee00f4fs210ba76309130be7@mail.gmail.com>
References: <20080905013609.GD14128@verge.net.au>
	 <20080905013755.GE14128@verge.net.au>
	 <f4845fc0809050440g24f304d9xec7982e984830c6e@mail.gmail.com>
	 <20080906041436.GB21521@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220693193; bh=xIOvwt0XEiAAQsimzv19ygVMtEU=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=OwC/KUMvbuCU5TKu6PJNag8nex0mtqwB
	KDAFi0t3mYJ1sbt1MDvPnlm3BC4wEyBhO9yHfccbUFs2cnvqj7oBhQ==
In-Reply-To: <20080906041436.GB21521@verge.net.au>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Malcolm Turnbull <malcolm@loadbalancer.org>, =?ISO-8859-1?Q?Siim_P=F5der?= <siim@p6drad-teel.net>, Vince Busam <vbusam@google.com>

On Sat, Sep 6, 2008 at 6:14 AM, Simon Horman <horms@verge.net.au> wrote:
> On Fri, Sep 05, 2008 at 01:40:31PM +0200, Julius Volz wrote:
>> Hi,
>>
>> Just some minor things:
>
> Hi Julius,
>
> thanks for pointing these out. I will send patches to fix these problems ASAP.

Thanks, looking good!

> More generally speaking, sorry to all parties concerned for applying
> these two patches a little prematurely. At this stage I'd rather move
> forward rather than roll the tree back. But I am happy to discuss this.

Probably better to just go forward when the tree is already public?

Julius

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
