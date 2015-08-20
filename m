From: Alex Gartrell <alexgartrell@gmail.com>
Subject: Re: [PATCH net-next 00/12] ipvs: Add icmp scheduling
Date: Thu, 20 Aug 2015 00:31:58 -0700
Message-ID: <CALCkm3fD9EEo2a8-6V_zu3ct=SOzt+CqXaTOu3pbRDJ4pNRDHQ@mail.gmail.com>
References: <1439412430-1702375-1-git-send-email-agartrell@fb.com> <CAJ26g5Q1kMERB0frOLKz51=8Bvji=q9yvrLdfFyjMeadNrUOUw@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:in-reply-to:references:from:date:message-id:subject:to
         :cc:content-type;
        bh=iVWQAq41GtZBcp7t2MDZ0e2QXIt9a5i10E4m79Te6BE=;
        b=uikj7C51Ndj15xQy2eQrh7zVYUoyDGX5UpfcqcwW7+siD/7+DQHW92K+Am/Q1psXrX
         HfDgy7hFL0xfPQKpjP/NYja+AHSLp2ybVWAgxWNPvD6/WedBloJtXeKGj13zbXNJAbbu
         Ff7nn6LPAZP9qAj1akZQnEvpF0pQ6X/F1QCmpkmfYdeZwW23KgzhFiuBreDxD66BAKDE
         CxZruDctAnYj0Yh3ntjKoAoGzndwI4YidI8YqgDBPdudpY08pBD2bTkRACJWxkN8gIAE
         +hLOBDBoJrYV/PVxTXjgDnDZeMYU6qx3VkA/cLg3yyJ2Lh/orbGfNsOjBDR+mfTCzS6h
         e8SQ==
In-Reply-To: <CAJ26g5Q1kMERB0frOLKz51=8Bvji=q9yvrLdfFyjMeadNrUOUw@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick Schaaf <netdev@bof.de>
Cc: Alex Gartrell <agartrell@fb.com>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, kernel-team <kernel-team@fb.com>, lvs-devel@vger.kernel.org

On Wed, Aug 19, 2015 at 11:09 PM, Patrick Schaaf <netdev@bof.de> wrote:
> Am 12.08.2015 22:47 schrieb "Alex Gartrell" <agartrell@fb.com>:
> Sounds like a missing feature in whatever does that ECMP thing, not being
> able to recognize ICMP / look at the ICMP inner L3/L4 addresses to drive the
> hashing. If you could get that to change, no partially-working (needing
> static schedule) IPVS hack would be neccessary, right?

If we were able to get the router to do the right thing, it would
definitely deal with the steady state case.  There are still two
problems though:
1) Doing this in the routers (in hardware) is /really/ hard.  Your
ASIC has to be able to descend into the icmp payload, which is
non-trivial.  For an example of where this routinely fails, simply
look at how routers and NICs handle ipv6 extension headers -- the
major NIC vendors simply give up immediately and omit the ports from
the hash.
2) It doesn't address the situation in which you want to swap or
restart and IPVS instance (as for sloppy TCP).  This will happen if
you add or remove next-hops via BGP or if you simply swap one.

tl;dr; it's too hard to change routers and, even if we did, it doesn't
address the "sloppy" scheduling case.

-- 
Alex Gartrell <agartrell@fb.com>
