From: Julian Anastasov <ja@ssi.bg>
Subject: Re: netfilter: ipvs: using maglev scheduler algorithm
Date: Thu, 21 Oct 2021 21:47:33 +0300 (EEST)
Message-ID: <2bb21c12-d8fa-acf1-73f1-67a996e6b98@ssi.bg>
References: <CAP962rShHbVtXNONwRWda6xAZ_L8kVWTSNZc_bC=gCetUMpNHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="-1463811672-1216637008-1634842054=:8245"
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <CAP962rShHbVtXNONwRWda6xAZ_L8kVWTSNZc_bC=gCetUMpNHw@mail.gmail.com>
List-ID: <lvs-devel.vger.kernel.org>
To: Alexis Vachette <avachette@deezer.com>
Cc: lvs-devel@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-1216637008-1634842054=:8245
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit


	Hello,

On Thu, 21 Oct 2021, Alexis Vachette wrote:

> Hello everyone,
> 
> If this is not the correct list to address my issue feel free to tell me.
> 
> We are heavily using Netfilter/IPVS with maglev scheduler algorithm
> and it's working great on most use case.
> 
> The only case when we face issue is when inhibit_on_failure option is enabled.
> 
> Here is our setup:
> 
> - 2 LVS director in active/passive mode
> - 2 backend node
> 
> Exposed service is SSH using port 2222.
> 
> You can find below the LVS state when issue is occurring:
> 
> root@dev-lvstest-01 ~ ❱ ipvsadm -L -n
> IP Virtual Server version 1.2.1 (size=1048576)
> Prot LocalAddress:Port Scheduler Flags
>   -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
> TCP  172.16.42.170:2222 mh (mh-port)

	If inhibit_on_failure sets weight to 0 you may need
to add the mh-fallback scheduler flag to allow traffic to
use fallback server(s).

>   -> 172.16.42.168:2222            Route   100    0          0
>   -> 172.16.42.169:2222            Route   0      0          0
> 
> Here is a working example output:
> 
> root@dev-lvstest-01 ~ ❱ tail -f /var/log/kern.20211021 | grep "172.16.42.170"

...

> Oct 21 09:17:34 dev-lvstest-01 kernel: [   75.590633] IPVS: lookup
> service: fwm 0 TCP 172.16.42.170:2222 hit
> Oct 21 09:17:34 dev-lvstest-01 kernel: [   75.590637] IPVS: mh: TCP
> 172.16.42.170:2222 - no destination available

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-1216637008-1634842054=:8245--
