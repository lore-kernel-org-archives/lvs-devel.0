From: Marco Angaroni <marcoangaroni@gmail.com>
Subject: SIP persistence engine - incorrect search of callid header
Date: Fri, 5 Feb 2016 15:10:15 +0100
Message-ID: <CANHHuCWbUAa1UqGCNTY1uODcXZAtxyCw6uPbSQeweA3oRWxPOw@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:date:message-id:subject:from:to:content-type
         :content-transfer-encoding;
        bh=v0k93daKr7I+iV1HBHuClfF2xnHNw4+3oM+utGRcdgg=;
        b=bYJqfKsNZNEyi+JtsLHeLlvoCURoLgTpqdzxd9cLdIBTZLh/yFIxWBEFFS0TCYsdwe
         TIvk6Jm0+O4n0qT31iEkwMmun+4pvetVQpS4RkYBEfIslZ1rGCeLRcSvSCb2ix4FpV85
         x2nI3H9NZGwU++d7Pv/nkKywbPBWblPJRN6l8/LSh+1FxYNmVTsUoG5Tpa/CmdAxDaYJ
         XvofRC6N1vfl/D31DYOUdYVw0iTUxlFfKfi4o/tTCdlEUxVvXusAT0LQ4g89qGgYCpI7
         QyL9r6TIkQsTvcGD+mXWbU/ioLnBr+K4RUDy6jnzSWQxLMWr9AQiNzPkPL+KNN+gBUir
         onJw==
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: lvs-devel@vger.kernel.org

Hello,

the IPVS SIP persistence engine is not able to parse the SIP header
=E2=80=9CCall-ID=E2=80=9D when such header is inserted in the first pos=
itions of the
SIP message.

When IPVS is configured with '--pe sip' option (ex. ipvsadm -A -u
10.0.2.15:5060 -s rr --pe sip -p 120 -o), you can verify that messages
like this one do not create entries in the connection template table
(ipvsadm -Lcn --persistent-conn), .

SIP/2.0 200 OK
Call-ID: a84b4c76e66710@pc33.atlanta.com
Via: SIP/2.0/UDP pc33.atlanta.com;branch=3Dz9hG4bK776asdhds
Max-Forwards: 70
To: Bob <sip:bob@biloxi.com>
=46rom: Alice <sip:alice@atlanta.com>;tag=3D1928301774
CSeq: 314159 INVITE
Contact: <sip:alice@pc33.atlanta.com>
Content-Length: 0

Instead when the =E2=80=9CCall-ID=E2=80=9D is positioned down (after =E2=
=80=9CFrom=E2=80=9D header for
example), the header is recognized.

This is due to the data offset used in get_callid function call inside
ip_vs_pe_sip.c file: since dptr already points to the start of the SIP
message, the value of dataoff should be initially 0. Otherwise the
header is searched starting from some bytes after the first character
of the SIP message.

This patch , in my tests, solved the problem. I'm using the sources of
kernel 3.10.0-229.20.1.el7.x86_64 (RH7).

 --- a/ip_vs_pe_sip.c 2015-09-24 17:47:25.000000000 +0200
+++ b/ip_vs_pe_sip.c 2016-01-28 15:08:34.309934600 +0100
@@ -88,7 +88,7 @@
dptr =3D skb->data + dataoff;
datalen =3D skb->len - dataoff;

- if (get_callid(dptr, dataoff, datalen, &matchoff, &matchlen))
+ if (get_callid(dptr, 0, datalen, &matchoff, &matchlen))
return -EINVAL;

  /* N.B: pe_data is only set on success,



Marco Angaroni
