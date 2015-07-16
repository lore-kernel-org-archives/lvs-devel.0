From: Julian Anastasov <ja@ssi.bg>
Subject: Re: ovf scheduler
Date: Thu, 16 Jul 2015 10:56:54 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1507161044500.1681@ja.home.ssi.bg>
References: <CAA0i4Bp0n-PooNaUq=F7MgD2Ou8=hdA6w+B0te5tcWP4ODxTfw@mail.gmail.com> <alpine.LFD.2.11.1507132328500.1708@ja.home.ssi.bg> <CAA0i4Bph-Gw00+-kUovvvfSgEta6XEH2-hGtSnusuPNdro2nCA@mail.gmail.com> <alpine.LFD.2.11.1507142152450.1833@ja.home.ssi.bg>
 <CAA0i4Bo3w3msK9Tdn1T3BNa-ZyQ6mon=XeXFRkSfsWHRVEua=w@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <CAA0i4Bo3w3msK9Tdn1T3BNa-ZyQ6mon=XeXFRkSfsWHRVEua=w@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Raducu Deaconu <rhadoo.io88@gmail.com>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Thu, 16 Jul 2015, Raducu Deaconu wrote:

> Hi,
> I have updated the code and generated the patch, according to your indications.

	When patch is attached it is difficult to
comment it. Anyways, I'll try.

- The Subject should include "ipvs: ",
eg. Subject: [PATCH] ipvs: add ovf scheduler

- In Kconfig the "tristate..." line has wrong indentation,
one tab should be removed

- When debugging is enabled (CONFIG_IP_VS_DEBUG=y) the module
does not compile, you can also use short var names, eg:

	struct ip_vs_dest *dest, *h = NULL;
	int hw = 0, w;

- the comment block "select the node..." has one empty line
at end, should be removed

- the 'if ...' blocks in the loop are not properly indented

Regards

--
Julian Anastasov <ja@ssi.bg>
