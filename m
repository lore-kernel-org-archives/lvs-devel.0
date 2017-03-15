From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [PATCHv2 net-next 0/4] update ipvs sysctl document
Date: Wed, 15 Mar 2017 10:42:32 +0800
Message-ID: <CAPwn2JSnDdsR6sPSRT5YXtJB-Q3qubdtz_VY9wyUQvd9Zri-Lg@mail.gmail.com>
References: <1487313241-11361-1-git-send-email-liuhangbin@gmail.com>
 <1487579498-18967-1-git-send-email-liuhangbin@gmail.com> <alpine.LFD.2.11.1702212154590.1840@ja.home.ssi.bg>
 <20170313091430.GA17847@verge.net.au>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:in-reply-to:references:from:date:message-id:subject:to
         :cc;
        bh=N2NgefjAP+z/LS2CbGugy1ksDUPV7SBv5LBddpklVU4=;
        b=Xfr0OcavcmzYjUl9QpJWJ915N/Q+gpYbuJ4wxXZ4icjes7yATyn23wwrics2BZYvNV
         zmZQcnObfE3/PoJpFlEoAuifPwRqGb38c2BRaJIH8TWx7OU1NFSomY8D2lvCPdKOCAxa
         WKF0XukJqVbS2O6GAX4x9p5d6zPHkhh2+UodCHwEVHaDKaIDjk3EzMb1RT6DvxdXM1F+
         AJTUEh3D79SU1ftRvBLLGG+TcU8chARK1QK0MwQ+sCnxxLcl3TAUFdMbEfndBpRbIF1l
         /ssFxkMLvOkyvQnqwoUmCkARrmHKwWpRYD5cZH8WdXOjiGezvlrS4hasOz93ziPTjaNW
         7TFQ==
In-Reply-To: <20170313091430.GA17847@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org, network dev <netdev@vger.kernel.org>, Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

2017-03-13 17:14 GMT+08:00 Simon Horman <horms@verge.net.au>:
>> >
>> > Hangbin Liu (4):
>> >   ipvs: fix sync_threshold description and add sync_refresh_period, sync_retries
>> >   ipvs: Document sysctl sync_qlen_max and sync_sock_size
>> >   ipvs: Document sysctl sync_ports
>> >   ipvs: Document sysctl pmtu_disc
>>
>>       All patches look ok to me, thanks!
>>
>> Acked-by: Julian Anastasov <ja@ssi.bg>
>>
>>       Simon, can we keep this patchset while in merge window?
>
> Hi,
>
> I apologise for the extended delay in dealing with this - I have been ill.
>
> I have queued these up for v4.12 in ipvs-next as that seems to be the most
> appropriate course of action at this time. Please let me know if you'd like
> to explore a different approach.

Hi Simon,

Thanks a lot for taking care of this. I'm OK with the schedule.

Hope you can be well soon.

Best Wishes
Hangbin
