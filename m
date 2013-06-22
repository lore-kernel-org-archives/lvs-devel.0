From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: add sync_persist_mode flag
Date: Sat, 22 Jun 2013 15:43:26 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1306221510100.1577@ja.ssi.bg>
References: <20130524120935.GL264@eldamar.org.uk> <alpine.LFD.2.00.1305241633430.1636@ja.ssi.bg> <20130524151408.GM264@eldamar.org.uk> <519F92EB.4080509@gmail.com> <alpine.LFD.2.00.1305280011490.1728@ja.ssi.bg> <51A4B3ED.4070809@gmail.com>
 <alpine.LFD.2.00.1306191153590.2077@ja.ssi.bg> <51C5887A.1070301@gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <51C5887A.1070301@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Aleksey Chudov <aleksey.chudov@gmail.com>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Sat, 22 Jun 2013, Aleksey Chudov wrote:

> > From: Julian Anastasov <ja@ssi.bg>
> > [PATCH] ipvs: add sync_persist_mode flag
> > 
> > Add sync_persist_mode flag to reduce sync traffic
> > by syncing only persistent templates.
> > 
> > 
> 
> I tested the changes on one pair of LAN servers. After turning on
> sync_persist_mode synchronization traffic decreased by 4 times! Also on LVS
> Backup I can see only persist connections.

	Thanks! Can we assume that you have small number
of connections from every client? 1-2 per IP? Or a small
sync_refresh_period value is used? Can you show all these
sync* sysctl parameters that were used?

> First of all the Kernel on both servers have been updated. Then LVS Backup has
> been rebooted to drop all connections. After the reboot sync was disabled and
> all connections counters was zero. When I enabled sync again almost all
> persist connections from LVS Master have been synced to LVS Backup. But also I
> can see 0.04% of the connections in ESTABLISHED state, although they should
> not be there! After disabling sync all connections on LVS Backup completely
> disappear after about 5 minutes.

	Is it possible some of your services to be with
persistence disabled? Because the sync_persist_mode=1 mode
will not affect non-persistent services - their synchronisation
should work as before.

	You can also try to grep for such established conns:

# Find such ESTABLISHED conns
grep ESTAB ip_vs_conn

# and see what kind of conns we have from such client IPs, do
# we have persistence templates, etc.
grep client_ip ip_vs_conn

> After turning on sloppy_tcp IP address have been moved from LVS Master to LVS
> Backup. According to our statistics, most on clients remained on the same real
> servers. I don't see any problems with sloppy_tcp.

	So, at least sloppy_tcp appears to work :)

Regards

--
Julian Anastasov <ja@ssi.bg>
