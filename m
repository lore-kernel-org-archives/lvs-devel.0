From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: Re: [PATCH trivial 1/2] net: Fix Kconfig indentation
Date: Mon, 23 Sep 2019 19:56:12 +0200
Message-ID: <2354684.0ZvKvX0iQ3@sven-edge>
References: <20190923155243.6997-1-krzk@kernel.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart2306317.z6aVZVsvuq"; micalg="pgp-sha512"; protocol="application/pgp-signature"
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=narfation.org;
        s=20121; t=1569259611;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=JUegENmeIHHiT+O9uIIOxc1zWJHPwvIxI2SvuwGf54A=;
        b=dVWTU2YRhbvNTjzU5zWqJuZwGuXdr2Y5i4h8fAIbmfcxuBJK1ZG+fGo/W/YblVDINcKj0n
        B670FTOeqbkbbqdtvLu3HbF2eoleJzXw6Dgnm1/VfifonzNleM7VytHWdyYL6G301L3qIC
        tdTHwh8/l2Z9JQUVmzRFgWWvKZS3wUo=
In-Reply-To: <20190923155243.6997-1-krzk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-ID: <lvs-devel.vger.kernel.org>
To: b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Cc: Krzysztof Kozlowski <krzk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Michael Grzeschik <m.grzeschik-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>, Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Heiner Kallweit <hkallweit1-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>, Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>, Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>, Jozsef Kadlecsik <kadlec-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>, Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>, Jiri Kosina <trivial-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, lvs-dev

--nextPart2306317.z6aVZVsvuq
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Monday, 23 September 2019 17:52:42 CEST Krzysztof Kozlowski wrote:
> --- a/net/batman-adv/Kconfig
> +++ b/net/batman-adv/Kconfig
> @@ -12,11 +12,11 @@ config BATMAN_ADV
>         depends on NET
>         select LIBCRC32C
>         help
> -          B.A.T.M.A.N. (better approach to mobile ad-hoc networking) is
> -          a routing protocol for multi-hop ad-hoc mesh networks. The
> -          networks may be wired or wireless. See
> -          https://www.open-mesh.org/ for more information and user space
> -          tools.
> +         B.A.T.M.A.N. (better approach to mobile ad-hoc networking) is
> +         a routing protocol for multi-hop ad-hoc mesh networks. The
> +         networks may be wired or wireless. See
> +         https://www.open-mesh.org/ for more information and user space
> +         tools.
>  
>  config BATMAN_ADV_BATMAN_V
>         bool "B.A.T.M.A.N. V protocol"

Acked-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>

Kind regards,
	Sven

--nextPart2306317.z6aVZVsvuq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEF10rh2Elc9zjMuACXYcKB8Eme0YFAl2JBzwACgkQXYcKB8Em
e0YTVg/+PgtfvbyO8UPeEG3nkvaRcMywQsGWWB2nkRfHXA+QnFghJNXsvPHonkd+
QQ1E5I3loiK90VFbdRR8R0o5G57WPTFAivY334UAL1m5qOZT1bMKwI971dT0GCny
a9+BhZEjt729e7WlSOvkT/v7BHo8lxyHH5+x33dxMJF0oSD5UDdH8VZX9PCBTJ1g
4+O3e18WyQdsXFi3G2N75DcT+OhRle2P7T6yfgD0Ro5ViMqeTigsdmw+kpq8x8IK
fyUN3oo5vqFnH3sEEXFshmxAqAVjPjzzoRYTFTupTw8yDOTL2REIgU75HZ0WP2w6
eQ03/+7hKhujukr4V/bwVPMf6WJ1mi9+cz88Op8BkY/UgFgAYJSUhnfeoLo1pK6q
ewEwagQfFibXUqtebAoam3z20Mb7rnrUmQJbUvPLQatL76qUaonJp3yxUMnrOWo+
GmDWR4zgHgwatjOBeGCPBuF3PBMPWe1NBrA0EF7+33gZu6pttf3Z6XLNUWCw3unx
xQCR1dn7VzUA+/FdFZfVoUlGBPeqWzqdyp3Os2ymDHJRp6jZWTd2gX6KvldvWTDR
dU2SmyvoOovNLFWyBd7rC7vud0aWMJUHypD2IlEMCPprnu+m33Lhqx8nrbF/goZL
drH0F1BJDs5jlWehfTwnnaNdqZEuzamWT8GEJAUBj8Iq5R6+35s=
=OS2O
-----END PGP SIGNATURE-----

--nextPart2306317.z6aVZVsvuq--



