From: Julian Anastasov <ja@ssi.bg>
Subject: Re: ovf scheduler
Date: Tue, 14 Jul 2015 22:11:25 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1507142152450.1833@ja.home.ssi.bg>
References: <CAA0i4Bp0n-PooNaUq=F7MgD2Ou8=hdA6w+B0te5tcWP4ODxTfw@mail.gmail.com> <alpine.LFD.2.11.1507132328500.1708@ja.home.ssi.bg> <CAA0i4Bph-Gw00+-kUovvvfSgEta6XEH2-hGtSnusuPNdro2nCA@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <CAA0i4Bph-Gw00+-kUovvvfSgEta6XEH2-hGtSnusuPNdro2nCA@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "rhadoo.io88" <rhadoo.io88@gmail.com>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Tue, 14 Jul 2015, rhadoo.io88 wrote:

> Unfortunately i was not aware of the FO scheduler, i looked it up just
> now...indeed you could get similar behavior with FO scheduler and
> proper thresholds.
> The only trouble with that is that i can't set the thresholds from
> within ldirectord , so i won't be able to keep all the config in one
> place,  and that upper threshold seems to take into account all
> connections ( active and inactive) , that making the upper limit a bit
> vague.
> i think this approach has the advantage of keeping all the config in
> one place, having the weight set at the actual number of active
> connections the node can handle whilst still allowing to have
> thresholds on the total connections.

	OK. But you have to update this scheduler because
it is based on old code. You can use ip_vs_fo.c for
reference. You have to fix any coding style warnings by using
scripts/checkpatch.pl --strict /tmp/your.patch
You can check Documentation/CodingStyle for reference.
You can add comment that this scheduler can be used
for TCP/SCTP but not for UDP because it uses only the
activeconns.

	Your patch should include also changes for Kconfig
and Makefile.

	Also, the 'curentw = atomic_read(&dest->weight);'
can be used early to read the weight only once.

Regards

--
Julian Anastasov <ja@ssi.bg>
