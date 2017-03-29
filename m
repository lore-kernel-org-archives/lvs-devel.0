From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH v2] netfilter: Clean up tests if NULL returned on
 failure
Date: Wed, 29 Mar 2017 08:55:15 +0200 (CEST)
Message-ID: <alpine.LSU.2.20.1703290854390.26906@n3.vanv.qr>
References: <20170328131340.GA19688@singhal-Inspiron-5558> <alpine.LSU.2.20.1703281552040.21255@n3.vanv.qr> <CALrZqyPeR6X1RrqOsGfLbbZ2rPQgOf=50Rs+ot0kxkkA464V5w@mail.gmail.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <CALrZqyPeR6X1RrqOsGfLbbZ2rPQgOf=50Rs+ot0kxkkA464V5w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: SIMRAN SINGHAL <singhalsimran0@gmail.com>
Cc: wensong@linux-vs.org, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org, outreachy-kernel <outreachy-kernel@googlegroups.com>


On Tuesday 2017-03-28 18:23, SIMRAN SINGHAL wrote:
>On Tue, Mar 28, 2017 at 7:24 PM, Jan Engelhardt <jengelh@inai.de> wrote:
>> On Tuesday 2017-03-28 15:13, simran singhal wrote:
>>
>>>Some functions like kmalloc/kzalloc return NULL on failure. When NULL
>>>represents failure, !x is commonly used.
>>>
>>>@@ -910,7 +910,7 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
>>>       }
>>>
>>>       dest = kzalloc(sizeof(struct ip_vs_dest), GFP_KERNEL);
>>>-      if (dest == NULL)
>>>+      if (!dest)
>>>               return -ENOMEM;
>>
>> This kind of transformation however is not cleanup anymore, it's really
>> bikeshedding and should be avoided. There are pro and cons for both
>> variants, and there is not really an overwhelming number of arguments
>> for either variant to justify the change.
>
>Sorry, but I didn't get what you are trying to convey. And particularly pros and
>cons of both variants.

The ==NULL/!=NULL part sort of ensures that the left side is a pointer, which
is lost when just using the variable and have it implicitly convert to bool.
