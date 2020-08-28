From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] Remove ipvs v6 dependency on iptables
Date: Fri, 28 Aug 2020 17:08:20 +0200
Message-ID: <e4765a73-e6a1-f5ba-dd8b-7c1ee1e5883d@6wind.com>
References: <alpine.LFD.2.23.451.2008272357240.4567@ja.home.ssi.bg>
 <20200827220715.6508-1-iam@lach.pw>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=6wind.com; s=google;
        h=reply-to:subject:to:cc:references:from:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=ona2SramZlOzoBjP/aJ5NnGGdz2GwYgLuTlQT94U0hE=;
        b=CTzbyprJ6gg7Ng1f7JKIYOiw19rZ8MsC9LXJxlx1AUjvXqxdfbD7dUGt3IY+jvLe6/
         w7naHbgmd77NXUXb4Vfa+purkaMUDniQwUQXNIKfDhV81NR3364+sIm5RLgTZzLgWlwI
         ojDrAV+OcPffbUyPYUIK1Zxt3Ty08sUiirCXxPAWVdz6svj2Q5BkWrvd0qjcCbQ4MJvD
         k7b03bFx/7Ovmf+ESu1OU1HPF9nSDa6Uhlvw27gxmlGiFvyL1xZnSqDwcmzk9jAhbv0Q
         DI62eXPsDO1pV6eBdjcGLp23bZNQJbPK90UdQ/w7qiE5gWZ/0mxLikOR4vzljPUUaTy6
         kMDA==
In-Reply-To: <20200827220715.6508-1-iam@lach.pw>
Content-Language: en-US
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Lach <iam@lach.pw>, ja@ssi.bg
Cc: "David S. Miller" <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Jakub Kicinski <kuba@kernel.org>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org

Le 28/08/2020 à 00:07, Lach a écrit :
> This dependency was added in 63dca2c0b0e7a92cb39d1b1ecefa32ffda201975, because this commit had dependency on
> ipv6_find_hdr, which was located in iptables-specific code
> 
> But it is no longer required, because f8f626754ebeca613cf1af2e6f890cfde0e74d5b moved them to a more common location
> ---
Your 'Signed-off-by' is missing, the commit log lines are too long, a commit
should not be referenced like this.
Please run checkpatch on your submissions.


Regards,
Nicolas
