From: "rhadoo.io88" <rhadoo.io88@gmail.com>
Subject: ovf scheduler
Date: Mon, 13 Jul 2015 22:45:22 +0300
Message-ID: <CAA0i4Bp0n-PooNaUq=F7MgD2Ou8=hdA6w+B0te5tcWP4ODxTfw@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:date:message-id:subject:from:to:content-type;
        bh=i4cD5f0uQTPJBdqdiyIjVBLovYpk8rMLw7N16/kCSMI=;
        b=PN3wS61UGTo9vEFEgA9jGrcdh2tQz3WLAuZMi4m3U+52+6R+eKJkH5ymJxJrVbwQTk
         vYXZZez+GiiQ6kUfoJ95Ar5CUWFsCW3YmE6HxLdpr96LWetb/dGuVKsj5OmHM5iZbqkp
         i8LMko4PaTKKT6zPxMem6mT3lhdNB8ufa9j7zeA1Y/O2hMeYghxzdYFWAYVsRpX7IcPx
         MPyhl1U2A/fT6YMVZBTpc5z18d8Xe3AGf9ZN2kiQ6lSxrdZFfALs0fY3TiNZmV1e3MIn
         YXjC/UXLFuWAeY34KS7ndZz0FiSIE+wa9OmKMpaofv/rwEOEna1shSv4I8n9fLi2oF8S
         iQmQ==
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org

Hi,
My name is Raducu Deaconu, i am a romanian syadmin/solution manager
and i have been working with lvs for some years now, great software!
I mainly use ldirectord on top of lvs and every now and then i do run
into customer tasks that would need new features.
One such feature is the need of a failover scheduler that would allow
a certain number of active connections to be served by a server and
only in case that is overloaded send some jobs to another/other
servers.
That would be needed say in the case you have let's say a galera
cluster and you want to make sure all writes go to one node, and only
one node,or in the case where you have some caching implemented in an
application and you want the virtual service to always go to that
server, unless there is a problem, case when another server can handle
the job, although without the caching.
These features are not possible now in ldirectord/lvs and i think they
would bring some benefits to many use cases like my own.
let me expose two cases:

1)galera cluster:
192.168.0.100:3306   ->192.168.0.1:3306 weight 500
                                   ->192.168.0.2:3306 weight 499
                                   ->192.168.0.3:3306 weight 498

this setup will allow all writes to go to the same node (w 500) and
thus maintain lowest  latency, while allowing failover to the next
(499) if the first fails.

2)application specific

192.168.0.100:8080  ->192.168.0.1:8080 weight 500
                                  ->192.168.0.2:8080 weight 499

192.168.0.101:8080  ->192.168.0.2:8080 weight 500
                                  ->192.168.0.1:8080 weight 499

in this setup all connections go to a preferred node and only go to
the other one if the node is overloaded.

this also allows to have a normal server and a fallback server that is
health checked in ldirectord (instead of using the fallback directive
which is not checked)


I made a small scheduler for this:


 cat ip_vs_ovf.c


/*
 * IPVS:        Overflow-Connection Scheduling module
 *
 * Authors:     Raducu Deaconu <rhadoo_io@yahoo.com>
 *
 *              This program is free software; you can redistribute it and/or
 *              modify it under the terms of the GNU General Public License
 *              as published by the Free Software Foundation; either version
 *              2 of the License, or (at your option) any later version.
 *
 * Scheduler implements "overflow" loadbalancing according to number
of active connections , will keep all conections to the node with the
highest weight
 * and overflow to the next node if the number of connections exceeds
the node's weight
 *
 */

#define KMSG_COMPONENT "IPVS"
#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt

#include <linux/module.h>
#include <linux/kernel.h>

#include <net/ip_vs.h>

/*
 *      OVF Connection scheduling
 */
static struct ip_vs_dest *
ip_vs_ovf_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
{
        struct ip_vs_dest *dest, *hw = NULL;
        unsigned int highestw = 0, curentw;

        IP_VS_DBG(6, "%s(): Scheduling...\n", __func__);

        /*
         *select the node with highest weight, go to next in line if
active connections exceed weight
         *
         */

        list_for_each_entry(dest, &svc->destinations, n_list) {
                if ((dest->flags & IP_VS_DEST_F_OVERLOAD) ||
(atomic_read(&dest->activeconns) > atomic_read(&dest->weight)) ||
                    atomic_read(&dest->weight) == 0)
                        continue;
                curentw = atomic_read(&dest->weight);
                if (!hw || curentw > highestw) {
                        hw = dest;
                        highestw = curentw;
                }
        }

        if (!hw)
                ip_vs_scheduler_err(svc, "no destination available");
        else
                IP_VS_DBG_BUF(6, "OVF: server %s:%u activeconns %d "
                              "inactconns %d\n",
                              IP_VS_DBG_ADDR(svc->af, &hw->addr),
                                ntohs(hw->port),
                              atomic_read(&hw->activeconns),
                              atomic_read(&hw->inactconns));

        return hw;
}


static struct ip_vs_scheduler ip_vs_ovf_scheduler = {
        .name =                 "ovf",
        .refcnt =               ATOMIC_INIT(0),
        .module =               THIS_MODULE,
        .n_list =               LIST_HEAD_INIT(ip_vs_ovf_scheduler.n_list),
        .schedule =             ip_vs_ovf_schedule,
};


static int __init ip_vs_ovf_init(void)
{
        return register_ip_vs_scheduler(&ip_vs_ovf_scheduler) ;
}

static void __exit ip_vs_ovf_cleanup(void)
{
        unregister_ip_vs_scheduler(&ip_vs_ovf_scheduler);
}

module_init(ip_vs_ovf_init);
module_exit(ip_vs_ovf_cleanup);
MODULE_LICENSE("GPL");




Hope this makes some sense and perhaps this can make it in ipvs modules,

Thank you
