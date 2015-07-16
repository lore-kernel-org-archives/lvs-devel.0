From: Julian Anastasov <ja@ssi.bg>
Subject: Re: ovf scheduler
Date: Thu, 16 Jul 2015 21:27:21 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1507162119020.2164@ja.home.ssi.bg>
References: <CAA0i4Bp0n-PooNaUq=F7MgD2Ou8=hdA6w+B0te5tcWP4ODxTfw@mail.gmail.com> <alpine.LFD.2.11.1507132328500.1708@ja.home.ssi.bg> <CAA0i4Bph-Gw00+-kUovvvfSgEta6XEH2-hGtSnusuPNdro2nCA@mail.gmail.com> <alpine.LFD.2.11.1507142152450.1833@ja.home.ssi.bg>
 <CAA0i4Bo3w3msK9Tdn1T3BNa-ZyQ6mon=XeXFRkSfsWHRVEua=w@mail.gmail.com> <alpine.LFD.2.11.1507161044500.1681@ja.home.ssi.bg> <CAA0i4BrKP91wiFOWpPpmFP3L1ZdVCPTdDk6PkJrGYGPWkqpxxw@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <CAA0i4BrKP91wiFOWpPpmFP3L1ZdVCPTdDk6PkJrGYGPWkqpxxw@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Raducu Deaconu <rhadoo.io88@gmail.com>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Thu, 16 Jul 2015, Raducu Deaconu wrote:

> Hello,
> 
> I have readjusted the patch, sorry for the code style issues, this is
> my first attempt at a contribution.

	No worries. But one new problem...

> +               if (h) {
> +                       IP_VS_DBG_BUF(6, "OVF: server %s:%u active %d w %d\n",
> +                                     IP_VS_DBG_ADDR(svc->af, &h->addr),

	Indentation of this 'if' block should be fixed.
It was correct in first patch. Also, change svc->af to
h->af in above line.

> +                                     ntohs(h->port),
> +                                     atomic_read(&h->activeconns),
> +                                     atomic_read(&h->weight));
> +               return h;
> +               }

Regards

--
Julian Anastasov <ja@ssi.bg>
