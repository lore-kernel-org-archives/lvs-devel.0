From: Alexis Vachette <avachette@deezer.com>
Subject: netfilter: ipvs: using maglev scheduler algorithm
Date: Thu, 21 Oct 2021 11:54:32 +0200
Message-ID: <CAP962rShHbVtXNONwRWda6xAZ_L8kVWTSNZc_bC=gCetUMpNHw@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=deezer.com; s=google;
        h=mime-version:from:date:message-id:subject:to
         :content-transfer-encoding;
        bh=uaImw6JQvHAj6XEqRgU/2G7iZy+1366o2W9rw6TGRRE=;
        b=OetSE+5iUZ/MiTD6dV+L4Cm0CZLhhW9VSvduhtd+ucshMVCEtKvisih9VMOrWLV4CW
         U9PXjFC02KQCtY6jAEx0IGSR7cyh6gP81go9i8CmwiJUqAMsVNcSmiTgwrYkNT4R6oRU
         SNlPiBSoLlffaqTzD3LGWur7UjCY9t87tJ4CA=
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: lvs-devel@vger.kernel.org

Hello everyone,

If this is not the correct list to address my issue feel free to tell me.

We are heavily using Netfilter/IPVS with maglev scheduler algorithm
and it's working great on most use case.

The only case when we face issue is when inhibit_on_failure option is enabl=
ed.

Here is our setup:

- 2 LVS director in active/passive mode
- 2 backend node

Exposed service is SSH using port 2222.

You can find below the LVS state when issue is occurring:

root@dev-lvstest-01 ~ =E2=9D=B1 ipvsadm -L -n
IP Virtual Server version 1.2.1 (size=3D1048576)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  172.16.42.170:2222 mh (mh-port)
  -> 172.16.42.168:2222            Route   100    0          0
  -> 172.16.42.169:2222            Route   0      0          0

Here is a working example output:

