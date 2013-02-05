From: Simon Horman <horms@verge.net.au>
Subject: Re: How does the mode fullnat work in detail and is implemented?
Date: Tue, 5 Feb 2013 10:44:35 +0900
Message-ID: <20130205014435.GA2394@verge.net.au>
References: <zarafa.510cd889.2056.2ff512266db7af11@zarafa.cubewerk.int>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <zarafa.510cd889.2056.2ff512266db7af11@zarafa.cubewerk.int>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Stefan Bauer <stefan.bauer@cubewerk.de>
Cc: "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>

On Sat, Feb 02, 2013 at 10:12:41AM +0100, Stefan Bauer wrote:
> Dear developers,
> 
> how does the mode fullnat work and how is it implemented?
> 
> I see there are patches at http://kb.linuxvirtualserver.org/images/a/a5/Lvs-fullnat-synproxy.tar.gz for the kernel.

I do not believe that is the code that was merged into the kernel.
Full-nat for IPVS was included in the 2.6.35 kernel and I do not
details of how to configure it have changed since.

> How is this mode triggered in userland? I see there are patches for
> ipvsadm as well. Additionally to this, do i have to set a SNAT-rule with
> iptables?
> 
> It would be nice to get some informations on this - there arent many
> informations out there about the deeper details.

My recollection is as follows:

FULL-NAT is implemented by using the existing LVS-NAT (DNAT) implementation
plus an IPVS helper module for iptables which allows it to handle SNAT
of connections which are handled by IPVS.

The code changes where:
* IPVS (kernel)
* New iptables IPVS module (kernel)
* New iptables IPVS module (user-space)

There is some description of how this may be configured at
http://old.nabble.com/-lvs-users---PATCH-v2-0-4--IPVS-full-NAT-support-%2B-netfilter-'ipvs'-match-support-tc25663214.html
and
http://blog.loadbalancer.org/enabling-snat-in-lvs-xt_ipvs-and-iptables/

I have cut and pasted a portion of the first link below:

% ipvsadm -A -t 192.168.100.30:80 -s rr 
% ipvsadm -a -t 192.168.100.30:80 -r 192.168.10.20:80 -m 
# ... 

# Source NAT for VIP 192.168.100.30:80 
% iptables -t nat -A POSTROUTING -m ipvs --vaddr 192.168.100.30/32 \
  --vport 80 -j SNAT --to-source 192.168.10.10

or SNAT-ing only a specific real server:

% iptables -t nat -A POSTROUTING --dst 192.168.11.20 \
  -m ipvs --vaddr 192.168.100.30/32 -j SNAT --to-source 192.168.10.10
