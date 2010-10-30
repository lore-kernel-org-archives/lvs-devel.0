From: Simon Horman <horms@verge.net.au>
Subject: Re: [v2 PATCH 3/4] IPVS: Backup, Adding Version 1 receive
 capability
Date: Sat, 30 Oct 2010 20:23:22 +0900
Message-ID: <20101030112322.GC28355@verge.net.au>
References: <1288354599-10919-3-git-send-email-hans.schillstrom@ericsson.com>
 <20101030064710.GJ26727@verge.net.au>
 <alpine.LFD.2.00.1010301338210.1610@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1010301338210.1610@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, lvs-devel@vger.kernel.org, wensong@linux-vs.org, daniel.lezcano@free.fr

On Sat, Oct 30, 2010 at 01:59:34PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Sat, 30 Oct 2010, Simon Horman wrote:
> 
> >I realise that the commenting syntax used throughout IPVS
> >is a) inconsistent and b) for the most part does not comply with
> >any variant of the style guidelines. However, for the record
> >I believe that the preferred commenting style for code in net/
> >and thus IPVS is:
> >
> >/* This is a one line comment */
> >
> >/* This is a
> >* multi-line comment
> >*/
> 
> 	Documentation/CodingStyle has rule for multi-line:
> 
> /*
>  * This is a
>  * multi-line comment
>  */

Right, but I believe that Dave Miller prefers the variant that I described.

> 
> >>+		ip_vs_conn_fill_param(af, sc->v6.protocol,
> >>+				   (const union nf_inet_addr *)&sc->v6.caddr,
> >>+				   sc->v6.cport,
> >>+				   (const union nf_inet_addr *)&sc->v6.vaddr,
> >>+				   sc->v6.vport, p);
> >
> >I'm ok with not aligning to the opening ( in order to avoid
> >going over 80 columns here. Though I suspect others would disagree.
> 
> 	Agreed, in such cases I prefer one tab after parent,
> especially, if there is no other code around and when not
> part of some complex 'if' expression.
> 
> 	I'm now sure Hans will read Documentation/CodingStyle again :)
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
> 
