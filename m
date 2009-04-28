From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ldirectord: Allow sending email via external SMTP
	server
Date: Wed, 29 Apr 2009 01:11:20 +1000
Message-ID: <20090428151120.GB8377@verge.net.au>
References: <33afbbe70904271254j17e1896fqdb51e88ebd71b2b7@mail.gmail.com> <20090428062636.GB19369@verge.net.au> <33afbbe70904280647x33fafef1w258303ebe4eec313@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <33afbbe70904280647x33fafef1w258303ebe4eec313@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Caleb Anthony <caleb.anthony@gmail.com>
Cc: lvs-devel@vger.kernel.org

On Tue, Apr 28, 2009 at 07:47:07AM -0600, Caleb Anthony wrote:
> >From what I understand about Mail::Mailer (maybe incorrectly!), in
> order to use the SMTP functionality, you have to be running an SMTP
> server on the same server as ldirectord. That isn't an option in our
> organization, so I had to add the ability to use an external SMTP
> server.
> 
> Am I wrong about Mail::Mailer? Can it use an SMTP server other than
> one on the server that ldirectord is also running on?

Sorry, I was a bit confused.

I think that Mail::Mailer can probably do what you are after,
but the current ldirectord code uses Mail::Send, which does
not apper to be able to access an SMTP server.

With regards to the patch, I think that it might be nice
to arrance things such that there are two functions,
one whcih contains the existing Mail::Send code, including
the call to "use Mail::Send;". One that includes your new code,
including any calls to use or require. And have ld_emailalert_send()
call one of these functions depending on if $SMTP is set or not.

-- 
Simon Horman
  VA Linux Systems Japan K.K. Satellite Lab in Sydney, Australia
  H: www.vergenet.net/~horms/            W: www.valinux.co.jp/en

