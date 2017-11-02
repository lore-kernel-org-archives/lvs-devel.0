From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH] netfilter: ipvs: Convert timers to use timer_setup()
Date: Thu, 2 Nov 2017 15:11:54 -0700
Message-ID: <CAGXu5jKi-yKO+QuvJ7kTJreZpvh_-Ozmbjr0e-HiXRXueT-RSg@mail.gmail.com>
References: <20171024084521.GA23684@beast> <alpine.LFD.2.20.1710242203100.2078@ja.home.ssi.bg>
 <20171102144247.yz2yupsj4cjctvio@verge.net.au>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:sender:in-reply-to:references:from:date:message-id
         :subject:to:cc;
        bh=U9h35mfZ/+njkaBbGJbtR1djxs5XsNQ4M3afktMmJgE=;
        b=WfM+4uYurR1GoDzS1kvl2DzIo22T1Z8M17+2wk5XqhLWL1XKzedkpayOrMDDxNC0X6
         6wfOZbbPeMzvwLypbwKF/50jyG+HaAnqKfbbg8noLG9G4RTOq98uBKuwDjHH0ENVMTQr
         4lDqU6v5pgxonTDWjVvC3o4PhuYQjG8SMVByCN0o9QG7ncRYjiBD9smKZdXOIVe1Go79
         0l5VzKyc30mh7MNV3DbPkrosLOnuU0GbZSXzC9+Yv4zwOsPcjQKJti3KZn7gq8UrTGKP
         XWASiEZU5P6Su07otj1mT54p7hdVytCgVtOHYsNXSE7/CDGcsiwL0f2RwRVTcrgUgYYC
         MEPQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:sender:in-reply-to:references:from:date:message-id
         :subject:to:cc;
        bh=U9h35mfZ/+njkaBbGJbtR1djxs5XsNQ4M3afktMmJgE=;
        b=NcH2g3/acxx+0vIB3a1+8PFh9yWDoefhaXM0f0AZMkZVo24vbNncuECiKFdFqYL5yW
         rTYI9hXMrkZmMFJUFfA/IhpvQkUnFoRukjQ6Qp531BCLurRRqPyRDM1w4mutd852bkMk
         fjHXglIZRJqOPyRtURxb2qLFLnA939hNnpx3Y=
In-Reply-To: <20171102144247.yz2yupsj4cjctvio@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>, "David S. Miller" <davem@davemloft.net>, Wensong Zhang <wensong@linux-vs.org>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, Network Development <netdev@vger.kernel.org>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>

On Thu, Nov 2, 2017 at 7:42 AM, Simon Horman <horms@verge.net.au> wrote:
> On Tue, Oct 24, 2017 at 10:07:03PM +0300, Julian Anastasov wrote:
>>
>>       Hello,
>>
>> On Tue, 24 Oct 2017, Kees Cook wrote:
>>
>> > In preparation for unconditionally passing the struct timer_list pointer to
>> > all timer callbacks, switch to using the new timer_setup() and from_timer()
>> > to pass the timer pointer explicitly.
>> >
>> > Cc: Wensong Zhang <wensong@linux-vs.org>
>> > Cc: Simon Horman <horms@verge.net.au>
>> > Cc: Julian Anastasov <ja@ssi.bg>
>> > Cc: Pablo Neira Ayuso <pablo@netfilter.org>
>> > Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
>> > Cc: Florian Westphal <fw@strlen.de>
>> > Cc: "David S. Miller" <davem@davemloft.net>
>> > Cc: netdev@vger.kernel.org
>> > Cc: lvs-devel@vger.kernel.org
>> > Cc: netfilter-devel@vger.kernel.org
>> > Cc: coreteam@netfilter.org
>> > Signed-off-by: Kees Cook <keescook@chromium.org>
>>
>>       Looks good to me,
>>
>> Acked-by: Julian Anastasov <ja@ssi.bg>
>
> Signed-off-by: Simon Horman <horms@verge.net.au>
>
> Pablo, could you take this?

If it's helpful, we could take this via the timers tree. Either way. :) Thanks!

-Kees

-- 
Kees Cook
Pixel Security
