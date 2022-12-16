From: "Arnd Bergmann" <arnd@arndb.de>
Subject: Re: [PATCH] ipvs: use div_s64 for signed division
Date: Fri, 16 Dec 2022 12:24:15 +0100
Message-ID: <e17c7340-8973-417a-a334-01e96e5bbe73@app.fastmail.com>
References: <20221215170324.2579685-1-arnd@kernel.org>
 <e1fea67-7425-f13d-e5bd-3d80d9a8afb8@ssi.bg> <Y5xEITNJkry8uy/h@salvia>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=arndb.de; h=cc
        :cc:content-type:date:date:from:from:in-reply-to:in-reply-to
        :message-id:mime-version:references:reply-to:sender:subject
        :subject:to:to; s=fm1; t=1671189877; x=1671276277; bh=64TMHd9mCM
        xlohGzvyOHHYDGzPMMW5ePInqTBtIjYdk=; b=VsF9DdcyJT9XCBQ/qNusAupwue
        44Rl2EOQGWItRfsBUCTBoaHn4g8Ra1HFz88POOmJTsD7A/9wjDwYq4Y4aU+ptnCc
        XXmUUQC9sAXHCbiVE7/NX+YlxjSxnR3CMf1yWd/3iHQHCDUA+97d822o4WHYRScF
        HxIRNc8JN4rbRymDbV7uJeEauYXXMm79JNB692DPPC46jWi2iCyg0EgmfG8Pxno/
        CYj7SH0CLMmOegEKnaECCtgc2NS4sy15JGqF5gtbM/RGMUBKsURT5nY7xpLvZ7Oq
        joxe8Rvdb5gyVdQkNJnNEoe0J2ptnN9Vy34eGuvgrPMzdobfAvKK19oYn0Rw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
        messagingengine.com; h=cc:cc:content-type:date:date:feedback-id
        :feedback-id:from:from:in-reply-to:in-reply-to:message-id
        :mime-version:references:reply-to:sender:subject:subject:to:to
        :x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
        fm2; t=1671189877; x=1671276277; bh=64TMHd9mCMxlohGzvyOHHYDGzPMM
        W5ePInqTBtIjYdk=; b=K70/qCvoSdbAWKVRz2ukFfBC92/UqdnvlOLb3gMasrh+
        METHyE9dna6KBwcNfF55fEHALvWHR9sejwulAGXfm1r+wwKRs20DstEf8wXVEhPa
        IB5e6FBOiSue95W2sCNBCUJna5g2kp+ON+Q1N1NlFPgEyCWw6Y3HUPZpehKzB5ft
        aJhmNJmFvKoLJkY2rmRdljp7SxNFkfIBWWPVwCAXNlzBwHmtkcLPocRmjA5gZ+rM
        olF1Uu7vm2dSZOoUSqTO2uTMKywN4K9KWJHohNpV6eajO0NcSOtiDwqi2eAe5dY1
        W3eSfP5myBzrQ2zL2KASNEUNzPH14UvlsGvVjgnEHQ==
In-Reply-To: <Y5xEITNJkry8uy/h@salvia>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, Julian Anastasov <ja@ssi.bg>
Cc: Arnd Bergmann <arnd@kernel.org>, Simon Horman <horms@verge.net.au>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, Jiri Wiesner <jwiesner@suse.de>, Netdev <netdev@vger.kernel.org>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel <linux-kernel@vger.kernel.org>

On Fri, Dec 16, 2022, at 11:10, Pablo Neira Ayuso wrote:
> Hi Julian,
>
> On Thu, Dec 15, 2022 at 09:01:59PM +0200, Julian Anastasov wrote:
>> 
>> 	Hello,
>> 
>> On Thu, 15 Dec 2022, Arnd Bergmann wrote:
>> 
>> > From: Arnd Bergmann <arnd@arndb.de>
>> > 
>> > do_div() is only well-behaved for positive numbers, and now warns
>> > when the first argument is a an s64:
>> > 
>> > net/netfilter/ipvs/ip_vs_est.c: In function 'ip_vs_est_calc_limits':
>> > include/asm-generic/div64.h:222:35: error: comparison of distinct pointer types lacks a cast [-Werror]
>> >   222 |         (void)(((typeof((n)) *)0) == ((uint64_t *)0));  \
>> >       |                                   ^~
>> > net/netfilter/ipvs/ip_vs_est.c:694:17: note: in expansion of macro 'do_div'
>> >   694 |                 do_div(val, loops);
>> 
>> 	net-next already contains fix for this warning
>> and changes val to u64.
>
> Arnd's patch applies fine on top of net-next, maybe he is addressing
> something else?

No, it's the same bug. I had prepared my patch before the other fix
went in, and only one of the two is needed.

FWIW, I find my version slightly more readable, but Jakub's fix
is probably more efficient, because the unsigned 64-bit division
is better optimized on 32-bit, while div_s64() goes through an
extern function.

     Arnd
