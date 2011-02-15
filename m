From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch] ldirectord: add a support of "netmask" directive for
 IPv6
Date: Wed, 16 Feb 2011 07:47:22 +0900
Message-ID: <20110215224722.GA29263@verge.net.au>
References: <20110212.195904.39163868.sohgo@sohgo.dyndns.org>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110212.195904.39163868.sohgo@sohgo.dyndns.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sohgo Takeuchi <sohgo@sohgo.dyndns.org>
Cc: lvs-devel@vger.kernel.org

On Sat, Feb 12, 2011 at 07:59:04PM +0900, Sohgo Takeuchi wrote:
> 
> Hi
> 
> I have added a support of "netmask" directive for IPv6 to
> ldirectord.
> 
> Any comments are appreciated.

Hi Takeuchi-san,

this looks good to me, I've applied it to the agents tree.

> # HG changeset patch
> # User Sohgo Takeuchi <sohgo@sohgo.dyndns.org>
> # Date 1297506755 -32400
> # Node ID 8243bbc2ffa24847833c30248c5edf934f970cb2
> # Parent  b52fa171ccaeb9565ea4d96ea583a0a67c7122a7
> add a support of "netmask" directive for IPv6
> 
> diff --git a/ldirectord/ldirectord.in b/ldirectord/ldirectord.in
> --- a/ldirectord/ldirectord.in
> +++ b/ldirectord/ldirectord.in
> @@ -659,9 +659,11 @@
>  
>  Number of seconds for persistent client connections.
>  
> -B<netmask => I<w.x.y.z>
> +B<netmask => I<w.x.y.z> | I<prefixlen>
>  
>  Netmask to be used for granularity of persistent client connections.
> +IPv4 netmask should be specified in dotted quad notation.
> +IPv6 netmask should be specified as a prefix length between 1 and 128.
>  
>  B<protocol = tcp> | B<udp> | B<fwm>
>  
> @@ -1456,8 +1458,17 @@
>  					$1 =~ /(\d+)/ or &config_error($line, "invalid persistent timeout");
>  					$vsrv{persistent} = $1;
>  				} elsif ($rcmd =~ /^netmask\s*=\s*(.*)/) {
> -					$1 =~ /(\d+\.\d+\.\d+\.\d+)/ or &config_error($line, "invalid netmask");
> -					$vsrv{netmask} = $1;
> +					my $val = $1;
> +					if ($vsrv{addressfamily} == AF_INET6) {
> +						if ($val !~ /^\d+$/ or ($val < 1 || $val > 128)) {
> +							&config_error($line, "invalid netmask: a prefix length between 1 and 128 is required");
> +						}
> +					} else {
> +						if ($val !~ /^\d+\.\d+\.\d+\.\d+$/) {
> +							&config_error($line, "invalid netmask: dotted quad notation is required");
> +						}
> +					}
> +					$vsrv{netmask} = $val;
>  				} elsif ($rcmd =~ /^protocol\s*=\s*(.*)/) {
>  					if ( $1 =~ /(\w+)/ ) {
>  						if ( $vsrv{protocol} eq "fwm" ) {

