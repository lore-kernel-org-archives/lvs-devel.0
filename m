From: Simon Horman <horms@verge.net.au>
Subject: Re: ldirectord: reaping defunct processes when fork=yes and
 checktimeout expires
Date: Wed, 22 Feb 2012 09:11:00 +0900
Message-ID: <20120222001100.GB7680@verge.net.au>
References: <20120222.000041.290567899.sohgo@sohgo.dyndns.org>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120222.000041.290567899.sohgo@sohgo.dyndns.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sohgo Takeuchi <sohgo@sohgo.dyndns.org>
Cc: lvs-devel@vger.kernel.org

On Wed, Feb 22, 2012 at 12:00:41AM +0900, Sohgo Takeuchi wrote:
> 
> Hi Simon,
> 
> I wrote a patch for ldirectord to fix an issue mentioned in the
> following thread.
> 
>     [lvs-users] defunct checkcommand processes w/ ldirectord
>     http://archive.linuxvirtualserver.org/html/lvs-users/2012-02/msg00018.html
> 
> The patch is attached in this E-mail. You can get it from my
> github's repository too.
> 
> https://github.com/sohgo/resource-agents/tree/reap-child-fork-yes
> 
> I would appreciate you checked and applied my patch to
> ldirectord when you had free time.

Thanks, I will get that pushed upstream.

> 
> Thank you.
> 
> 
> ---
>  ldirectord/ldirectord.in |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/ldirectord/ldirectord.in b/ldirectord/ldirectord.in
> index 646d687..ded1cb2 100644
> --- a/ldirectord/ldirectord.in
> +++ b/ldirectord/ldirectord.in
> @@ -2676,9 +2676,11 @@ sub run_child
>  		foreach my $r (@$real) {
>  			$0 = "ldirectord $virtual_id checking $$r{server}";
>  			_check_real($v, $r);
> +			check_signal();
>  		}
>  		$0 = "ldirectord $virtual_id";
>  		sleep $checkinterval;
> +		check_signal();
>  		ld_emailalert_resend();
>  	}
>  }
> -- 
> 1.7.0.4
> --
> To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
