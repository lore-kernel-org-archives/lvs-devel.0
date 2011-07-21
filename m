From: Huajun Li <huajun.li.lee@gmail.com>
Subject: Re: ipvs oops in 3.0-rc7
Date: Thu, 21 Jul 2011 21:37:29 +0800
Message-ID: <CA+v9cxbhpt3LSZ_m+OA_Kujt79mvDZ7VnGqjbbPQxS_gY6+pTA@mail.gmail.com>
References: <20110720205019.9dfa30c3.rdunlap@xenotime.net>
	<alpine.LFD.2.00.1107211202380.1660@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=mime-version:in-reply-to:references:date:message-id:subject:from:to
         :cc:content-type:content-transfer-encoding;
        bh=9QBpYUx0GzQwdhOKaSSUMkwQf6Bv2KpO7ug1U/7be4M=;
        b=ZHTByN3glnWqeMzkPb/S1pY1QDBs7Id35ONyfNLzuqTjY29vXGK9vZyWVE0ziKZxvD
         HnDkynUOB58csd8jXB7kusSb8Tk0eBgNdf8YRH/ehSlngIm73Bkd9Wn2fpVgXJorzGtJ
         q2YmgLBhTQKF+djneGWTM+eckmu9TWBGXeGp0=
In-Reply-To: <alpine.LFD.2.00.1107211202380.1660@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Julian Anastasov <ja@ssi.bg>
Cc: Randy Dunlap <rdunlap@xenotime.net>, netdev <netdev@vger.kernel.org>, lvs-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>

2011/7/21 Julian Anastasov <ja@ssi.bg>:
>
> =A0 =A0 =A0 =A0Hello,
>
> On Wed, 20 Jul 2011, Randy Dunlap wrote:
>
>> I'm seeing the following Oops in 3.0-rc7 on x86_64, just loading and=
 unloading
>> modules. =A0Any chance this is already fixed? =A0I can test current =
git, but I
>> wanted to ask first.
>>
>> Looks like it is on the second module load of ip_vs (i.e.,
>> modprobe ip_vs; rmmod ip_vs; modprobe ip_vs).
>
> =A0 =A0 =A0 =A0I think, this problem was fixed by this patch:
>
> http://www.spinics.net/lists/lvs-devel/msg02051.html
>
> =A0 =A0 =A0 =A0But it seems it was lost somewhere ...
>

That's great, SB. can help to apply it again, thanks.
