From: Julian Anastasov <ja@ssi.bg>
Subject: Re: ipvsadm: One-packet scheduling with UDP service is unstable
Date: Sun, 25 Aug 2013 09:07:31 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1308250840400.1603@ja.ssi.bg>
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

> I'll provide those test result later.

	In first email you said that traffic goes
to single server, is it first in list or what is its
position?

	Can you also check if sleep 1 solves the problem:

ipvsadm -C && sleep 1 && ipvsadm -R < rules-with-ops

Regards

--
Julian Anastasov <ja@ssi.bg>
