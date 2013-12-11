From: "Ryan O'Hara" <rohara@redhat.com>
Subject: Re: Configuring keepalived + ipvs with persistence: doesn't balance
 to other node if initial persistent node fails.
Date: Wed, 11 Dec 2013 10:11:07 -0600
Message-ID: <20131211161107.GB11973@redhat.com>
References: <CAO2+3OzZ-XK7X0vto7sgh4VULGT7FTep5ot_pqPqb1mB=gO6rQ@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAO2+3OzZ-XK7X0vto7sgh4VULGT7FTep5ot_pqPqb1mB=gO6rQ@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jose Luis Godoy <joseluis.gms@gmail.com>
Cc: lvs-devel@vger.kernel.org

On Wed, Dec 11, 2013 at 04:26:18PM +0100, Jose Luis Godoy wrote:
> Description of problem:
> 
> Configuring keepalived + ipvs with persistence: doesn't balance to
> other node if initial persistent node fails.


The problem is that your using "inhibit_on_failure" for quiescent
servers and persistence. To get the behavior your are expecting:

echo 1 > /proc/sys/net/ipv4/vs/expire_quiescent_template


Ryan

> Version-Release number of selected component (if applicable):
> 
> keepalived-1.2.9-1.fc19.x86_64
> ipvsadm-1.27-1.fc19.x86_64
> /lib/modules/3.11.9-200.fc19.x86_64/kernel/net/netfilter/ipvs/ip_vs.ko
> 
> How reproducible:
> Always.
> 
> Steps to Reproduce:
> 1. /etc/keepalived/keepalived.conf -> this is part of the configuration file:
> ...
> virtual_server 192.168.58.10 443 {
> delay_loop 5
> lb_algo rr
> lb_kind DR
> persistence_timeout 3600
> persistence_granularity 255.255.255.255
> protocol TCP
> 
> sorry_server 192.168.58.200 443
> 
> real_server 192.168.58.201 443 {
>     weight 1
>     inhibit_on_failure
>     TCP_CHECK {
>         connect_timeout 3
>         nb_get_retry 3
>         delay_before_retry 1
>     }
> }
> real_server 192.168.58.202 443 {
>     weight 1
>     inhibit_on_failure
>     TCP_CHECK {
>         connect_timeout 3
>         nb_get_retry 3
>         delay_before_retry 1
>     }
> }
> ...
> 
> 2. systemctl restart keepalived
> 
> # ipvsadm -L -n --persistent-conn
> 
> IP Virtual Server version 1.2.1 (size=4096)
> Prot LocalAddress:Port Weight PersistConn ActiveConn InActConn
> -> RemoteAddress:Port
> TCP 192.168.58.10:80 rr
> -> 192.168.58.201:80 1 0 0 0
> -> 192.168.58.202:80 1 0 0 0
> TCP 192.168.58.10:443 rr persistent 3600
> -> 192.168.58.201:443 1 0 0 0
> -> 192.168.58.202:443 1 0 0 0
> 
> 3. At first we connect to 192.168.58.10:443 four times from the same
> source address.
> 
> # ipvsadm -L -n --persistent-conn
> 
> IP Virtual Server version 1.2.1 (size=4096)
> Prot LocalAddress:Port Weight PersistConn ActiveConn InActConn
>   -> RemoteAddress:Port
> TCP 192.168.58.10:80 rr
>   -> 192.168.58.201:80 1 0 0 0
>   -> 192.168.58.202:80 1 0 0 0
> TCP 192.168.58.10:443 rr persistent 3600
>   -> 192.168.58.201:443 1 1 0 4
>   -> 192.168.58.202:443 1 0 0 0
> 
> 4. We stop the persistent node 192.168.58.201:
> 
> # ipvsadm -L -n --persistent-conn
> 
> IP Virtual Server version 1.2.1 (size=4096)
> Prot LocalAddress:Port Weight PersistConn ActiveConn InActConn
>   -> RemoteAddress:Port
> TCP 192.168.58.10:80 rr
>   -> 192.168.58.201:80 1 0 0 0
>   -> 192.168.58.202:80 1 0 0 0
> TCP 192.168.58.10:443 rr persistent 3600
>   -> 192.168.58.201:443 0 1 0 4
>   -> 192.168.58.202:443 1 0 0 0
> 
> 4. We connect again to 192.168.58.10:443 four times from the initial
> source address.
> 
> # ipvsadm -L -n --persistent-conn
> 
> IP Virtual Server version 1.2.1 (size=4096)
> Prot LocalAddress:Port Weight PersistConn ActiveConn InActConn
>   -> RemoteAddress:Port
> TCP 192.168.58.10:80 rr
>   -> 192.168.58.201:80 1 0 0 0
>   -> 192.168.58.202:80 1 0 0 0
> TCP 192.168.58.10:443 rr persistent 3600
>   -> 192.168.58.201:443 0 1 0 4
>   -> 192.168.58.202:443 1 0 0 0 <<<--- There aren't connections
> 
> Expected results:
> 
> IP Virtual Server version 1.2.1 (size=4096)
> Prot LocalAddress:Port Weight PersistConn ActiveConn InActConn
>   -> RemoteAddress:Port
> TCP 192.168.58.10:80 rr
>   -> 192.168.58.201:80 1 0 0 0
>   -> 192.168.58.202:80 1 0 0 0
> TCP 192.168.58.10:443 rr persistent 3600
>   -> 192.168.58.201:443 0 1 0 4
>   -> 192.168.58.202:443 1 0 0 4 <<<--- We must get four connections
> 
> Reference to bug in Fedora Project:
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=1040405
> 
> 
> Additional info:
> 
> The first node is stopped, IPVS doesn't balance to the other web
> server node 192.168.58.202:443 and waits 3600 seconds (in this case)
> to balance to it. We don't know te reason to do this, in our opinion
> it must balance to the other web server node, we think it could be a
> possible bug.
> 
> Can anyone explain this behaviour or is really it a bug?
> 
> Thanks!
> 
> Jose Luis
> --
> To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
