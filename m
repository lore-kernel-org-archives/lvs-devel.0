From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] ipvsadm: Enable to work display host name of IPv6
Date: Fri, 16 Jan 2015 11:30:35 +0100
Message-ID: <20150116113035.3b54bd32@redhat.com>
References: <54AF9439.8040409@lab.ntt.co.jp>
	<alpine.LFD.2.11.1501122159020.2636@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.11.1501122159020.2636@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Hibari Michiro <hibari.michiro@lab.ntt.co.jp>, lvs-devel@vger.kernel.org, brouer@redhat.com

On Mon, 12 Jan 2015 22:05:13 +0200 (EET)
Julian Anastasov <ja@ssi.bg> wrote:

> On Fri, 9 Jan 2015, Hibari Michiro wrote:
> 
> > So far ipvsadm can not display host name of IPv6.
> > This patch add process in the case of IPv6 for
> > addr_to_host function.
> > 
> > Signed-off-by: Michiro Hibari <hibari.michiro@lab.ntt.co.jp>
> 
> 	Looks good to me. Still, comment could be
> better. Jesper, please apply!

Thanks Hibari Michiro, applied.

But I updated the commit text, see:
 https://git.kernel.org/cgit/utils/kernel/ipvsadm/ipvsadm.git/commit/?id=a30224d4a04e63
 
> Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> 	One day we should convert it to getnameinfo()

Also added a note to the commit text about this future plan to use
getnameinfo().


> > diff --git a/ipvsadm.c b/ipvsadm.c
> > index 72ddc8a..162d4a2 100644
> > --- a/ipvsadm.c
> > +++ b/ipvsadm.c
> > @@ -1770,8 +1770,14 @@ static char * addr_to_host(int af, const void *addr)
> >  {
> >  	struct hostent *host;
> > -	if ((host = gethostbyaddr((char *) addr,
> > -				  sizeof(struct in_addr), af)) != NULL)
> > +	if (af == AF_INET)
> > +		host = gethostbyaddr((char *) addr,
> > +				     sizeof(struct in_addr), af);
> > +	else
> > +		host = gethostbyaddr((char *) addr,
> > +				     sizeof(struct in6_addr), af);
> > +
> > +	if (host != NULL)
> >  		return (char *) host->h_name;
> >  	else
> >  		return (char *) NULL;

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
