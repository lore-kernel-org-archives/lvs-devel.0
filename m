From: Julian Anastasov <ja@ssi.bg>
Subject: Re: ipvsadm: One-packet scheduling with UDP service is unstable
Date: Sat, 24 Aug 2013 17:43:55 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1308241733040.3217@ja.ssi.bg>
References: <CAJiejCQPa7V703RwOeWPpbQMJQvfswRn+pvTKFmNdeU05RU3SQ@mail.gmail.com> <alpine.LFD.2.00.1308220925340.1727@ja.ssi.bg> <CAJiejCSdfBKC3c1dqya55R5T0VBCTm3qaM6nL-CY+H0o5hbwoA@mail.gmail.com> <alpine.LFD.2.00.1308221558160.2993@ja.ssi.bg>
 <CAJiejCT-WemVeAkWoDib2ZXHLRj=Lme3-Lk=prOOVKL=w3vA5A@mail.gmail.com> <alpine.LFD.2.00.1308231708450.1852@ja.ssi.bg> <CAJiejCRKMe=tHdre0DY5=B70FnLV29tvLimW7K____0VPcW=Xg@mail.gmail.com> <alpine.LFD.2.00.1308241543030.1976@ja.ssi.bg>
 <CAJiejCSeJGm8RB02S8ZGKNNtS=b1noo0ykrBFg84H+FDnhjdnw@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <CAJiejCSeJGm8RB02S8ZGKNNtS=b1noo0ykrBFg84H+FDnhjdnw@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Drunkard Zhang <gongfan193@gmail.com>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Sat, 24 Aug 2013, Drunkard Zhang wrote:

> >         May be we can enable debug for short time when
> > OPS is not working:
> >
> > # Start debug for 10ms
> > echo 20 > /proc/sys/net/ipv4/vs/debug_level
> > usleep 10000
> > # Stop debug
> > echo 0 > /proc/sys/net/ipv4/vs/debug_level
> >
> >         You can show me such debug. The main thing to
> > understand is where in IPVS the traffic is lost, the
> > debug will be helpful, it should be no more than one
> > page per packet. I need debug for one packet, something
> > that you see is repeated in logs. May be due to the
> > destination trash mechanism something is not set properly
> > after the ipvsadm -C && ipvsadm -R sequence.
> 
> I'll provide those test result later.
> 
> So, about debug, do you mean when I find OPS is not working, then
> cutoff the traffic, turn on debug with "echo 20 >
> /proc/sys/net/ipv4/vs/debug_level", and then emulate the traffic with
> a couple of packets, like this?
> 
> logger -d -n $VIP "hello, this is test"
> 
> Or, should I just enable debug for tiny time slice under high traffic?

	Whatever is your preference, it does not matter
for me. With traffic you risk to flood log in director,
for 10ms we get ~600 packets. I think, even usleep 1000
will work. And I'm not sure what will happen when many
CPUs write to log. If you stop the traffic and send just
one message under debug it would be more safe, if it is not
a problem that your service is not available for some seconds.

Regards

--
Julian Anastasov <ja@ssi.bg>
