From: Mike Maxim <mike@okcupid.com>
Subject: Re: [PATCH] IPVS: Modify the SH scheduler to use weights
Date: Thu, 8 Dec 2011 10:50:54 -0500
Message-ID: <CAOgH2dsd1Nsk-yAtcLJXKNcum4xF8onwHjN+kPWMS92ts0Fvfw@mail.gmail.com>
References: <1323245223-13646-1-git-send-email-horms@verge.net.au>
	<1323245223-13646-2-git-send-email-horms@verge.net.au>
	<20111207113038.GA18166@1984>
	<CAOgH2dsHepr7Dyx7pNOutFNRh5SoO-oC9mx1MLm6Ncai8Ma3rQ@mail.gmail.com>
	<20111208004008.GD4586@verge.net.au>
	<20111208011108.GL4586@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20111208011108.GL4586@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

No problem, I'll send out the new patch now. Thanks!

On Wed, Dec 7, 2011 at 8:11 PM, Simon Horman <horms@verge.net.au> wrote=
:
> On Thu, Dec 08, 2011 at 09:40:09AM +0900, Simon Horman wrote:
>> On Wed, Dec 07, 2011 at 10:24:09AM -0500, Mike Maxim wrote:
>> > The reason I put that in is because the size of that table becomes
>> > more relevant/important if you decide to use the weights in the ma=
nner
>> > the patch lets you. It would be conceivable that someone might nee=
d to
>> > increase the size of that table to accommodate their configuration=
, so
>> > I thought it would be handy to be able to do that through the regu=
lar
>> > configuration system instead of editing the source.
>>
>> Hi Mike,
>>
>> I agree, but I think its also reasonable to consider IP_VS_SH_TAB_BI=
TS as
>> a separate change.
>>
>> Could you
>>
>> 1. Split the patch into a Kconfig patch and a ip_vs_sh.c patch
>> 2. Remove spurious line additions from the resulting patches?
>
> Scratch that, please follow Pablo's request.
> --
> To unsubscribe from this list: send the line "unsubscribe lvs-devel" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
