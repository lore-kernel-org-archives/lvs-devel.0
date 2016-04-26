From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 9/9] wireless: use nla_put_u64_64bit()
Date: Tue, 26 Apr 2016 09:51:31 +0200
Message-ID: <571F1E03.90703@6wind.com>
References: <1461572722-6029-1-git-send-email-nicolas.dichtel@6wind.com>
 <1461572722-6029-10-git-send-email-nicolas.dichtel@6wind.com>
 <1461656345.16188.6.camel@sipsolutions.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=6wind-com.20150623.gappssmtp.com; s=20150623;
        h=reply-to:subject:references:to:cc:from:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding;
        bh=L4uXVwiXR7Dube1h7tYKSJzjKieKeSUeYKQEQIjPEyY=;
        b=1f1K7xznXii7YHf/Hjc/S99oT5e71KKfAxzK6oDuLYWtFjdL/9/Sh8YLyAO2AbTFeU
         3VpPq+XKfzarUn88NKXJuO8s3p/XD05u/H9pYCwRrhmok6GUALLtpINcXBS1vv/RmW76
         rVazaYgs3h2LFGfmLvOywveEc6sH61kf6XHbRAut00zIAsauQmUD9rAC8PEL/nJcT4jn
         VH40HuCy7waL9nVELez/+jfqYtoSTQWQZol4F2FR3mNiSiIgsCRV7FB9zkFWtmK2Z7L5
         ZGV9BmkXqWWmSehXUY6wMslhqZTVU4+9CKeYZpIkjjAiB+plsXsVfmN5YfexhIwfEH0w
         I6aw==
In-Reply-To: <1461656345.16188.6.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Johannes Berg <johannes@sipsolutions.net>, netdev@vger.kernel.org
Cc: davem@davemloft.net, jhs@mojatatu.com, stephen@networkplumber.org, pshelar@nicira.com, aar@pengutronix.de, linux-wpan@vger.kernel.org, wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-wireless@vger.kernel.org

Hi Johannes,

Le 26/04/2016 09:39, Johannes Berg a =C3=A9crit :
> Hi Nicholas,
>=20
> Thanks for doing this.
>=20
> I'll also add a fix for the macro-generated nla_put_64() in
> nl80211_send_station(), unless there was a particular reason you didn=
't
> take that one?
>=20
> I suspect you just missed it while grepping, but wanted to ask.
Yes you're right. I missed it. Thank you for the check.

I will send the last patchset in some minutes.


Regards,
Nicolas
