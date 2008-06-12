From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH 24/26] IPVS: Add IPv6 support to userspace interface.
Date: Thu, 12 Jun 2008 11:46:43 +0200
Message-ID: <f4845fc0806120246w394b23a9t865a060d639bcfed@mail.gmail.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com>
	 <1213204329-10973-25-git-send-email-juliusv@google.com>
	 <48508214.6080306@hp.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213264005; bh=2YVBod4SjtJ/tzlaqIh/Y6JBHVM=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=DMWD7N72tmmCJUxtbuhaviOMxpbu9/1R
	FsEkQZuP7n+ITmG/REJl01pHFbzNCmPTgX4jr5pT5o0sogLWRqIDUQ==
In-Reply-To: <48508214.6080306@hp.com>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Brian Haley <brian.haley@hp.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org

On Thu, Jun 12, 2008 at 3:55 AM, Brian Haley <brian.haley@hp.com> wrote:
> Julius R. Volz wrote:
>>
>> +#ifdef CONFIG_IP_VS_IPV6
>> +               struct in6_addr zero_addr = { .s6_addr32 = {0, 0, 0, 0} };
>> +               if (usvc->af == AF_INET6 && !usvc->fwmark &&
>> +                   ipv6_addr_equal(&usvc->addr.v6,&zero_addr) &&
>> !usvc->port) {
>> +                       ret = ip_vs_zero_all();
>> +                       goto out_unlock;
>> +               }
>
> You can change this ipv6_addr_equal() to ipv6_addr_any(&usvc->addr.v6) and
> get rid of the zero_addr variable mess.

Thanks, will do that!

Julius

-- 
Google Switzerland GmbH
