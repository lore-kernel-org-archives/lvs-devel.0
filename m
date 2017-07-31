From: "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>
Subject: Re: [3.10.y,3.16.y,4.1.y,netfilter/ipvs] please, apply 3c5ab3f395d6
Date: Mon, 31 Jul 2017 13:22:03 +0000
Message-ID: <20170731132409.bnf7ai3ssvp4eaay@sasha-lappy>
References: <20170724095805.GA3807@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Return-path: <stable-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=verizon.com; i=@verizon.com; q=dns/txt; s=corp;
  t=1501507408; x=1533043408;
  h=from:to:cc:subject:date:message-id:references:
   in-reply-to:content-id:content-transfer-encoding:
   mime-version;
  bh=5NlMS04VrVw5SeaMVXhDJxymj73eXZPANB3RQyymB5I=;
  b=E0+g4+ueT85O6S9tL13CqUWfBsIIuUPRcpi3dOCgBx3+10zzmJqzV4/r
   /f8tbGTV20axe8z4DYxWfJBL/A5ytflRAO9+F3OaxOs4U6I04tkuJbCQh
   S5T7BLFQbDWi6Pv9ayf2u1QQcpGz14vZpjNtvnmf22cS0/nZwMz/0frH5
   s=;
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=verizon.com; i=@verizon.com; q=dns/txt; s=corp;
  t=1501507329; x=1533043329;
  h=from:to:cc:subject:date:message-id:references:
   in-reply-to:content-id:content-transfer-encoding:
   mime-version;
  bh=5NlMS04VrVw5SeaMVXhDJxymj73eXZPANB3RQyymB5I=;
  b=o2PTDM1AB4shA0jkkzvtAIu+ygKbqF6TiEC2pBHl/u6oFJ3OueVUgis1
   nDJ0pMZ59VckhsoB/jhrmGacYhg0bAmztBPlepMvoXclpAPISL9CsB5+2
   g/Z00865LPwGSviX+1usGhtxrX4e14Tt0fpwarRlpYm0j3gy5eVnrYwjx
   A=;
In-Reply-To: <20170724095805.GA3807@salvia>
Content-Language: en-US
Content-ID: <0E61505E43F92C48BBA62CC162BECF4B@vzwcorp.com>
Sender: stable-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Willy Tarreau <w@1wt.eu>, Ben Hutchings <ben@decadent.org.uk>, "stable@vger.kernel.org" <stable@vger.kernel.org>, Julian Anastasov <ja@ssi.bg>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, Simon Horman <horms@verge.net.au>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>

On Mon, Jul 24, 2017 at 11:58:05AM +0200, Pablo Neira Ayuso wrote:
>Hi Willy, Ben & Sasha,
>
>Please, apply this commit:
>
>commit 3c5ab3f395d66a9e4e937fcfdf6ebc63894f028b
>Author: Julian Anastasov <ja@ssi.bg>
>Date:   Sat Apr 29 20:33:09 2017 +0300
>
>    ipvs: SNAT packet replies only for NATed connections
>
>to stable 3.2.y.
>
>Julian made a backport for you, that is available at Netfilter's
>patchwork:
>
>        https://urldefense.proofpoint.com/v2/url?u=3Dhttp-3A__patchwork.oz=
labs.org_patch_789258_&d=3DDwIBAg&c=3DudBTRvFvXC5Dhqg7UHpJlPps3mZ3LRxpb6__0=
PomBTQ&r=3DbUtaaC9mlBij4OjEG_D-KMy3t3Ka3bY06suGz7ewY7g&m=3D8r6j7k5Ngp3u1KUX=
59uzAOt9dYNCQIS7iOZrIRS1icQ&s=3D7LrBh53VONaL-HCc-lGJeepxYWC4NG09UtvVSU8Fyrc=
&e=3D

Applied for 4.1, thanks!

--=20

Thanks,
Sasha=
