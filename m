From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: RE: Re: Fwd: LVS on local node
Date: Fri, 23 Jul 2010 07:24:10 +0800
Message-ID: <AANLkTinJW6ARfmvawUbCEEHmAQ9EtYVqmCpTBOxr8AdM@mail.gmail.com>
References: <20100723010102.121uPPJ1@mxfront8.mail.yandex.net> 
	<188211279834651@web111.yandex.ru>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:received:mime-version:received:in-reply-to
         :references:from:date:message-id:subject:to:cc:content-type
         :content-transfer-encoding;
        bh=L0lYaTHk5+s2TeSorG/E90qPmYRRFlXM0qlmjsyUWUE=;
        b=J/9vb+kZ552x8W7zUJgDoS57E2kWula+YPMbeWOyZecaksuDZ7e5DeSsAK7x4CrbRt
         Xs0D67KpuQLHQJB/sgSwJLm0dKBOYMn5pXmeOY3OCg59Y2yy/Hec9xRYoYQGZi0bzpZQ
         P8Kklwt7u7iHenWXR+uO7AiSr2h2NSjO0i+ko=
In-Reply-To: <188211279834651@web111.yandex.ru>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="windows-1252"
To: Franchoze Eric <franchoze@yandex.ru>
Cc: Graeme Fowler <graeme@graemef.net>, Eric Dumazet <eric.dumazet@gmail.com>, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org

On Fri, Jul 23, 2010 at 5:37 AM, Franchoze Eric <franchoze@yandex.ru> w=
rote:
>
>
> 23.07.10, 01:01, "Graeme Fowler" <graeme@graemef.net>:
>
>> Hi
>>
>> =9ATechnically keepalived is not LVS. It's a monitoring/mgmt app whi=
ch can manage an LVS according to health-check logic. LVS by itself can=
not "detect" any form of service failure - it's a fancy router with spe=
cial rules.
>>
>> =9AGraeme.
>>
>
> Ah, ok. Then with iptables I can write keepalived app to insert/remov=
e rules.
> Is there interface to iptables for dynamically turn on/off rules with=
out inserting and removing them from the table?

xt_condition is on its way to mainline. http://patchwork.ozlabs.org/pat=
ch/59578/


--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