root@dev-lvstest-01 ~ =E2=9D=B1 tail -f /var/log/kern.20211021 | grep "172.=
16.42.170"
Oct 21 09:18:32 dev-lvstest-01 kernel: [ 134.322832] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:32 dev-lvstest-01 kernel: [ 134.322834] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:32 dev-lvstest-01 kernel: [ 134.322836] IPVS: lookup
service: fwm 0 TCP 172.16.42.170:2222 hit
Oct 21 09:18:32 dev-lvstest-01 kernel: [ 134.322851] IPVS: Bind-dest
TCP c:10.0.0.6:49677 v:172.16.42.170:2222 d:172.31.0.168:2222 fwd:R
s:53052 conn->flags:183 conn->refcnt:1 dest->refcnt:2048
Oct 21 09:18:32 dev-lvstest-01 kernel: [ 134.322855] IPVS: Schedule
fwd:R c:10.0.0.6:49677 v:172.16.42.170:2222 d:172.31.0.168:2222
conn->flags:1C3 conn->refcnt:2
Oct 21 09:18:32 dev-lvstest-01 kernel: [ 134.322858] IPVS: TCP input
[S...] c:10.0.0.6:49677 v:172.16.42.170:2222 d:172.31.0.168:2222
state: NONE->SYN_RECV conn->refcnt:2
Oct 21 09:18:32 dev-lvstest-01 kernel: [ 134.324470] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:32 dev-lvstest-01 kernel: [ 134.324473] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 hit
Oct 21 09:18:32 dev-lvstest-01 kernel: [ 134.324475] IPVS: TCP input
[..A.] c:10.0.0.6:49677 v:172.16.42.170:2222 d:172.31.0.168:2222
state: SYN_RECV->ESTABLISHED conn->refcnt:2
Oct 21 09:18:32 dev-lvstest-01 kernel: [ 134.324998] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:32 dev-lvstest-01 kernel: [ 134.325002] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 hit
Oct 21 09:18:32 dev-lvstest-01 kernel: [ 134.334977] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:32 dev-lvstest-01 kernel: [ 134.334979] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 hit
Oct 21 09:18:32 dev-lvstest-01 kernel: [ 134.336872] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:32 dev-lvstest-01 kernel: [ 134.336875] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 hit
Oct 21 09:18:32 dev-lvstest-01 kernel: [ 134.342537] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:32 dev-lvstest-01 kernel: [ 134.342539] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 hit
Oct 21 09:18:32 dev-lvstest-01 kernel: [ 134.345179] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:32 dev-lvstest-01 kernel: [ 134.345181] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 hit
Oct 21 09:18:32 dev-lvstest-01 kernel: [ 134.350319] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:32 dev-lvstest-01 kernel: [ 134.350322] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 hit
Oct 21 09:18:32 dev-lvstest-01 kernel: [ 134.374611] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:32 dev-lvstest-01 kernel: [ 134.374614] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 hit
Oct 21 09:18:32 dev-lvstest-01 kernel: [ 134.419041] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:32 dev-lvstest-01 kernel: [ 134.419045] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 hit
Oct 21 09:18:32 dev-lvstest-01 kernel: [ 134.421754] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:32 dev-lvstest-01 kernel: [ 134.421756] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 hit
Oct 21 09:18:32 dev-lvstest-01 kernel: [ 134.421763] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:32 dev-lvstest-01 kernel: [ 134.421764] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 hit
Oct 21 09:18:32 dev-lvstest-01 kernel: [ 134.432266] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:32 dev-lvstest-01 kernel: [ 134.432268] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 hit
Oct 21 09:18:32 dev-lvstest-01 kernel: [ 134.432289] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:32 dev-lvstest-01 kernel: [ 134.432291] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 hit
Oct 21 09:18:32 dev-lvstest-01 kernel: [ 134.434754] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:32 dev-lvstest-01 kernel: [ 134.434757] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 hit
Oct 21 09:18:33 dev-lvstest-01 kernel: [ 135.041063] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:33 dev-lvstest-01 kernel: [ 135.041065] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 hit
Oct 21 09:18:33 dev-lvstest-01 kernel: [ 135.053383] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:33 dev-lvstest-01 kernel: [ 135.053385] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 hit
Oct 21 09:18:33 dev-lvstest-01 kernel: [ 135.053398] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:33 dev-lvstest-01 kernel: [ 135.053400] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 hit
Oct 21 09:18:34 dev-lvstest-01 kernel: [ 135.706476] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:34 dev-lvstest-01 kernel: [ 135.706479] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 hit
Oct 21 09:18:34 dev-lvstest-01 kernel: [ 135.708135] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:34 dev-lvstest-01 kernel: [ 135.708137] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 hit
Oct 21 09:18:34 dev-lvstest-01 kernel: [ 135.708208] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:34 dev-lvstest-01 kernel: [ 135.708210] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 hit
Oct 21 09:18:34 dev-lvstest-01 kernel: [ 135.711111] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:34 dev-lvstest-01 kernel: [ 135.711115] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 hit
Oct 21 09:18:34 dev-lvstest-01 kernel: [ 135.711130] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:34 dev-lvstest-01 kernel: [ 135.711133] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 hit
Oct 21 09:18:34 dev-lvstest-01 kernel: [ 135.711155] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:34 dev-lvstest-01 kernel: [ 135.711156] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 hit
Oct 21 09:18:34 dev-lvstest-01 kernel: [ 135.711183] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:34 dev-lvstest-01 kernel: [ 135.711184] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 hit
Oct 21 09:18:34 dev-lvstest-01 kernel: [ 135.711192] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:34 dev-lvstest-01 kernel: [ 135.711194] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 hit
Oct 21 09:18:34 dev-lvstest-01 kernel: [ 135.711202] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:34 dev-lvstest-01 kernel: [ 135.711203] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 hit
Oct 21 09:18:34 dev-lvstest-01 kernel: [ 135.711219] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:34 dev-lvstest-01 kernel: [ 135.711220] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 hit
Oct 21 09:18:34 dev-lvstest-01 kernel: [ 135.711228] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:34 dev-lvstest-01 kernel: [ 135.711230] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 hit
Oct 21 09:18:34 dev-lvstest-01 kernel: [ 135.711237] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:34 dev-lvstest-01 kernel: [ 135.711239] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 hit
Oct 21 09:18:34 dev-lvstest-01 kernel: [ 135.711255] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:34 dev-lvstest-01 kernel: [ 135.711256] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 hit
Oct 21 09:18:34 dev-lvstest-01 kernel: [ 135.712512] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:34 dev-lvstest-01 kernel: [ 135.712515] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 hit
Oct 21 09:18:34 dev-lvstest-01 kernel: [ 135.712526] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:34 dev-lvstest-01 kernel: [ 135.712528] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 hit
Oct 21 09:18:34 dev-lvstest-01 kernel: [ 136.098170] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:34 dev-lvstest-01 kernel: [ 136.098173] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 hit
Oct 21 09:18:38 dev-lvstest-01 kernel: [ 139.563477] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:38 dev-lvstest-01 kernel: [ 139.563482] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 hit
Oct 21 09:18:38 dev-lvstest-01 kernel: [ 139.566119] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:38 dev-lvstest-01 kernel: [ 139.566123] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 hit
Oct 21 09:18:38 dev-lvstest-01 kernel: [ 139.566150] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:38 dev-lvstest-01 kernel: [ 139.566152] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 hit
Oct 21 09:18:38 dev-lvstest-01 kernel: [ 139.566215] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:38 dev-lvstest-01 kernel: [ 139.566218] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 hit
Oct 21 09:18:38 dev-lvstest-01 kernel: [ 139.566238] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:38 dev-lvstest-01 kernel: [ 139.566240] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 hit
Oct 21 09:18:38 dev-lvstest-01 kernel: [ 139.566252] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:38 dev-lvstest-01 kernel: [ 139.566254] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 hit
Oct 21 09:18:38 dev-lvstest-01 kernel: [ 139.566255] IPVS: TCP input
[.FA.] c:10.0.0.6:49677 v:172.16.42.170:2222 d:172.31.0.168:2222
state: ESTABLISHED->FIN_WAIT conn->refcnt:2
Oct 21 09:18:38 dev-lvstest-01 kernel: [ 139.570330] IPVS: lookup/out
TCP 10.0.0.6:49677->172.16.42.170:2222 not hit
Oct 21 09:18:38 dev-lvstest-01 kernel: [ 139.570335] IPVS: lookup/in
TCP 10.0.0.6:49677->172.16.42.170:2222 hit

