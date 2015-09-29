From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH] ipvs: fix possible use of uninitialized ipvs pointer
Date: Tue, 29 Sep 2015 16:11:01 -0300
Message-ID: <560AE245.4000109@gmail.com>
References: <9bdf4c6e4d9aa5728488f0682008feaf35e3e092.1443545522.git.marcelo.leitner@gmail.com>
 <alpine.LFD.2.11.1509292200300.1775@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=subject:to:references:cc:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-type:content-transfer-encoding;
        bh=rjn2fk8RJPZDSbqclYOmqkch4caJOYsgLA8AKP4+IAM=;
        b=ufgjiwMqP1DFGZqcBqp5EjrNChyzUzswm8vClVBYZMSnen2dy4WdZVjafqJ8LrRo+Q
         xWdWpTKUxUHrRhAugkpl7liKj8Omb1QthNxdJq4V0GDASJzt7qHGXBEBYNK6/MGLIepl
         pceTo6ZfWyPqU3dst9eicrW8vrAexsanEEzxkSgYOHp9l8h0tm9ke1qr2En/m/7JlAn9
         U6ZoGDGwhE4i3aQz1uP1gakXA9dkenMFlJC1jNPwLQm3hgc4J+r/AC5frEplDhcK0HQA
         rwovAqUSx6nPxqMvkweChUKL2BdtRkCoOetf+zg19Q27vmcpo3hMBHWDWMznOPozoUEd
         h8PA==
In-Reply-To: <alpine.LFD.2.11.1509292200300.1775@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, agartrell@fb.com

Em 29-09-2015 16:04, Julian Anastasov escreveu:
>
> 	Hello,
>
> On Tue, 29 Sep 2015, Marcelo Ricardo Leitner wrote:
>
>> 5e26b1b3abce[1] moved a derreference on ipvs on sysctl_sloppy_sctp(ipvs)
>> to before its initialization.
>>
>> Fix now is to just move ipvs initialization a bit upper.
>>
>> Fixes: 5e26b1b3abce ("ipvs: support scheduling inverse and icmp SCTP packets")
>> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
>
> 	This is already fixed in ipvs-next tree as part of the
> Eric W. Biederman's work:
>
> "ipvs: Hoist computation of ipvs earlier in sctp_conn_schedule"

Oh, right. Sorry the noise then. Thanks.

   Marcelo

