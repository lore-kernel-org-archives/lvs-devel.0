From: "rhadoo.io88" <rhadoo.io88@gmail.com>
Subject: Re: ovf scheduler
Date: Tue, 14 Jul 2015 01:47:16 +0300
Message-ID: <CAA0i4Bph-Gw00+-kUovvvfSgEta6XEH2-hGtSnusuPNdro2nCA@mail.gmail.com>
References: <CAA0i4Bp0n-PooNaUq=F7MgD2Ou8=hdA6w+B0te5tcWP4ODxTfw@mail.gmail.com>
	<alpine.LFD.2.11.1507132328500.1708@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:in-reply-to:references:date:message-id:subject:from:to
         :cc:content-type;
        bh=yldzyoDMHHzwBYdxnvxv+sC4ykMwfSCrmCT+OjBXxrw=;
        b=UjP5zsUCxK2xeueoKLtd7hFhEgOoYKIfIRsXVSiAuU2BquURDUmnKrFMTBJO1P15kG
         n4Fu1+3KWr4fv4wuMtthfxtGEo1yOOhbSjKsc9j552sVfXFvOLQggZfUoyK9K9A/owU9
         9MhfWGd9/BbTPtRVmMbaWwmqjPpGUrG97IEBLNxEPwNbT3BfBT1dgWVvSh8Zr3Ubn3cD
         /CCa7QXzQC6jYDoPTXTpenxOZTGxheNLmzh2mfHcLF7tNAg+TfrfU0ogNJxSI4xr1Qpg
         RvkuzUsQ09l6pFlxl2gzcj+wud3T80Ai/gKlpXssjIwYghmyuZGN2zMsy6/mMQzdWrLq
         3kFQ==
In-Reply-To: <alpine.LFD.2.11.1507132328500.1708@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

Unfortunately i was not aware of the FO scheduler, i looked it up just
now...indeed you could get similar behavior with FO scheduler and
proper thresholds.
The only trouble with that is that i can't set the thresholds from
within ldirectord , so i won't be able to keep all the config in one
place,  and that upper threshold seems to take into account all
connections ( active and inactive) , that making the upper limit a bit
vague.
i think this approach has the advantage of keeping all the config in
one place, having the weight set at the actual number of active
connections the node can handle whilst still allowing to have
thresholds on the total connections.

On Mon, Jul 13, 2015 at 11:35 PM, Julian Anastasov <ja@ssi.bg> wrote:
>
>         Hello,
>
> On Mon, 13 Jul 2015, rhadoo.io88 wrote:
>
>> Hi,
>> My name is Raducu Deaconu, i am a romanian syadmin/solution manager
>> and i have been working with lvs for some years now, great software!
>> I mainly use ldirectord on top of lvs and every now and then i do run
>> into customer tasks that would need new features.
>> One such feature is the need of a failover scheduler that would allow
>> a certain number of active connections to be served by a server and
>> only in case that is overloaded send some jobs to another/other
>> servers.
>> That would be needed say in the case you have let's say a galera
>> cluster and you want to make sure all writes go to one node, and only
>> one node,or in the case where you have some caching implemented in an
>> application and you want the virtual service to always go to that
>> server, unless there is a problem, case when another server can handle
>> the job, although without the caching.
>> These features are not possible now in ldirectord/lvs and i think they
>> would bring some benefits to many use cases like my own.
>
>         Can the same be achieved by setting --u-threshold
> and using the FO scheduler? ip_vs_bind_dest() sets the
> IP_VS_DEST_F_OVERLOAD flag if number of connections
> exceed upper threshold and then the FO scheduler can select
> another real server with lower weight.
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