Here is the output when we face the issue described above:

root@dev-lvstest-01 ~ =E2=98=A0 =E2=9D=B1 tail -f /var/log/kern.20211021 | =
grep "172.16.42.170"
Oct 21 09:17:34 dev-lvstest-01 kernel: [   75.590627] IPVS: lookup/out
TCP 10.0.0.6:49673->172.16.42.170:2222 not hit
Oct 21 09:17:34 dev-lvstest-01 kernel: [   75.590630] IPVS: lookup/in
TCP 10.0.0.6:49673->172.16.42.170:2222 not hit
Oct 21 09:17:34 dev-lvstest-01 kernel: [   75.590633] IPVS: lookup
service: fwm 0 TCP 172.16.42.170:2222 hit
Oct 21 09:17:34 dev-lvstest-01 kernel: [   75.590637] IPVS: mh: TCP
172.16.42.170:2222 - no destination available
Oct 21 09:17:34 dev-lvstest-01 kernel: [   75.593020] IPVS: lookup/out
TCP 172.16.42.170:2222->10.0.0.6:49673 not hit
Oct 21 09:17:34 dev-lvstest-01 kernel: [   75.593022] IPVS: lookup/in
TCP 172.16.42.170:2222->10.0.0.6:49673 not hit

I'm wondering if in some case the IPVS stack is using the node with
inhibit_on_failure aka weight 0.

I'm available to do more testing or anything else that can help
troubleshoot this specific issue.

Regards,
Alexis Vachette.
