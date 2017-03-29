From: SIMRAN SINGHAL <singhalsimran0@gmail.com>
Subject: Re: [PATCH v2] netfilter: Clean up tests if NULL returned on failure
Date: Wed, 29 Mar 2017 14:45:57 +0530
Message-ID: <CALrZqyOMPfvt1OyH_LrNwj-a316gt=ZU2O0h+s+_NWH49dj_sw@mail.gmail.com>
References: <20170328131340.GA19688@singhal-Inspiron-5558> <alpine.LSU.2.20.1703281552040.21255@n3.vanv.qr>
 <CALrZqyPeR6X1RrqOsGfLbbZ2rPQgOf=50Rs+ot0kxkkA464V5w@mail.gmail.com>
 <alpine.LSU.2.20.1703290854390.26906@n3.vanv.qr> <CALrZqyN2Vh0J219tY_zj5u-4bUVmD+T=q6yMH9WZN2Y3O7yzpA@mail.gmail.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:in-reply-to:references:from:date:message-id:subject:to
         :cc;
        bh=g6jVn5iLNSsx+gHQ2q4kNLfWDJrrzOdsIcMNFlppsEE=;
        b=eBQlncCyoIZrBoYzWNHm2sCxUhBDsT7ocFsvCuAlSBm2P/wbR4BldFBdqT7JS/npMo
         csRf+856yW3/1jw+lbLKJ4HhiaLvQgD0ikAh/unEgZ1F8Qr1yzc2iYk0hkTnvt+s+s2Q
         d2ihYXIwMPOXQZ4kMJt/OC/epzbUDZ0pV2sG+e6abcY4J+2ywxOa7Kdwi/nVQ0vI+9G0
         hYQIdPPA8MUt+hmlxqkKQkDK8Bxli/FWEEOP/sZajm/FBmIo76oaDGHC1jhvEzQ2sMzM
         f57htP1nKUhsDHgJMOtdWz68hNPKU+xaC3mWW8gVOGRznvWfA444MBjtf3bESPdBklHl
         gFjA==
In-Reply-To: <CALrZqyN2Vh0J219tY_zj5u-4bUVmD+T=q6yMH9WZN2Y3O7yzpA@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jan Engelhardt <jengelh@inai.de>
Cc: wensong@linux-vs.org, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org, outreachy-kernel <outreachy-kernel@googlegroups.com>

On Wed, Mar 29, 2017 at 2:19 PM, SIMRAN SINGHAL
<singhalsimran0@gmail.com> wrote:
> On Wed, Mar 29, 2017 at 12:25 PM, Jan Engelhardt <jengelh@inai.de> wrote:
>>
>> On Tuesday 2017-03-28 18:23, SIMRAN SINGHAL wrote:
>>>On Tue, Mar 28, 2017 at 7:24 PM, Jan Engelhardt <jengelh@inai.de> wrote:
>>>> On Tuesday 2017-03-28 15:13, simran singhal wrote:
>>>>
>>>>>Some functions like kmalloc/kzalloc return NULL on failure. When NULL
>>>>>represents failure, !x is commonly used.
>>>>>
>>>>>@@ -910,7 +910,7 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
>>>>>       }
>>>>>
>>>>>       dest = kzalloc(sizeof(struct ip_vs_dest), GFP_KERNEL);
>>>>>-      if (dest == NULL)
>>>>>+      if (!dest)
>>>>>               return -ENOMEM;
>>>>
>>>> This kind of transformation however is not cleanup anymore, it's really
>>>> bikeshedding and should be avoided. There are pro and cons for both
>>>> variants, and there is not really an overwhelming number of arguments
>>>> for either variant to justify the change.
>>>
>>>Sorry, but I didn't get what you are trying to convey. And particularly pros and
>>>cons of both variants.
>>
>> The ==NULL/!=NULL part sort of ensures that the left side is a pointer, which
>> is lost when just using the variable and have it implicitly convert to bool.
>
> Thanks for the explaination!!!!
>
> But, according to me we should prefer != NULL over ==NULL according to
> coding style.

Sorry their is typing mistake in above.

But, according to me we should prefer !var over ( var ==NULL ) according to the
coding style
