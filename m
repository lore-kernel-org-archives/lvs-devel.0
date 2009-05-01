From: Caleb Anthony <caleb.anthony@gmail.com>
Subject: Re: [PATCH] ldirectord: Allow sending email via external SMTP server
Date: Fri, 1 May 2009 13:42:06 -0600
Message-ID: <33afbbe70905011242m2423ff3eg4606d7d0ef287387@mail.gmail.com>
References: <33afbbe70904271254j17e1896fqdb51e88ebd71b2b7@mail.gmail.com>
	 <20090428062636.GB19369@verge.net.au>
	 <33afbbe70904280647x33fafef1w258303ebe4eec313@mail.gmail.com>
	 <20090428151120.GB8377@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:mime-version:received:in-reply-to:references
         :date:message-id:subject:from:to:cc:content-type
         :content-transfer-encoding;
        bh=klBqjjAUvTkzlhONSN7qA2d38sd4Mb+9k2zWlIPU52w=;
        b=UI+Np4J+ldy9ecHhk68wupZK3y7nMYaajEbbYh2kuWziQ5MrdKs7g7wpXPx7/eqV9+
         37wWm+pAjbyGomuAsdNArpx1soEKA3TH/H9LPmrqEe9ciTqgys9f3OEhOAmg8VYovAYQ
         qEJ7HzW7cwEApFu7JArLD8kXXxjvJ7ScmCItU=
In-Reply-To: <20090428151120.GB8377@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

I think that's a good idea, I'll see what I can do to get a patch that
adds that functionality.

On Tue, Apr 28, 2009 at 9:11 AM, Simon Horman <horms@verge.net.au> wrot=
e:
> On Tue, Apr 28, 2009 at 07:47:07AM -0600, Caleb Anthony wrote:
>> >From what I understand about Mail::Mailer (maybe incorrectly!), in
>> order to use the SMTP functionality, you have to be running an SMTP
>> server on the same server as ldirectord. That isn't an option in our
>> organization, so I had to add the ability to use an external SMTP
>> server.
>>
>> Am I wrong about Mail::Mailer? Can it use an SMTP server other than
>> one on the server that ldirectord is also running on?
>
> Sorry, I was a bit confused.
>
> I think that Mail::Mailer can probably do what you are after,
> but the current ldirectord code uses Mail::Send, which does
> not apper to be able to access an SMTP server.
>
> With regards to the patch, I think that it might be nice
> to arrance things such that there are two functions,
> one whcih contains the existing Mail::Send code, including
> the call to "use Mail::Send;". One that includes your new code,
> including any calls to use or require. And have ld_emailalert_send()
> call one of these functions depending on if $SMTP is set or not.
>
> --
> Simon Horman
> =A0VA Linux Systems Japan K.K. Satellite Lab in Sydney, Australia
> =A0H: www.vergenet.net/~horms/ =A0 =A0 =A0 =A0 =A0 =A0W: www.valinux.=
co.jp/en
>
>
