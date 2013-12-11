From: Jose Luis Godoy <joseluis.gms@gmail.com>
Subject: Configuring keepalived + ipvs with persistence: doesn't balance to
 other node if initial persistent node fails.
Date: Wed, 11 Dec 2013 16:26:18 +0100
Message-ID: <CAO2+3OzZ-XK7X0vto7sgh4VULGT7FTep5ot_pqPqb1mB=gO6rQ@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:date:message-id:subject:from:to:content-type;
        bh=HqBFuL0+qBQXhiapphcP2PjF0ZX0EbVx8U/2feZ+Erg=;
        b=rSkQqO3eYPFZyO5rmBA6wRJNWJq7eM71MPC4M18brYeFuisZB4Z8vTmgywz0xosG8Y
         HA5NzkDkcVl7JTYyug5ntx5vgIqB1aGh4bZwNnVJx9IfJO9xaUZfBOAEPnDnGK2VaPVJ
         k8JcZoXsL8zLgGye45t1SjmxIzyIvmgl/tGn96/rf/rwMJ1SkFd7qgg9XfUR7hpE+Jn1
         hCWV/RckqXxOCPikdjwso8MB4AvrqDv+/SmXzmMw7F2g3dFGbdvsk0/MfC7VzjdoxZUo
         /4/pOZSXN6FhIML8lWmrzZVdPucKP8ILMWyjDT/vUsoyznM+dPK+tjncRIGdinWP1pPy
         DKNA==
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org

Description of problem:

Configuring keepalived + ipvs with persistence: doesn't balance to
other node if initial persistent node fails.

Version-Release number of selected component (if applicable):

keepalived-1.2.9-1.fc19.x86_64
ipvsadm-1.27-1.fc19.x86_64
/lib/modules/3.11.9-200.fc19.x86_64/kernel/net/netfilter/ipvs/ip_vs.ko

How reproducible:
Always.

Steps to Reproduce:
1. /etc/keepalived/keepalived.conf -> this is part of the configuration file:
...
virtual_server 192.168.58.10 443 {
delay_loop 5
lb_algo rr
lb_kind DR
persistence_timeout 3600
persistence_granularity 255.255.255.255
protocol TCP

sorry_server 192.168.58.200 443

real_server 192.168.58.201 443 {
    weight 1
    inhibit_on_failure
    TCP_CHECK {
        connect_timeout 3
        nb_get_retry 3
        delay_before_retry 1
    }
}
real_server 192.168.58.202 443 {
    weight 1
    inhibit_on_failure
    TCP_CHECK {
        connect_timeout 3
        nb_get_retry 3
        delay_before_retry 1
    }
}
...

2. systemctl restart keepalived

# ipvsadm -L -n --persistent-conn

IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Weight PersistConn ActiveConn InActConn
-> RemoteAddress:Port
TCP 192.168.58.10:80 rr
-> 192.168.58.201:80 1 0 0 0
-> 192.168.58.202:80 1 0 0 0
TCP 192.168.58.10:443 rr persistent 3600
-> 192.168.58.201:443 1 0 0 0
-> 192.168.58.202:443 1 0 0 0

3. At first we connect to 192.168.58.10:443 four times from the same
source address.

# ipvsadm -L -n --persistent-conn

IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Weight PersistConn ActiveConn InActConn
  -> RemoteAddress:Port
TCP 192.168.58.10:80 rr
  -> 192.168.58.201:80 1 0 0 0
  -> 192.168.58.202:80 1 0 0 0
TCP 192.168.58.10:443 rr persistent 3600
  -> 192.168.58.201:443 1 1 0 4
  -> 192.168.58.202:443 1 0 0 0

4. We stop the persistent node 192.168.58.201:

# ipvsadm -L -n --persistent-conn

IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Weight PersistConn ActiveConn InActConn
  -> RemoteAddress:Port
TCP 192.168.58.10:80 rr
  -> 192.168.58.201:80 1 0 0 0
  -> 192.168.58.202:80 1 0 0 0
TCP 192.168.58.10:443 rr persistent 3600
  -> 192.168.58.201:443 0 1 0 4
  -> 192.168.58.202:443 1 0 0 0

4. We connect again to 192.168.58.10:443 four times from the initial
source address.

# ipvsadm -L -n --persistent-conn

IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Weight PersistConn ActiveConn InActConn
  -> RemoteAddress:Port
TCP 192.168.58.10:80 rr
  -> 192.168.58.201:80 1 0 0 0
  -> 192.168.58.202:80 1 0 0 0
TCP 192.168.58.10:443 rr persistent 3600
  -> 192.168.58.201:443 0 1 0 4
  -> 192.168.58.202:443 1 0 0 0 <<<--- There aren't connections

Expected results:

IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Weight PersistConn ActiveConn InActConn
  -> RemoteAddress:Port
TCP 192.168.58.10:80 rr
  -> 192.168.58.201:80 1 0 0 0
  -> 192.168.58.202:80 1 0 0 0
TCP 192.168.58.10:443 rr persistent 3600
  -> 192.168.58.201:443 0 1 0 4
  -> 192.168.58.202:443 1 0 0 4 <<<--- We must get four connections

Reference to bug in Fedora Project:

https://bugzilla.redhat.com/show_bug.cgi?id=1040405


Additional info:

The first node is stopped, IPVS doesn't balance to the other web
server node 192.168.58.202:443 and waits 3600 seconds (in this case)
to balance to it. We don't know te reason to do this, in our opinion
it must balance to the other web server node, we think it could be a
possible bug.

Can anyone explain this behaviour or is really it a bug?

Thanks!

Jose Luis
