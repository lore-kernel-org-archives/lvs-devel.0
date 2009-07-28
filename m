From: Hannes Eder <heder@google.com>
Subject: Re: [RFC][PATCH 5/5] libxt_ipvs: user space lib for netfilter matcher 
	xt_ipvs
Date: Tue, 28 Jul 2009 14:34:26 +0200
Message-ID: <b5ddba180907280534l78eaf951j53048ebfbef4258c@mail.gmail.com>
References: <20090727134457.12897.272.stgit@jazzy.zrh.corp.google.com>
	 <20090727134852.13319.39035.stgit@jazzy.zrh.corp.google.com>
	 <alpine.LSU.2.00.0907272037500.20984@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1248784471; bh=XDhIJHsG/iijU6S25/xhaXRPNWk=;
	h=DomainKey-Signature:MIME-Version:In-Reply-To:References:Date:
	 Message-ID:Subject:From:To:Cc:Content-Type:
	 Content-Transfer-Encoding:X-System-Of-Record; b=CWfOxSCXupLD4fFtod
	Plih4G/ipw7P8LI51UEqa8kszOwbHEImWFcUCl/eV4m0nAnGQA1PAPkepQGfQxakDv9
	A==
In-Reply-To: <alpine.LSU.2.00.0907272037500.20984@fbirervta.pbzchgretzou.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Jan Engelhardt <jengelh@medozas.de>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Jul 27, 2009 at 20:40, Jan Engelhardt<jengelh@medozas.de> wrote=
:
>
> On Monday 2009-07-27 15:48, Hannes Eder wrote:
>>+
>>+ =A0 =A0 =A0switch (c) {
>>+ =A0 =A0 =A0case '0': /* --ipvs */
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Nothing to do here. */
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Then why add it?

In the 'default' branch is an assert(false);  Call it defensive program=
ming.

>>+ =A0 =A0 =A0char buf[BUFSIZ];
>>+
>>+ =A0 =A0 =A0if (family =3D=3D NFPROTO_IPV4) {
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!numeric && addr->ip =3D=3D 0) {
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printf("anywhere ");
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0if (numeric)
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0strcpy(buf, xtables_ipad=
dr_to_numeric(&addr->in));
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0else
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0strcpy(buf, xtables_ipad=
dr_to_anyname(&addr->in));
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0strcat(buf, xtables_ipmask_to_numeric(&m=
ask->in));
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0printf("%s ", buf);
>
> There is no need to use the strcpy/strcat hacks. Just directly printf=
 it.

As the comment says: "Shamelessly copied from libxt_conntrack.c". ;)

=46urthermore I think it is good that way, because
xtables_ipaddr_to_numeric writes to a local static buffer, and
xtables_ipaddr_to_numeric might get called by
xtables_ipmask_to_numeric.

>>--- /dev/null
>>+++ b/extensions/libxt_ipvs.man
>>@@ -0,0 +1,7 @@
>>+ipvs tests where the packet was modified by IPVS, i.e. is the
>>+skb_buff->ipvs_property set.
>>+.TP
>>+[\fB!\fP] \fB--ipvs
>>+Does the packet have to IPVS property?
>>+
>>+TODO: Write proper documentation.
>
> Yes.

Sir, yes, sir ;) I am working on that.

Thanks,
-Hannes
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
