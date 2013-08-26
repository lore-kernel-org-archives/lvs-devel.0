From: Drunkard Zhang <gongfan193@gmail.com>
Subject: Re: ipvsadm: One-packet scheduling with UDP service is unstable
Date: Mon, 26 Aug 2013 11:37:12 +0800
Message-ID: <CAJiejCSZKAZz0cmsys-xfuNUOQPD3qvEkR-Bm_X7aEF0aPu97w@mail.gmail.com>
References: <CAJiejCQPa7V703RwOeWPpbQMJQvfswRn+pvTKFmNdeU05RU3SQ@mail.gmail.com>
 <alpine.LFD.2.00.1308220925340.1727@ja.ssi.bg> <CAJiejCSdfBKC3c1dqya55R5T0VBCTm3qaM6nL-CY+H0o5hbwoA@mail.gmail.com>
 <alpine.LFD.2.00.1308221558160.2993@ja.ssi.bg> <CAJiejCT-WemVeAkWoDib2ZXHLRj=Lme3-Lk=prOOVKL=w3vA5A@mail.gmail.com>
 <alpine.LFD.2.00.1308231708450.1852@ja.ssi.bg> <CAJiejCRKMe=tHdre0DY5=B70FnLV29tvLimW7K____0VPcW=Xg@mail.gmail.com>
 <alpine.LFD.2.00.1308241543030.1976@ja.ssi.bg> <CAJiejCTBmSqog3WrfbgD9Cw6e4wXGCyhJX+cKvFbv9Dg=zF_AA@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:in-reply-to:references:from:date:message-id:subject:to
         :cc:content-type;
        bh=RoI2ye6G0ha6vch3od/JHutYKbMZ8+/I4RnK/kwDLJc=;
        b=IIjvkqWxZvbbybYUQvSgl0Z8MjPeTcHxcGRyjQ2jm1mfAZ0j+DsAQdOAYujYNCh23B
         qp395IjOUUp/hvp9+QS8t9HkuAA137sWFA19LVLDqXDOL7ePoZjfCHK7Nh20lXjhRLmR
         D3h7cDolDg0JZdtwG+T+F6ijGOLU3FkYdbeurPw8TKJe++PYRpKbP3onF/netDTeMH37
         hXJFG7KKKviMEB7LfT4F6ut0seA7eAUhZudsaljfuAd1gINiy+vWiLD0ROvxCJw0XyWR
         ssm3PFvHgjSJyFe1WZn0EVTi7VvV+AzQm0L65D/EHejYV8H8pzc4rWLSeVOcVnwD2cc5
         3gnw==
In-Reply-To: <CAJiejCTBmSqog3WrfbgD9Cw6e4wXGCyhJX+cKvFbv9Dg=zF_AA@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

Good news, I finally found the crap source, it's keepalived. I tested
several times without keepalived in runlevel 3, after kernel boots I
add the ipvs service by hand:

./ipvsadm -C
# Clear previous log
> /var/log/kern.log
sleep 1
# Start debug
echo 20 > /proc/sys/net/ipv4/vs/debug_level
./ipvsadm -R < /etc/keepalived/rules-with-ops
usleep 30000
# Stop debug
echo 0 > /proc/sys/net/ipv4/vs/debug_level

Then add VIP manually, then do ARP announce manually:
vs3 ~/pkgs # ip a add 150.164.100.120/32 dev eno1
vs3 ~/pkgs # arp-sk -i eno1 -S 150.164.100.120:90:b1:1c:1a:59:46 -d
150.164.100.126

After these actions, traffic starts come in. and all ipvsadm checks
are fine, OPS is fine too. So I figured that maybe outdated libipvs in
keepalived broke the ipvs in kernel. I'll try to report this to
upstream.

On the other hand, ipvs didn't recovery from ipvsadm -C, rmmod ip_vs
&& ./ipvsadm -R < rules-with-ops is needed (I tested, reload ip_vs
module could make OPS work). So robustness of IPVS needs improvement.

Thanks for all your help and kindness :-)
