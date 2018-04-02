From: Vincent Bernat <vincent@bernat.im>
Subject: Re: [PATCH net-next v1] ipvs: add consistent source hashing scheduling
Date: Mon, 02 Apr 2018 19:57:12 +0200
Message-ID: <m3zi2lcwzr.fsf@luffy.cx>
References: <20180402172025.7380-1-vincent@bernat.im>
        <63c63fab-12ed-8b15-e00e-dc54e5c144eb@gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed; d=bernat.im; h=from:to:cc
        :subject:references:date:in-reply-to:message-id:mime-version
        :content-type; s=postfix; bh=hC6sEKuAf4oQA5sLhQnzzKMJgZw=; b=xpw
        X9j9a0mk6Y/+Ee2JfHh2Z1ddxiU6Q3De1//O1hP4AOnz+rjvmuuYLYLShh7gfM/H
        ig1pWjvlwdhJ36bkTVce828upON7ZxF+vNB2mZM8Oy3GscK6aJvfj72pb2EeLq/E
        7VlqAM0g2oGlha3ATXGSe+m+tzbJCwWiAT9AhN+o=
In-Reply-To: <63c63fab-12ed-8b15-e00e-dc54e5c144eb@gmail.com> (Eric Dumazet's
        message of "Mon, 2 Apr 2018 10:33:27 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org

 =E2=9D=A6  2 avril 2018 10:33 -0700, Eric Dumazet <eric.dumazet@gmail.com>=
=C2=A0:

>> +static inline u32
>> +ip_vs_csh_permutation(struct ip_vs_dest *d, int j)
>> +{
>> +	u32 offset, skip;
>> +	__be32 addr_fold =3D d->addr.ip;
>> +
>> +#ifdef CONFIG_IP_VS_IPV6
>> +	if (d->af =3D=3D AF_INET6)
>> +		addr_fold =3D d->addr.ip6[0]^d->addr.ip6[1]^
>> +			d->addr.ip6[2]^d->addr.ip6[3];
>> +#endif
>> +	addr_fold =3D ntohl(addr_fold) + ntohs(d->port);
>> +	offset =3D hash_32(addr_fold, 32) % IP_VS_CSH_TAB_SIZE;
>> +	skip =3D (hash_32(addr_fold + 1, 32) % (IP_VS_CSH_TAB_SIZE - 1)) + 1;
>> +	return (offset + j * skip) % IP_VS_CSH_TAB_SIZE;
>> +}
>> +
>
> This does not look very strong to me, particularly the IPv6 folding
>
> I would rather use __ipv6_addr_jhash() instead of ipv6_addr_hash(),
> even if it is hard coded ;)

I can switch to ipv6_addr_hash(). However, switching to
__ipv6_addr_jhash seems useless as I would need to hardcode the initial
value: people use source hashing to get the same result from one host to
another. Am I missing something?
--=20
Each module should do one thing well.
            - The Elements of Programming Style (Kernighan & Plauger)
