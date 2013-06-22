From: Aleksey Chudov <aleksey.chudov@gmail.com>
Subject: Re: [PATCH] ipvs: add sync_persist_mode flag
Date: Sun, 23 Jun 2013 00:11:14 +0300
Message-ID: <51C612F2.6080500@gmail.com>
References: <20130524120935.GL264@eldamar.org.uk> <alpine.LFD.2.00.1305241633430.1636@ja.ssi.bg> <20130524151408.GM264@eldamar.org.uk> <519F92EB.4080509@gmail.com> <alpine.LFD.2.00.1305280011490.1728@ja.ssi.bg> <51A4B3ED.4070809@gmail.com> <alpine.LFD.2.00.1306191153590.2077@ja.ssi.bg> <51C5887A.1070301@gmail.com> <alpine.LFD.2.00.1306221510100.1577@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=message-id:date:from:user-agent:mime-version:to:cc:subject
         :references:in-reply-to:content-type:content-transfer-encoding;
        bh=h1JIhs4mLlAHuqquJdoZQmrMouH9yTKimV5D1p8dwDQ=;
        b=kYLLu3PwLgt8L1pC/CfGMoJnQeqRHeL4PweEcBRsU6wZXsgUO+gSpLYic1bCRkBx46
         kK68zO1NfsKXNmWoFZezar3K25SL9ejyb+sDwita7AzoN+JCieV5aUzgYPsSr0UofEzn
         kUIM1m3ev1nfGf5RUZK9Z8MgQGH3iHDirsAZvn829SZN/TkYy//tV5j42emMAzy5/xj8
         oLtb1HXQ0BRpouIm811M9GEXoolHYtUJsxJN94PmBZgnimX+iePTuDfA1C9m/4pmmqAj
         DMbsp8PPRxAXA1m7G2lw+0gJztS33Qe/FzBUu55Mkgx/rB6c4540PUtnD4AvPLfxzynY
         TvAA==
In-Reply-To: <alpine.LFD.2.00.1306221510100.1577@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

Hello,

On 22.06.2013 15:43, Julian Anastasov wrote:
>
>> I tested the changes on one pair of LAN servers. After turning on
>> sync_persist_mode synchronization traffic decreased by 4 times! Also on LVS
>> Backup I can see only persist connections.
> 	Thanks! Can we assume that you have small number
> of connections from every client? 1-2 per IP? Or a small
> sync_refresh_period value is used? Can you show all these
> sync* sysctl parameters that were used?

Each client opens about 3 connections.

Below is all ipvs sysctl parameters

# sysctl -a | grep net\.ipv4\.vs\.
net.ipv4.vs.amemthresh = 1048576
net.ipv4.vs.am_droprate = 10
net.ipv4.vs.drop_entry = 1
net.ipv4.vs.drop_packet = 0
net.ipv4.vs.conntrack = 0
net.ipv4.vs.secure_tcp = 1
net.ipv4.vs.snat_reroute = 1
net.ipv4.vs.sync_version = 1
net.ipv4.vs.sync_ports = 16
net.ipv4.vs.sync_persist_mode = 1
net.ipv4.vs.cache_bypass = 0
net.ipv4.vs.expire_nodest_conn = 1
net.ipv4.vs.sloppy_tcp = 1
net.ipv4.vs.sloppy_sctp = 0
net.ipv4.vs.expire_quiescent_template = 1
net.ipv4.vs.sync_threshold = 0  0
net.ipv4.vs.sync_refresh_period = 200
net.ipv4.vs.sync_retries = 0
net.ipv4.vs.nat_icmp_send = 0
net.ipv4.vs.lblc_expiration = 86400
net.ipv4.vs.lblcr_expiration = 86400


>> First of all the Kernel on both servers have been updated. Then LVS Backup has
>> been rebooted to drop all connections. After the reboot sync was disabled and
>> all connections counters was zero. When I enabled sync again almost all
>> persist connections from LVS Master have been synced to LVS Backup. But also I
>> can see 0.04% of the connections in ESTABLISHED state, although they should
>> not be there! After disabling sync all connections on LVS Backup completely
>> disappear after about 5 minutes.
> 	Is it possible some of your services to be with
> persistence disabled? Because the sync_persist_mode=1 mode
> will not affect non-persistent services - their synchronisation
> should work as before.

There is only one service on this pair of LVS servers:
ipvsadm -A -f 1 -s wlc -p 300

May be some connection on LVS Master erroneously considered non-persistent?

> 	You can also try to grep for such established conns:
>
> # Find such ESTABLISHED conns
> grep ESTAB ip_vs_conn
>
> # and see what kind of conns we have from such client IPs, do
> # we have persistence templates, etc.
> grep client_ip ip_vs_conn

For most ESTABLISHED conn on LVS Backup there is also persistence 
templates on both LVS Backup and LVS Master.


On 22.06.2013 15:53, Julian Anastasov wrote:
>
> 	I checked this file, there are 50 EST conns to
> X.X.X.X, is it the same VIP that is part of persistent
> services? All these conns are at their end of life, so
> may be in the last 15mins there were more like them?
>

Yes. There is only one service. And there is always about 50 - 70 
ESTABLISHED conns on LVS Backup. This should not create any problems. 
Just do not understand where they came from.

It looks like "end of life" conns because of reduced default tcp timeout.

# ipvsadm -l --timeout
Timeout (tcp tcpfin udp): 150 60 300


Aleksey
