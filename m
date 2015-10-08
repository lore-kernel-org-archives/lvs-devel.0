From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 00/16] net: Pass net through the output path v2
Date: Thu, 8 Oct 2015 11:40:30 +0200
Message-ID: <56163A0E.4050701@6wind.com>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
 <87pp1fpy1b.fsf@x220.int.ebiederm.org>
 <87fv2bo7br.fsf_-_@x220.int.ebiederm.org>
 <87si62gteh.fsf_-_@x220.int.ebiederm.org>
 <877fn7eh2f.fsf_-_@x220.int.ebiederm.org>
 <878u7fesrg.fsf_-_@x220.int.ebiederm.org>
 <87bnca4aie.fsf_-_@x220.int.ebiederm.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <87bnca4aie.fsf_-_@x220.int.ebiederm.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"; format="flowed"
To: "Eric W. Biederman" <ebiederm@xmission.com>, David Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org

Le 07/10/2015 23:46, Eric W. Biederman a =C3=A9crit :
>
> This is the next installment of my work to pass struct net through th=
e
> output path so the code does not need to guess how to figure out whic=
h
> network namespace it is in, and ultimately routes can have output
> devices in another network namespace.
>
> The first patch in this series is a fix for a bug that came in when s=
k
> was passed through the functions in the output path, and as such is
> probably a candidate for net.  At the same time my later patches depe=
nd
> on it so sending the fix separately would be confusing.
>
> The second patch in this series is another fix that for an issue that
> came in when sk was passed through the output path.  I don't think it
> needs a backport as I don't think anyone uses the path where the code
> was incorrect.
>
> The rest of the patchset focuses on the path from xxx_local_out to
> dst_output and in the end succeeds in passing sock_net(sk) from the
> socket a packet locally originates on to the dst->output function.
LGTM.

Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
