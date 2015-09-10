From: Alex Gartrell <alexgartrell@gmail.com>
Subject: Re: [PATCH ipvs-next] ipvs: add sysctl to ignore tunneled packets
Date: Thu, 10 Sep 2015 12:57:20 -0700
Message-ID: <CALCkm3e3zLsHVd8hE8Wb1nzt=+-M0MSiro7akstpLy8BREzNrg@mail.gmail.com>
References: <1441907665-1703876-1-git-send-email-agartrell@fb.com> <alpine.LFD.2.11.1509102128220.1751@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:in-reply-to:references:from:date:message-id:subject:to
         :cc:content-type;
        bh=NhkSRvGuPnw2XmFRBov3bFhcMpJmqym1TmK6LqDpFIc=;
        b=EpWGbjLIWi5Mh1B+QIw3qW3Vxzww73qGdzruzBpNk/AHkWyfXc5YwpPp5/tZzWEw1L
         OyppjBEpCA3GM0CmyUPfwm4Z12JvB0W3c6wTFe8jpKbhooADHhM6tTbtIhubdebRyj6Z
         BTnOFqJ7lDZpewAN7XxZBInZCdEMGXXnFQ+r9VHQ4cdRHBXKP9ST3E7uEM+X2m5eZZG6
         1m5K8Q6R5Ipi1q87sqXWd9+JJEmfFstqaRnuKf8B8GRKWXrc1Q8Vz7JnD09Kizci9uVE
         Zq5Iw4TVr/XGW0oOV7Na68SCezlntT5gFeC+gpJyVFqBU1gsUmxpZ6uep1T4MyhHjLVO
         Yf9Q==
In-Reply-To: <alpine.LFD.2.11.1509102128220.1751@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Alex Gartrell <agartrell@fb.com>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, kernel-team <kernel-team@fb.com>

On Thu, Sep 10, 2015 at 11:30 AM, Julian Anastasov <ja@ssi.bg> wrote:
>         More details? Do we set the flag for IPIP packets
> and what happens otherwise?

This is for the situation where you are running ipvs on a server that
is also one of the real servers.  What will happen is that you get an
IPIP encapsulated packet sent to you from the other ipvs server,
decapsulate it, and it is caught by ipvs and then forwarded again.

This is always extra work, but in the worst case, you can end up
forwarding it back to the other ipvs server.  For us, this has caused
a lot of ping-ponging which burns up a CPU core.

-- 
Alex Gartrell <agartrell@fb.com>
