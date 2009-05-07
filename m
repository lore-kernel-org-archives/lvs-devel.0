From: Caleb Anthony <caleb.anthony@gmail.com>
Subject: Re: Ldirectord Feature Request
Date: Thu, 7 May 2009 10:08:52 -0600
Message-ID: <33afbbe70905070908xf712994j31973ca80b02e3f8@mail.gmail.com>
References: <33afbbe70905011318j35d226a6h31e0dfaeb1b77b45@mail.gmail.com>
	 <20090502021644.GA15603@verge.net.au>
	 <Pine.LNX.4.64.0905020531001.18799@wm7d.net>
	 <20090505124520.GA19402@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:mime-version:received:in-reply-to:references
         :date:message-id:subject:from:to:cc:content-type
         :content-transfer-encoding;
        bh=NP9gmr+KvbzDJT5MD8XkwznWFtH7LkYBs8Ph0X2aei0=;
        b=NMFqavyIaCCcG8fso521a7SjwPPNvGvH8l3TFc0kaB5nSX0+wrLjIrpD0Km0Dhz7lH
         pytj7g3f8KLbOV8ZzyKW3YWMviOpxAZYTabwr9HjwiGixtzBGsfmv39Fz0v49pmaSUrP
         6eKq66J7MdrFK5Gh6ZWL9ybR+sJ+vldEalzJc=
In-Reply-To: <20090505124520.GA19402@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Simon Horman <horms@verge.net.au>
Cc: Joseph Mack NA3T <jmack@wm7d.net>, lvs-devel@vger.kernel.org

I just ran a test (on kernel 2.6.27-7) and Simon is right, weight does
not equal the number of connections with the source hash scheduler.
Looks like the documentation needs to be updated.

Thanks for pointing this out.

Since ldirectord doesn't need to be changed in regards to the weight
setting for a fallback server for my situation, I'll take a stab at
adding the functionality to specify multiple fallback servers in
ldirectord.cf. It seems like it should be a simple enough addition.

Thanks again.

On Tue, May 5, 2009 at 6:45 AM, Simon Horman <horms@verge.net.au> wrote=
:
> Hi Joe,
>
> On Sat, May 02, 2009 at 05:33:43AM -0700, Joseph Mack NA3T wrote:
>>
>> On Sat, 2 May 2009, Simon Horman wrote:
>>
>>> I'll double check, but I think the weight specifies a proportion
>>> of conections rather than an absolute number. Could you let
>>> me know which documentation you are looking at?
>>
>> it's the number of connections
>>
>> see section 4.10.2 of
>>
>> http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.ipvsadm.html#=
SH-scheduler
>
> That may have been the case in the past, but examining the code now
> I don't see any evidence of weight =3D number of connections for the =
purpose
> of calculating overload.
>
> As far as I can see a real-server is only regarded as
> being overloaded if the IP_VS_DEST_F_OVERLOAD flag is set.
> And that flag only seems to be set in ip_vs_bind_dest()
> where the criteria is that u-threshhold - as supplied
> by ipvsadm - has been exceeded.
>
> Specifically, I am looking at ip_vs_sh_schedule(), ip_vs_sh_get()
> and is_overloaded() in net/netfilter/ipvs/ip_vs_sh.c in 2.6.30-rc4.
>
> Caleb, are you observing that weight =3D number of connections?
> If so, which kernel are you running?
>
>> no-one used the -SH scheduler for years because no-one understood ho=
w to
>> use it. I expect that weighting by the number of connections was pro=
bably
>> the easiest to code up, but it's not particularly useful
>
> I agree with your comments regarding utility.
> If it is the case then I think it should be changed.
>
> --
> Simon Horman
> =A0VA Linux Systems Japan K.K. Satellite Lab in Sydney, Australia
> =A0H: www.vergenet.net/~horms/ =A0 =A0 =A0 =A0 =A0 =A0W: www.valinux.=
co.jp/en
>
>
