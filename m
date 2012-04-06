From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: [PATCH] netfilter: ipvs: Verify that IP_VS protocol has been registered
Date: Fri, 6 Apr 2012 11:07:21 +0200
Message-ID: <CA+1xoqcS2+F+Nz_akXNQ7k+nuHkJjXYG6d=faMZ6xx1CW=RtPA@mail.gmail.com>
References: <1333668273-8873-1-git-send-email-levinsasha928@gmail.com> <20120405231942.GB7715@verge.net.au>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:in-reply-to:references:from:date:message-id:subject:to
         :cc:content-type;
        bh=smzpJh+MHcjCqtDhJbtqEviJnTCRVoRKjJNhB+HzMiY=;
        b=a4tY105Pb2BsgNzOTbM/+xjtxpgMupnV1+4ed0tumngwd5znZRGVH8D4VcHvaGZ4zY
         R0uWrUkRKGzgKdTBGA4YwHKavU2GCxAX2qgG2y3IeqqWTLDsCWe9FHMB7UdoAmGze8jv
         E0979vAT1mAkVxSHuMQZAii9RaOwuVE7yMF/4BzHNJZFWSl8lgsF5a5ahTuzyeRV1SI1
         RBhr+c1+bkrSX7zoniB6T6KSsIegeUAwpC5HJsGCFIOhhTkqYOUx6dnYa93CVIVJh5lv
         9rkJ4DYj+M550OYIuluE7sAPiLVi1Af7KeFEsVcuYD4YCnvqXVdzrTxVX3pxX+bFqa+o
         IxuQ==
In-Reply-To: <20120405231942.GB7715@verge.net.au>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: wensong@linux-vs.org, ja@ssi.bg, kaber@trash.net, davem@davemloft.net, davej@redhat.com, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Apr 6, 2012 at 1:19 AM, Simon Horman <horms@verge.net.au> wrote:
> On Thu, Apr 05, 2012 at 07:24:33PM -0400, Sasha Levin wrote:
>> The registration of a protocol might fail, there were no checks
>> and all registrations were assumed to be correct. This lead to
>> NULL ptr dereferences when apps tried registering.
>
> Thanks, I will queue up this fix.
>
> Do you have a real-world example of this failing, if so it
> might be worth pushing your change into stable.

The scenario is a failed allocation in register_ip_vs_proto_netns(),
which can happen in real world cases as well.
