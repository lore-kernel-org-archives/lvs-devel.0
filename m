From: Smart Weblications GmbH - Florian Wiessner 
	<f.wiessner@smart-weblications.de>
Subject: Re: 3.12.33 - BUG xfrm_selector_match+0x25/0x2f6
Date: Fri, 05 Dec 2014 14:55:16 +0100
Message-ID: <5481B944.2000002@smart-weblications.de>
References: <547F2462.6040405@smart-weblications.de> <20141204075627.GE6390@secunet.com> <alpine.LFD.2.11.1412042338370.4841@ja.home.ssi.bg> <5481173A.9060308@smart-weblications.de> <alpine.LFD.2.11.1412051126090.2522@ja.home.ssi.bg>
Reply-To: f.wiessner@smart-weblications.de
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.11.1412051126090.2522@ja.home.ssi.bg>
Sender: stable-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Julian Anastasov <ja@ssi.bg>
Cc: Steffen Klassert <steffen.klassert@secunet.com>, netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, stable@vger.kernel.org, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org

Hi,

Am 05.12.2014 10:55, schrieb Julian Anastasov:

>=20
> On Fri, 5 Dec 2014, Smart Weblications GmbH - Florian Wiessner wrote:
>=20
>> i tried with 3.12.33 without any XFRM and now got this one (which is=
 reproducable):
>>
>> [  233.956012] BUG: unable to handle kernel NULL pointer dereference=
 at 00000000
>>                                    00000014
>> [  233.956218] IP: [<ffffffffa013a470>] nf_ct_seqadj_set+0x60/0x90 [=
nf_conntrack
>=20
> 	It seems fix from 3.13 was not sent to 3.12 stable:
>=20
> commit b25adce1606427fd8 ("ipvs: correct usage/allocation of seqadj e=
xt in=20
> ipvs")
>=20
> 	There was related change but it is not needed
> for stable kernels:
>=20
> commit db12cf27435356017e ("netfilter: WARN about wrong usage of sequ=
ence=20
> number adjustments"
>=20
> 	Simon, can we try commit b25adce1606427fd8 for 3.12?


>> setup is like this:
>>
>>
>> #virtual=3D<myVIP>:21
>> #       real=3D10.10.1.20:21 masq
[...]
>> #       service=3Dftp
>> #       scheduler=3Drr
>> #       protocol=3Dtcp
>> #       checktype=3Dconnect
>>
>> ( i remarked it to prevent fruther crashes...)
>>
>> when ip_vs_ftp is loaded and someone trying to make a ftp connection=
, the system
>> panics instantly.
>>
>> 10.10.1.20 - 10.10.1.23 are lxc-containers using veth connected to t=
he bridge
>> running on 4 different nodes. The node running ldirector/ipvsadm has=
 also one of
>> those containers running (don't know if that matters)
>=20
> 	It is always good to know the setup. Do you access VIP
> from local clients (from director)?
>=20

Not for ftp, but we have mail as well in the same setup, and yes, there=
 we do
access it from local client.

>> brctl show
>> bridge name     bridge id               STP enabled     interfaces
>> br0             8000.00259052bbf4       no              bond0
>>                                                         vethMKELUc

[...]

> 	Before I create patch to avoid rerouting for
> LOCAL_IN you can try to set IPVS sysctl var "snat_reroute" to 0
> or even to change ip_vs_route_me_harder() function just to return 0.
> snat_reroute=3D1 (a default value) is needed if you have
> multiple links to clients and use ip rules to select
> correct route by src ip (after SNAT). If you have single
> uplink snat_reroute can be 0.
>=20


ip rule show

0:      from all lookup local
32765:  from all to 10.10.0.0/16 lookup 200

I use ip rules, but this is not for source but destination. I need this=
 to
enable clients from the local net to connect to some VIPs so they get t=
here
correct route back.

I have also seen "b25adce1606427fd8 ipvs: correct usage/allocation of s=
eqadj ext
in ipvs" in the net while googling, but i thought that it would be incl=
uded in
3.12.33 as the patch is over a year old and since this is marked as sta=
ble i did
not expect any issues.

Maybe i would not have stubmled accross this if the ocfs2 devs were as =
fast as
the netdev-devs! But to my ocfs2 isseu/bug i still have no reply until =
today. So
thank you for the fast responses! I would like to test any patch for 3.=
12.

If i understand correctly, i set:

echo 0 > /proc/sys/net/ipv4/vs/snat_reroute
modprobe ip_vs_ftp

and reenable ftp ipvs?

It does not crash, but ftp is not working with neither PASV nor PORT:


[14:47:42] [R] Verbindung herstellen zu 192.168.10.62 -> IP=3D192.168.1=
0.62 PORT=3D21
[14:47:42] [R] Verbunden mit 192.168.10.62
[14:47:43] [R] 220 (vsFTPd 3.0.2)
[14:47:43] [R] USER (hidden)
[14:47:43] [R] 331 Please specify the password.
[14:47:43] [R] PASS (hidden)
[14:47:43] [R] 230 Login successful.
[14:47:43] [R] SYST
[14:47:43] [R] 215 UNIX Type: L8
[14:47:43] [R] FEAT
[14:47:43] [R] 211-Features:
[14:47:43] [R]  EPRT
[14:47:43] [R]  EPSV
[14:47:43] [R]  MDTM
[14:47:43] [R]  PASV
[14:47:43] [R]  REST STREAM
[14:47:43] [R]  SIZE
[14:47:43] [R]  TVFS
[14:47:43] [R]  UTF8
[14:47:43] [R] 211 End
[14:47:43] [R] PWD
[14:47:43] [R] 257 "/"
[14:47:43] [R] CWD /
[14:47:43] [R] 250 Directory successfully changed.
[14:47:43] [R] PWD
[14:47:43] [R] 257 "/"
[14:47:43] [R] TYPE A
[14:47:43] [R] 200 Switching to ASCII mode.
[14:47:43] [R] PASV
[14:47:43] [R] 227 Entering Passive Mode (10,10,1,23,251,6).
[14:47:43] [R] Datenkanal-IP =F6ffnen: 192.168.10.62 PORT: 64262
[14:47:44] [R] Datensocket-Fehler: Verbindung abgewiesen
[14:47:44] [R] List Fehler
[14:47:44] [R] PASV
[14:47:44] [R] 227 Entering Passive Mode (10,10,1,23,250,144).
[14:47:44] [R] Datenkanal-IP =F6ffnen: 192.168.10.62 PORT: 64144
[14:47:45] [R] Datensocket-Fehler: Verbindung abgewiesen
[14:47:45] [R] List Fehler
[14:47:45] [R] PASV-Modus fehlgeschlagen, PORT -Modus versuchen...
[14:47:45] [R] Auf PORT: 62505 warten, Verbindung erwarten.
[14:47:45] [R] PORT 192,168,200,13,244,41
[14:47:45] [R] 500 Illegal PORT command.
[14:47:45] [R] List Fehler
[14:48:14] [R] QUIT
[14:48:14] [R] 221 Goodbye.
[14:48:14] [R] Ausgeloggt: 192.168.10.62


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
