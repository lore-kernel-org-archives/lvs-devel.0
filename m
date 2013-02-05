From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re: AW: How does the mode fullnat work in detail and is 
	implemented?
Date: Tue, 5 Feb 2013 15:06:50 +0100 (CET)
Message-ID: <npf7fa8.9c77446ae41a9082dd5a9b7f0f5db267@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Stefan Bauer <stefan.bauer@cubewerk.de>
Cc: "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>


>---- Original Message ----
>From: Stefan Bauer <stefan.bauer@cubewerk.de>
>To: "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>
>Sent: Tue, Feb 5, 2013, 2:29 PM
>Subject: AW: How does the mode fullnat work in detail and is implement=
ed?
>
>-----Urspr=C3=BCngliche Nachricht-----
>Von:	Simon Horman <horms@verge.net.au>
>> > I'm more than happy to get this informations. thank you. So the in=
itial=20
>> patches are not used in the mainline kernel hence can be seen as obs=
olete. Also=20
>> the patches for ipvsadm are useless as its used with the regular NAT=
 mode.
>>=20
>> Yes, AFIC that is correct.
>
>And through full-nat, the IPVS does not have to be the default gw in l=
ocal network anymore correct?
>
>Furthermore, the IPVS itself can also host on the same machine a real-=
server right?

Yes, but if you want a uniform configuration=20
place IPVS into a network namespace (use LXC it makes life easier),
then there is no diff in the configuration even if the RS runs on the s=
ame physical machine.
This configuration might need more NIC:s or you can use macvlan or vlan=
 depening on the traffic load.

BR
Hans Schillstrom

