From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] IPVS: use pr_err and friends instead of
 IP_VS_ERR and friends
Date: Thu, 30 Jul 2009 14:29:06 -0700 (PDT)
Message-ID: <20090730.142906.266849967.davem@davemloft.net>
References: <20090728203414.7654.73236.stgit@jazzy.zrh.corp.google.com>
	<20090728203554.7654.29628.stgit@jazzy.zrh.corp.google.com>
	<1248814615.18284.22.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1248814615.18284.22.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: joe@perches.com
Cc: heder@google.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, jengelh@medozas.de

From: Joe Perches <joe@perches.com>
Date: Tue, 28 Jul 2009 13:56:55 -0700

> On Tue, 2009-07-28 at 22:35 +0200, Hannes Eder wrote:
>> Since pr_err and friends is used instead of printk there is not point
>> in keeping IP_VS_ERR and friends.
>> +			pr_err("Schedule: port zero only supported "
>> +			       "in persistent services, "
>> +			       "check your ipvs configuration\n");
> 
> You might consider ignoring the checkpatch 80 char limit here
> and consolidate the message into a single string.

I don't think this is such a big deal.

>> -		IP_VS_ERR("ip_vs_svc_unhash(): request for unhash flagged, "
>> -			  "called from %p\n", __builtin_return_address(0));
>> +		pr_err("ip_vs_svc_unhash(): request for unhash flagged, "
>> +		       "called from %p\n", __builtin_return_address(0));
> 
> Maybe use something like:
> 	"%s(): <foo> called from %pf",
> 	 __func__, __builtin_return_address(0)
> 

However I do agree that this change should be made.
