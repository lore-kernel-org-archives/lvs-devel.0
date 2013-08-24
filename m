From: Drunkard Zhang <gongfan193@gmail.com>
Subject: Re: ipvsadm: One-packet scheduling with UDP service is unstable
Date: Sat, 24 Aug 2013 22:15:16 +0800
Message-ID: <CAJiejCSeJGm8RB02S8ZGKNNtS=b1noo0ykrBFg84H+FDnhjdnw@mail.gmail.com>
References: <CAJiejCQPa7V703RwOeWPpbQMJQvfswRn+pvTKFmNdeU05RU3SQ@mail.gmail.com>
 <alpine.LFD.2.00.1308220925340.1727@ja.ssi.bg> <CAJiejCSdfBKC3c1dqya55R5T0VBCTm3qaM6nL-CY+H0o5hbwoA@mail.gmail.com>
 <alpine.LFD.2.00.1308221558160.2993@ja.ssi.bg> <CAJiejCT-WemVeAkWoDib2ZXHLRj=Lme3-Lk=prOOVKL=w3vA5A@mail.gmail.com>
 <alpine.LFD.2.00.1308231708450.1852@ja.ssi.bg> <CAJiejCRKMe=tHdre0DY5=B70FnLV29tvLimW7K____0VPcW=Xg@mail.gmail.com>
 <alpine.LFD.2.00.1308241543030.1976@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:in-reply-to:references:from:date:message-id:subject:to
         :cc:content-type;
        bh=mic3Ma2fXRhXkN9A+SH9V+7msOU7KrBSdYE24Ik6lF8=;
        b=nNWiCRa52szE+puF+RiqsVkfqCFK3ABaavVynZuZLT7qbtMGSuqDohhk6rJCanxQZN
         aMsOyossg6FpaLwtnGfrIVjreo2NS0tx9nOkU58UG7eHLz8xgokgccbCYjcMZfuVkmIt
         L2v2HWmKRYhmCecG9MWo/gsv5V5oxZ1r8tgh+aBzTc6S9S9tMRMPtF/IB26qoyRG9lem
         ai4ujUwhY/1WulcBWVBUeucMAifq08CRmzKhF6J9uyB4F2v7as1uifDQT2Wzg5bo27Y5
         dvCEPyp87EIoE1z1GO/O0aodsgBlXctjouyqlk57LrltNgI1GeTTSbNtc487hL+xFvTF
         Rssw==
In-Reply-To: <alpine.LFD.2.00.1308241543030.1976@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

>         May be we can enable debug for short time when
> OPS is not working:
>
> # Start debug for 10ms
> echo 20 > /proc/sys/net/ipv4/vs/debug_level
> usleep 10000
> # Stop debug
> echo 0 > /proc/sys/net/ipv4/vs/debug_level
>
>         You can show me such debug. The main thing to
> understand is where in IPVS the traffic is lost, the
> debug will be helpful, it should be no more than one
> page per packet. I need debug for one packet, something
> that you see is repeated in logs. May be due to the
> destination trash mechanism something is not set properly
> after the ipvsadm -C && ipvsadm -R sequence.

I'll provide those test result later.

So, about debug, do you mean when I find OPS is not working, then
cutoff the traffic, turn on debug with "echo 20 >
/proc/sys/net/ipv4/vs/debug_level", and then emulate the traffic with
a couple of packets, like this?

logger -d -n $VIP "hello, this is test"

Or, should I just enable debug for tiny time slice under high traffic?
