From: Julian Anastasov <ja@ssi.bg>
Subject: Re: ovf scheduler
Date: Mon, 13 Jul 2015 23:35:14 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1507132328500.1708@ja.home.ssi.bg>
References: <CAA0i4Bp0n-PooNaUq=F7MgD2Ou8=hdA6w+B0te5tcWP4ODxTfw@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <CAA0i4Bp0n-PooNaUq=F7MgD2Ou8=hdA6w+B0te5tcWP4ODxTfw@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "rhadoo.io88" <rhadoo.io88@gmail.com>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Mon, 13 Jul 2015, rhadoo.io88 wrote:

> Hi,
> My name is Raducu Deaconu, i am a romanian syadmin/solution manager
> and i have been working with lvs for some years now, great software!
> I mainly use ldirectord on top of lvs and every now and then i do run
> into customer tasks that would need new features.
> One such feature is the need of a failover scheduler that would allow
> a certain number of active connections to be served by a server and
> only in case that is overloaded send some jobs to another/other
> servers.
> That would be needed say in the case you have let's say a galera
> cluster and you want to make sure all writes go to one node, and only
> one node,or in the case where you have some caching implemented in an
> application and you want the virtual service to always go to that
> server, unless there is a problem, case when another server can handle
> the job, although without the caching.
> These features are not possible now in ldirectord/lvs and i think they
> would bring some benefits to many use cases like my own.

	Can the same be achieved by setting --u-threshold
and using the FO scheduler? ip_vs_bind_dest() sets the
IP_VS_DEST_F_OVERLOAD flag if number of connections
exceed upper threshold and then the FO scheduler can select
another real server with lower weight.

Regards

--
Julian Anastasov <ja@ssi.bg>
