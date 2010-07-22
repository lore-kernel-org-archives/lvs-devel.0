From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: Fwd: LVS on local node
Date: Thu, 22 Jul 2010 17:52:35 +0800
Message-ID: <AANLkTimLZG_-4wbKy8nrajHVKQvvGtRKEd8qHNoU3swJ@mail.gmail.com>
References: <27901279770680@web67.yandex.ru> <1279781811.2405.15.camel@edumazet-laptop> 
	<AANLkTimneLE2xKg6fie5u3Cvjzcrq4VnK6wMT3pno0JK@mail.gmail.com> 
	<1279791964.2467.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:received:mime-version:received:in-reply-to
         :references:from:date:message-id:subject:to:cc:content-type
         :content-transfer-encoding;
        bh=UYltvXQebiQnyhWzlUjbrYlH3veHo3BG7mPr4wTupKk=;
        b=VkSKjXkklcYfDWn021HJCN3/yr8BaZ5tDoSyFfv3SQ0LxWkNCnRk6zCvXOljAdNGzg
         RbOJXWdmwDb7dcQLRE6rHNyPlKSWU87aD47mE05j8LamOzqm/t7FyHRy2X6IsXU9RL0c
         2GOGBerg0IXGqKdySL3mybOEQeKbVIs1bNFvA=
In-Reply-To: <1279791964.2467.12.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Patrick McHardy <kaber@trash.net>, Jan Engelhardt <jengelh@medozas.de>, Franchoze Eric <franchoze@yandex.ru>, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org

On Thu, Jul 22, 2010 at 5:46 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le jeudi 22 juillet 2010 =E0 17:10 +0800, Changli Gao a =E9crit :
>
>>
>> I think maybe REDIRECT is enough. If the public port is one of the
>> real ports, you need to append "random" option to iptables target
>> REDIRECT. If not, "REDIRECT --to-ports 1000-1007" is good enough, an=
d
>> the destination port will be selected in the round-robin manner.
>>
>
> Yes, on 2.6.32, no RPS, so undocumented --random option is probably t=
he
> best we can offer. (random option was added in 2.6.22)
>
> iptables -t nat -A PREROUTING -p tcp --dport 1234 -j REDIRECT --rando=
m --to-port 1000-1007
>
> Here is a patch to add "random" help to REDIRECT iptables target
>

=46YI: the random option is documented in the manual page of iptables.

   REDIRECT
       This  target is only valid in the nat table, in the PREROUTING a=
nd OUT-
       PUT chains, and user-defined chains which are only  called  from=
  those
       chains.   It redirects the packet to the machine itself by chang=
ing the
       destination IP  to  the  primary  address  of  the  incoming  in=
terface
       (locally-generated packets are mapped to the 127.0.0.1 address).

       --to-ports port[-port]
              This  specifies  a  destination  port  or range of ports =
to use:
              without this, the destination port is never  altered.   T=
his  is
              only valid if the rule also specifies -p tcp or -p udp.

       --random
              If  option --random is used then port mapping will be ran=
domized
              (kernel >=3D 2.6.22).


--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
