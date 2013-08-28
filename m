From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: ipvsadm: One-packet scheduling with UDP service is unstable
Date: Wed, 28 Aug 2013 12:47:32 +0200
Message-ID: <20130828124732.5d294ae1@redhat.com>
References: <CAJiejCQPa7V703RwOeWPpbQMJQvfswRn+pvTKFmNdeU05RU3SQ@mail.gmail.com>
	<alpine.LFD.2.00.1308220925340.1727@ja.ssi.bg>
	<CAJiejCSdfBKC3c1dqya55R5T0VBCTm3qaM6nL-CY+H0o5hbwoA@mail.gmail.com>
	<alpine.LFD.2.00.1308221558160.2993@ja.ssi.bg>
	<CAJiejCT-WemVeAkWoDib2ZXHLRj=Lme3-Lk=prOOVKL=w3vA5A@mail.gmail.com>
	<alpine.LFD.2.00.1308231708450.1852@ja.ssi.bg>
	<CAJiejCRKMe=tHdre0DY5=B70FnLV29tvLimW7K____0VPcW=Xg@mail.gmail.com>
	<alpine.LFD.2.00.1308241543030.1976@ja.ssi.bg>
	<CAJiejCSeJGm8RB02S8ZGKNNtS=b1noo0ykrBFg84H+FDnhjdnw@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <CAJiejCSeJGm8RB02S8ZGKNNtS=b1noo0ykrBFg84H+FDnhjdnw@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Drunkard Zhang <gongfan193@gmail.com>
Cc: Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org, brouer@redhat.com

On Sat, 24 Aug 2013 22:15:16 +0800
Drunkard Zhang <gongfan193@gmail.com> wrote:

> >         May be we can enable debug for short time when
> > OPS is not working:
> >
> > # Start debug for 10ms
> > echo 20 > /proc/sys/net/ipv4/vs/debug_level
> > usleep 10000
> > # Stop debug
> > echo 0 > /proc/sys/net/ipv4/vs/debug_level

Just some general notes on debugging.

Debug verbose levels:
 -  1 is least verbose
 - 12 is most verbose
 -  0 disables debugging

Kernel needs to be compiled with CONFIG_IP_VS_DEBUG=y

To get even more detailed debugging. The macro IP_VS_DBG_PKT uses
debug_pr() to print its messages.  If the kernel is configured with
dynamic debug (CONFIG_DYNAMIC_DEBUG), you will not see these messages.
To enable these messages, do the following:

 mount -t debugfs none /sys/kernel/debug/
 cat /sys/kernel/debug/dynamic_debug/control | grep ipvs

 echo "func ip_vs_tcpudp_debug_packet_v6 +p" > /sys/kernel/debug/dynamic_debug/control
 echo "func ip_vs_tcpudp_debug_packet_v4 +p" > /sys/kernel/debug/dynamic_debug/control

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
