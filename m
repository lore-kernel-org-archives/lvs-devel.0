From: Smart Weblications GmbH - Florian Wiessner 
	<f.wiessner@smart-weblications.de>
Subject: Re: 3.12.33 - BUG xfrm_selector_match+0x25/0x2f6
Date: Thu, 11 Dec 2014 15:04:21 +0100
Message-ID: <5489A465.6090305@smart-weblications.de>
References: <547F2462.6040405@smart-weblications.de> <20141204075627.GE6390@secunet.com> <alpine.LFD.2.11.1412042338370.4841@ja.home.ssi.bg> <5481173A.9060308@smart-weblications.de> <alpine.LFD.2.11.1412051126090.2522@ja.home.ssi.bg> <5481B944.2000002@smart-weblications.de> <alpine.LFD.2.11.1412072019410.1885@ja.home.ssi.bg> <54858948.2060007@smart-weblications.de> <alpine.LFD.2.11.1412082234350.2401@ja.home.ssi.bg> <5486CD9D.4060107@smart-weblications.de> <alpine.LFD.2.11.1412102331230.4043@ja.home.ssi.bg>
Reply-To: f.wiessner@smart-weblications.de
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.11.1412102331230.4043@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Julian Anastasov <ja@ssi.bg>
Cc: Steffen Klassert <steffen.klassert@secunet.com>, netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, stable@vger.kernel.org, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org

Hi,

Am 10.12.2014 22:41, schrieb Julian Anastasov:>
> 	Hello,
>
> On Tue, 9 Dec 2014, Smart Weblications GmbH - Florian Wiessner wrote:
>
>> I rebuild everything with the two provided patches and still get:
>>
>> [  512.475449] BUG: unable to handle kernel NULL pointer dereference=
 at
>> 0000000000000014
>> [  512.481277] IP: [<ffffffffa013d470>] nf_ct_seqadj_set+0x60/0x90 [=
nf_conntrack]
>
> 	Same place, hm...
>
>> [  512.485323] CPU: 4 PID: 28142 Comm: vsftpd Not tainted 3.12.33 #5
>
> 	Above "#5" is same as previous oops. It means kernel
> is not updated. Or you updated only the IPVS modules after
> applying the both patches?

I did it with make-kpkg --initrd linux_image which only rebuilt the mod=
ules,
correct. I can retry with make clean before building the package

>
> 	You can also try without FTP tests to see if there
> are oopses in xfrm, so that we can close this topic and then
> to continue for the FTP problem on IPVS lists without
> bothering non-IPVS people.
>

yeah, it seems that the xfrm issue is away.


--=20

Mit freundlichen Gr=FC=DFen,

=46lorian Wiessner

Smart Weblications GmbH
Martinsberger Str. 1
D-95119 Naila

fon.: +49 9282 9638 200
fax.: +49 9282 9638 205
24/7: +49 900 144 000 00 - 0,99 EUR/Min*
http://www.smart-weblications.de

--
Sitz der Gesellschaft: Naila
Gesch=E4ftsf=FChrer: Florian Wiessner
HRB-Nr.: HRB 3840 Amtsgericht Hof
*aus dem dt. Festnetz, ggf. abweichende Preise aus dem Mobilfunknetz
