Received: from out30-111.freemail.mail.aliyun.com (out30-111.freemail.mail.aliyun.com [115.124.30.111])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5E1E9653;
	Wed,  6 Nov 2024 10:01:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=115.124.30.111
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1730887297; cv=none; b=R/Ji8f9FE9TSl6jeGpdJo22RGbKv86jxPAsJroJYlveeRa1mtQ4b06hzbptabOV6KRf6yULHYN3RIwV9bi/GUrHh2ljlnv6dAj2sSlkXHWnMNGeahI+8k1Qdgi5RPZ4y7kc9odg+PTszaML+oIbEf/Shu9KZHg7pLT33se4SWIA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1730887297; c=relaxed/simple;
	bh=5H4p85iBCVpCJqUU/+0E8vRTCYLytXTgiQ/HjbhbJuo=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=OnoB2CL7XhLs9EN5WzXL7NmfhBepF3vznFfWm05Fqd4e147BsXbvYiGizQ8gjm6lCHX0cN7Ir6ncLtS+KbgmM65mkqYx59DeVpOaXFip7WHtEGzCQJJ+J/vf4FuYpxciIN0HipcO4k0CAQsEPkl2A6agSm4lQWj48+d3UscfI1A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com; spf=pass smtp.mailfrom=linux.alibaba.com; dkim=pass (1024-bit key) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.b=kvy+j8WI; arc=none smtp.client-ip=115.124.30.111
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.b="kvy+j8WI"
DKIM-Signature:v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=linux.alibaba.com; s=default;
	t=1730887291; h=Message-ID:Date:MIME-Version:Subject:To:From:Content-Type;
	bh=gAEn9thfzLRy42eN3/oD6NOZqicEf53zaj+UIUQCNdQ=;
	b=kvy+j8WIfJJJDrynNtWY2DrUllAaAwA5VSw028x/+FTMOjM+AlJ7mCbrPJ9P+AMjTrY8sQ5X9o8IriXrDr1uEHYtjrQhupVID/GdDLgBO0ZF49YeECRPL8xfh7TZ57FUWybaYNShFcyhIzX7A2uk88N3uGu4f1Ui/q62v7va7GU=
Received: from 30.221.147.151(mailfrom:alibuda@linux.alibaba.com fp:SMTPD_---0WIqqUbo_1730887288 cluster:ay36)
          by smtp.aliyun-inc.com;
          Wed, 06 Nov 2024 18:01:29 +0800
Message-ID: <c9a1c5c5-58dc-48d0-9693-0ae4ac347b97@linux.alibaba.com>
Date: Wed, 6 Nov 2024 18:01:28 +0800
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [syzbot] [lvs?] possible deadlock in start_sync_thread
To: Pablo Neira Ayuso <pablo@netfilter.org>,
 Wenjia Zhang <wenjia@linux.ibm.com>, Jan Karcher <jaka@linux.ibm.com>,
 Tony Lu <tonylu@linux.alibaba.com>, Wen Gu <guwen@linux.alibaba.com>,
 linux-s390@vger.kernel.org
Cc: syzbot <syzbot+e929093395ec65f969c7@syzkaller.appspotmail.com>,
 coreteam@netfilter.org, davem@davemloft.net, edumazet@google.com,
 horms@verge.net.au, ja@ssi.bg, kadlec@netfilter.org, kuba@kernel.org,
 linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org,
 netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, pabeni@redhat.com,
 syzkaller-bugs@googlegroups.com
References: <000000000000abf2f0061ba46a1a@google.com>
 <6725704b.050a0220.35b515.0180.GAE@google.com> <ZyoAjPBjtQA6jE-8@calendula>
Content-Language: en-US
From: "D. Wythe" <alibuda@linux.alibaba.com>
In-Reply-To: <ZyoAjPBjtQA6jE-8@calendula>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 11/5/24 7:25 PM, Pablo Neira Ayuso wrote:
> Hi,
> 
> I am Cc'ing SHARED MEMORY COMMUNICATIONS (SMC) SOCKETS maintainers.
> 
> Similar issue already reported by syzkaller here:
> 
> https://lore.kernel.org/netdev/ZyIgRmJUbnZpzXNV@calendula/T/#mf1f03a65108226102d8567c9fb6bab98c072444c
> 
> related to smc->clcsock_release_lock.
> 
> I think this is a false possible lockdep considers smc->clcsock_release_lock
> is a lock of the same class sk_lock-AF_INET.
> 
> Could you please advise?
> 
> Thanks.

Hi Pablo,

Thank you for the reminder. We are currently working on it. The community has already submitted some 
fixes[1], and we are still reviewing them.


Best wishes,
D. Wythe


[1] 
https://lore.kernel.org/netdev/c2ac8e30806af319eb96f67103196b7cda22d562.1729031472.git.danielyangkang@gmail.com/



