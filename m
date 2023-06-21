From: Dan Carpenter <dan.carpenter@linaro.org>
Subject: Re: [PATCH 06/11] sysctl: Add size to register_net_sysctl function
Date: Wed, 21 Jun 2023 13:49:54 +0300
Message-ID: <f95b7489-8654-435c-bc74-da1eac479fba@kadam.mountain>
References: <20230621091000.424843-1-j.granados@samsung.com>
 <CGME20230621091022eucas1p1c097da50842b23e902e1a674e117e1aa@eucas1p1.samsung.com>
 <20230621091000.424843-7-j.granados@samsung.com>
 <dab06c20-f8b0-4e34-b885-f3537e442d54@kadam.mountain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="ZFMDZBc9cnLbyP1u"
Return-path: <netdev+bounces-12564-gl-netdev-2=m.gmane-mx.org@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linaro.org; s=google; t=1687344600; x=1689936600;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:from:to:cc:subject:date:message-id:reply-to;
        bh=fSRkwHLFq+2I9Xiyi/hU6wMpRwozZdsPaoeIOTE25yg=;
        b=AIsj2vEdz+Fc9Jy19U2Q4+7jk5CdnnBRAq8EU0/qgIBKasDy/i9F7ZXwuxvu/FIk+V
         e/sUJHlgDgR4Qx2Oh1t5R17vdDFqF/9Ly0AVSK9zUVBFtxeRPEJfGRY1Ks9BJsa7NWkf
         GXQKQBgxImLcLHozIYWaaIqJ2GrVDZ8vDZMAG4ZNWlYOBv1zbniTnw6kcMxllyCdLRPM
         ZQ4LPyPa8TOuuqU/g5NEtzVey08OWckHaORybMu3dXpLsx3EAMUOJp98YetCTODsSvBK
         UGnxHZVFuD2xpLdXg7xgTBB0HXflRT1SIPGFL3SgcodXnvQYRGYsUcq+78aAj0lpxCAJ
         /6yw==
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:netdev+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:netdev+unsubscribe@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <dab06c20-f8b0-4e34-b885-f3537e442d54@kadam.mountain>
To: Joel Granados <j.granados@samsung.com>
Cc: mcgrof@kernel.org, Jason Gunthorpe <jgg@ziepe.ca>, Leon Romanovsky <leon@kernel.org>, David Ahern <dsahern@kernel.org>, "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, Joerg Reuter <jreuter@yaina.de>, Ralf Baechle <ralf@linux-mips.org>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, Roopa Prabhu <roopa@nvidia.com>, Nikolay Aleksandrov <razor@blackwall.org>, Alexander Aring <alex.aring@gmail.com>, Stefan Schmidt <stefan@datenfreihafen.org>, Miquel Raynal <miquel.raynal@bootlin.com>, Steffen Klassert <steffen.klassert@secunet.com>, Herbert Xu <herbert@gondor.apana.org.au>, Matthieu Baerts <matthieu.baerts@tessares.net>, Mat Martineau <martineau@kernel.org>, Simon Horman <horms@verge.net.au>, Julian


--ZFMDZBc9cnLbyP1u
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Jun 21, 2023 at 12:47:30PM +0300, Dan Carpenter wrote:
> The patchset doesn't include the actual interesting changes, just a
> bunch of mechanical prep work.
> 

I was wrong here, the patchset just hadn't all hit the mailing lists.
I can't apply this patchset to anything.  I tried linux-next, net, and
net-next.  So it's hard to review.

It looks like ensure_safe_net_sysctl() never got update to use
table_size...

You could easily write a static checker test to print a warning any time
that ->procname is checked for NULL.  I have attached a Smatch check.
You would need to added to check_list.h and recompile.

net/sysctl_net.c:130 ensure_safe_net_sysctl() warn: checking ->procname 'ent->procname'

regards,
dan carpenter


--ZFMDZBc9cnLbyP1u
Content-Type: text/x-csrc; charset=us-ascii
Content-Disposition: attachment; filename="check_checking_procname.c"

#include "smatch.h"
#include "smatch_slist.h"

static int my_id;

static void match_condition(struct expression *expr)
{
	char *member_name;

	if (expr->type == EXPR_COMPARE)
		return;

	member_name = get_member_name(expr);
	if (!member_name)
		return;

	if (strcmp(member_name, "(struct ctl_table)->procname") == 0)
		sm_warning("checking ->procname '%s'", expr_to_str(expr));
}

void check_checking_procname(int id)
{
	my_id = id;

	add_hook(&match_condition, CONDITION_HOOK);
}

--ZFMDZBc9cnLbyP1u--

