From: "Julius Volz" <juliusv@google.com>
Subject: Re: [patch] ipvsadm: use strtoul to convert ip addresses from hex
Date: Wed, 20 Aug 2008 12:30:41 +0200
Message-ID: <f4845fc0808200330lc1cad87ya94eb73da9b4c175@mail.gmail.com>
References: <20080820054415.GA31393@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1219228244; bh=AScfRHnFfeo2f14iixACIompQIk=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=hI4zXlqGrGZFTRH06H3bPhZqRbGTAX7T
	Z5wqiWKIWfJuw0kqEmELz9KFHd6fELacWCnEdfJbblNw2xOu+hbigQ==
In-Reply-To: <20080820054415.GA31393@verge.net.au>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: Vince Busam <vbusam@google.com>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, wensong@linux-vs.org

On Wed, Aug 20, 2008 at 7:44 AM, Simon Horman <horms@verge.net.au> wrote:
> The ip addresses that come out of /proc/net/ip_vs_conn as integers
> are in hex not decimal.
>
> Without this change most IP addresses reported as integers end up being
> 0.0.0.0.
>
> This change is against the development code ipvsadm-1.25-nl-4 from
> http://sixpak.org/vince/google/ipvsadm/ . It is not relevant to
> ipvsadm-1.24, the current released version.
>
> Signed-off-by: Simon Horman <horms@verge.net.au>
>
> Index: ipvsadm-1.25-nl-4/ipvsadm.c
> ===================================================================
> --- ipvsadm-1.25-nl-4.orig/ipvsadm.c    2008-08-20 15:16:18.000000000 +1000
> +++ ipvsadm-1.25-nl-4/ipvsadm.c 2008-08-20 15:16:39.000000000 +1000
> @@ -1212,9 +1212,9 @@ static void print_conn(char *buf, unsign
>                inet_pton(AF_INET, temp2, &vaddr.ip);
>                inet_pton(AF_INET, temp3, &daddr.ip);
>        } else {
> -               caddr.ip = (__u32) htonl(atoi(temp1));
> -               vaddr.ip = (__u32) htonl(atoi(temp2));
> -               daddr.ip = (__u32) htonl(atoi(temp3));
> +               caddr.ip = (__u32) htonl(strtoul(temp1, NULL, 16));
> +               vaddr.ip = (__u32) htonl(strtoul(temp2, NULL, 16));
> +               daddr.ip = (__u32) htonl(strtoul(temp3, NULL, 16));
>        }
>
>        if (!(cname = addrport_to_anyname(af, &caddr, cport, proto, format)))

Thanks for this fix! I'm sure Vince will release a new version with
this once there is sunlight in his timezone :)

Do you think it'll make sense to host the new ipvsadm on
linuxvirtualserver.org (marked as experimental, of course) when the
Netlink patches go in? This seems more open than hosting it on our
private servers...

Julius

-- 
Google Switzerland GmbH
