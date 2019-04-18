From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipvs:set sock send/receive buffer correctly
Date: Wed, 17 Apr 2019 19:02:11 -0700
Message-ID: <a8ed41f3-1576-cbf6-907a-f501b3df189e@gmail.com>
References: <501e5522-1d69-7c67-a1bc-fd8502d3b5d1@huawei.com>
 <60c11e72-99eb-fcde-e130-a35ecdc1d2d1@gmail.com>
 <bbfcccf4-626b-1029-62a6-a82b79edacbb@huawei.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=s6InVlmwhf7nDs3US5FW36FMkwSol+9ahSHqxp3m2yw=;
        b=Z9I6BAymfGIMLS9r5mmp2sPOZsCGuZ+ND3z+VHRi98g3k3Lv8UtPuDqVwdMMMJPQoh
         RQkO8hd+afXPWlK1RFtuSTNGEpZL09zqMnFkHfuGuS8xGKPLzmuAqyF4dKjhSY+A2DOo
         i+B6vke8Mn66KdVOC1SFsgFV5Ul5TImSKnUIteE3d2bm0iboEsdoI5qUBsxUspo1dSEz
         Vehxd/tiPJwSmivjpheCMwpARar9uHm0kNhRgrGJYZ9wKvDXz0tTjeKdo7iqiR3wBoDv
         +0npKuOeH0oix3TWQnfqHUkgtuebPWga/3X+S6xPoPGYaXJkfjodLLylYnZl1JNKxvtd
         +MAA==
In-Reply-To: <bbfcccf4-626b-1029-62a6-a82b79edacbb@huawei.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: linmiaohe <linmiaohe@huawei.com>, Eric Dumazet <eric.dumazet@gmail.com>, wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, kadlec@blackhole.kfki.hu, fw@strlen.de, davem@davemloft.net, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org
Cc: Mingfangsen <mingfangsen@huawei.com>, liujie165@huawei.com



On 04/17/2019 06:45 PM, linmiaohe wrote:
> 

> In fact, I just implemented this function with reference to
> sock_setsockopt(). When val * 2 overflow, we will set the
> buffer as SOCK_MIN_SNDBUF, just as sock_setsockopt() do.
> 

I do not think so.

Please check latest linux kernel, not some old version.

commit 4057765f2dee79cb92f9067909477303360be8d3    sock: consistent handling of extreme SO_SNDBUF/SO_RCVBUF values
