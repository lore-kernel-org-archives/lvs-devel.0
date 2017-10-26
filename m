From: Ye Yin <hustcat@gmail.com>
Subject: Re: ipvs problem with container
Date: Thu, 26 Oct 2017 17:57:54 +0800
Message-ID: <CAK-cHay6Ttj8kwV-va6pyD3aChUyddmBzdsiTMDkNXVhZ7c0HA@mail.gmail.com>
References: <CAK-cHazJX03jwFkcfFz2Xtin82f3jhnvMVU_QdK+qeSXXVNWsw@mail.gmail.com>
 <alpine.LFD.2.20.1710252152520.1851@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:in-reply-to:references:from:date:message-id:subject:to
         :cc;
        bh=t56wvTr+ESLunEZqdso/YYpq1cyI4Q35TAZLE2BidsE=;
        b=STTbjRBYFet3cdLCbyLI4+OyYza2DieTci8lfFsoxUHygniRUyax3trEuNGuXieWM0
         a/Icdyq2hZbLxTotwoH32fYqe8rvT8Wc6YZmxP4Jx/GUOScxwbinD+G4UN15Zy2mZi/H
         vGvV209nl8ptAWYMoxM2mMKEy8gykXvriYSoxgnqxQPSSxNxvKZfDMV4qDVoVUqKCc2b
         CCi4Q00hK2wfenGJSbUzp4CbT+ro02V4S4lbX5r/R5l+xYrdl5+UVeNBUfh43FmTkTje
         amoEINGqvls/njGBWt5iiI0WocTEo78wGtTRQByM96qLgztqZRQ0RnSTOr9FAe4w5VmF
         lWoA==
In-Reply-To: <alpine.LFD.2.20.1710252152520.1851@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

Hi, Julian,

We have test and confirmed successful about your suggestion. Thanks very much.

And I have submited a patch , please see
https://www.mail-archive.com/netdev@vger.kernel.org/msg196160.html

Regards,
Ye

On Thu, Oct 26, 2017 at 3:01 AM, Julian Anastasov <ja@ssi.bg> wrote:
>
>         Hello,
>
> On Wed, 25 Oct 2017, Ye Yin wrote:
>
>> Hi, all,
>>
>> We run ipvs at host and container in the same host at the same time,
>> and ipvs at host will transport network traffic to ipvs in the
>> container. Then some problem happended to us, the detail is as
>> follows:
>>
>>
>>  ________________              _____________
>> |                       ___|___      |container1        |
>> | host bridge     |_vethA_|----|192.168.1.232  |
>> |192.168.1.193/26  |             |____________|
>> |                       ___|___        _____________
>> |                      |_vethB_|----|container2        |
>> |________________|            |192.168.1.233  |
>>                                             |_____________|
>>
>> container1 and container2 connected each other by bridge on the host,
>> which is the gateway of the two containers. Run ipvs on the host with
>> VIP 172.17.169.208.
>>
>> host:
>> $ ipvsadm -l -n
>> IP Virtual Server version 1.2.1 (size=4096)
>> Prot LocalAddress:Port Scheduler Flags
>>   -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
>> TCP  172.17.169.208:80 rr
>>   -> 192.168.1.233:80             Masq    1      0          0
>>
>> container2:
>> $ ipvsadm -l -n
>> IP Virtual Server version 1.2.1 (size=4096)
>> Prot LocalAddress:Port Scheduler Flags
>>   -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
>> TCP  192.168.1.233:80 rr
>>   -> 14.17.xx.yyy:80              Masq    0      0          0
>>
>> telnet from container1 to container2:
>>
>> access by ipvs at host will failed:
>>
>> $ telnet 172.17.169.208 80
>> Trying 172.17.169.208...
>> telnet: connect to address 172.17.169.208: Connection refused
>>
>> direct access ipvs in container will success:
>> $ telnet 192.168.1.233 80
>> Trying 192.168.1.233...
>> Connected to 192.168.1.233.
>> Escape character is '^]'.
>> ^]
>> telnet  quit
>> Connection closed.
>>
>>
>> I think it's  the ipvs_property flag make ipvs in container return
>> NF_ACCEPT for network traffic, which make traffic go up to tcp layer.
>> Please see ip_vs_in.
>>
>> We should clear this flag when SKB's netns has changed, Any idea?
>
>         Good idea. Are you able to test after adding such line to
> net/core/skbuff.c:skb_scrub_packet()?:
>
>         skb->ipvs_property = 0;
>
>         Just after nf_reset_trace(skb);
>
>         On success we should provide a patch instead that adds
> some ipvs_property_reset(skb) func in include/linux/skbuff.h that
> depends on the IS_ENABLED(CONFIG_IP_VS), just like it is done
> for nf_reset().
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
