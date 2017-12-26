From: =?UTF-8?B?5p2O5pil?= <pickup112@gmail.com>
Subject: Re: LVS TCP package fragment
Date: Tue, 26 Dec 2017 21:42:42 +0800
Message-ID: <CAGpjB9La3ZH0+xJ8RcuidjsB3asXfBOY_Z2JKeeUApOortwtAg@mail.gmail.com>
References: <CAGpjB9LEJrVUmdhe-mV+y7VaXwinyHCN0w9Y36gQEYy34mpWpg@mail.gmail.com>
 <a308974f-9f14-0bd8-1d60-1032def3822e@schiro.it>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:in-reply-to:references:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=S/m3eQkATLol3DLOtg681e3SdnW33XjRIOj3RxmH0co=;
        b=mqR+79K925y0E/nJT6Fbx1u+V3+jSQGWbjNRWOwB9WlEb57ngH8LDa8nCATBynyVDo
         6mQ1JTWsu8ZwOt7p8vEnEh+lE20BHVfGQtrnyaElxTNeI4MikhA7pVNME5nPSQeNBih4
         qJODfyZrdQYMLa0bqet2GpsB21bTf426636JEdl7ZhOREWhAgHquSb/jOOq1CTL7MO/2
         xwNlJNmkuV4TWHW4SQFa4y/O41zMU4V2BFTCaZPITfiEcdIwS6QVTILZQ9L79zQLylhG
         CCDBbQW/rKuep4fRF3H2WJZacow9SE0lprGx/3rgcFUFuQO6a/D+Vvyq6BMBoYz8sPH7
         jWDA==
In-Reply-To: <a308974f-9f14-0bd8-1d60-1032def3822e@schiro.it>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Paolo Schiro <paolo@schiro.it>
Cc: lvs-devel@vger.kernel.org

Thanks for reply.
It seems not the problem of checksum.
Because the LVS send a 252 length package and checksum of 0x5d97, but
real server get a 248 package with the same checksum 0x5d97.

I still want to  check the environment of checksum offload on the LVS serve=
r.
But unfortunately we can not reproduce the problem on  "net.ipv4.ip_forward=
 =3D 0"


2017-07-24 16:47 GMT+08:00 Paolo Schiro <paolo@schiro.it>:
> Checksum problems are usally caused by ethernet offloads.
> try play with ethtool -k -K.
>
> Il 17/07/2017 16:04, =E6=9D=8E=E6=98=A5 ha scritto:
>>
>> I have meet a very strange problem in my LVS environment.
>>
>>
>> when I connect to mysqld real server, mysql client is ok.
>> when I connect to LVS to access to the real server, mysql client report
>> error.
>>
>>
>> I config the LVS as DR mode like this:
>> ```
>> ipvsadm -A -t 158.222.165.185:3306 -s wrr
>> ipvsadm -a -t 158.222.165.185:3306 -r 158.222.165.125:3306 -g -w 100
>> ```
>>
>>
>>
>> And I have tcpdump the package on the LVS and real server.
>> Sync/Sync+ack/ack of Three-way Handshake is ok=EF=BC=8Cand four-way hand=
shake is
>> ok.
>> But when mysql client send the login request (user/password) package,
>> the package fragment.
>>
>>
>> As show as follows,The LVS received the package and send it the real
>> server correct(length 252).
>> But real server get a fragment of the package (length 248) and a error
>> chksum. It have missed the 4 bytes fragment of the package.
>>
>>
>> Here is the package I have ```tcpdump -lnnneeevvv``` on the LVS.
>> * 9c:dc:71:4d:49:d0 =3D 158.222.165.126 is the client
>> * 24:8a:07:64:7f:21 =3D 158.222.165.185 is the VIP and the director
>> * 24:8a:07:64:56:41 =3D 158.222.165.185 is the real server
>>
>>
>> LVS package:
>> ```
>> 19:12:22.229356 9c:dc:71:4d:49:d0 > 24:8a:07:64:7f:21, ethertype IPv4
>> (0x0800), length 252: (tos 0x8, ttl 64, id 56669, offset 0, flags
>> [DF], proto TCP (6), l
>>      158.222.165.126.37691 > 158.222.165.185.3306: Flags [P.], cksum
>> 0x5d97 (correct), seq 0:198, ack 83, win 115, length 198
>> 19:12:22.229367 24:8a:07:64:7f:21 > 24:8a:07:64:56:41, ethertype IPv4
>> (0x0800), length 252: (tos 0x8, ttl 64, id 56669, offset 0, flags
>> [DF], proto TCP (6), l
>>      158.222.165.126.37691 > 158.222.165.185.3306: Flags [P.], cksum
>> 0x5d97 (correct), seq 0:198, ack 83, win 115, length 198
>> ```
>>
>>
>> real server packages:
>> ```
>> 19:12:21.803118 24:8a:07:64:7f:21 > 24:8a:07:64:56:41, ethertype IPv4
>> (0x0800), length 248: (tos 0x8, ttl 64, id 56668, offset 0, flags
>> [DF], proto TCP (6), l
>>      158.222.165.126.37691 > 158.222.165.185.3306: Flags [.], cksum
>> 0x5d97 (incorrect -> 0x4883), seq 1:195, ack 83, win 115, length 194
>> 19:12:21.803126 24:8a:07:64:7f:21 > 24:8a:07:64:56:41, ethertype IPv4
>> (0x0800), length 60: (tos 0x8, ttl 64, id 56669, offset 0, flags [DF],
>> proto TCP (6), le
>>      158.222.165.126.37691 > 158.222.165.185.3306: Flags [P.], cksum
>> 0x7973 (incorrect -> 0x5fb3), seq 199, ack 83, win 115, length 0
>> ```
>>
>>
>>
>> * we run the test on rhel6.7 with ipvsadm v1.26 2008/5/15 (compiled
>> with popt and IPVS v1.2.1)
>> * our network engineer have mirror the port of LVS and report that the
>> package is fragmented from LVS director.
>> * we have replace the broadcom network card to mellanox netword card,
>> but it still the same problem
>>
>>
>> And I have not config net.ipv4.ip_forward =3D 1 accord to
>> http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.LVS-DR.html
>> But if I config "net.ipv4.ip_forward =3D 1 ", there are no package
>> fragment. MySQL connect to mysqld (throught LVS) successfully.
>>
>>
>> Have any one meet the problem, do you resolve it ? Or any one can help
>> to fix it.
>>
>



--=20
pickup.lichun =E6=9D=8E=E6=98=A5
