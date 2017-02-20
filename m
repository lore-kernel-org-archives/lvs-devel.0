From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [PATCH net 0/4] update ipvs sysctl document
Date: Mon, 20 Feb 2017 16:19:45 +0800
Message-ID: <CAPwn2JTc84Nw1GyEBbS97XBye0o1HbcwxBpLoVdwC1XSiWKwFw@mail.gmail.com>
References: <1487313241-11361-1-git-send-email-liuhangbin@gmail.com> <alpine.LFD.2.11.1702191552560.1590@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:in-reply-to:references:from:date:message-id:subject:to
         :cc;
        bh=PaRArrVlAfjXUKVISul71lemgKq1V3Abu650fx1GoGE=;
        b=WCrUOSGo1+rY7zBU+YsFG0KQzn5inE2eNyXQvoVzUsPK44okvgWDWoR7yYguS9Ghi4
         YLAmGB6O2HOaHt5pWgoenCZpkviSfW5HhUfpl+xmnsCtc3bH8hcfqcoiqXRkVB5PLSJS
         5H9wZVdf5mJ2yGkB21sQHr4fRmYQoZuXKopz9MctMRzRMNJL9IdDHXCIjsFdsngUGRSH
         vMGkRagjn8RV1Qrk5r8zz48f8iHUXJgFqNe0Lz3LbAtwFMEDRcJ6c5o0wpFYk3uopvnb
         /xPwgJTO0uUvEhpfCv1CscOupKBPltZ0OyOtc6vxseJEUuIY20jTRc1i9QWFamDELJ2g
         rT6A==
In-Reply-To: <alpine.LFD.2.11.1702191552560.1590@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>, network dev <netdev@vger.kernel.org>, Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Hi Julian,

Thanks a lot for the comments. I will send a v2 patch.

Regards
Hangbin

2017-02-19 22:04 GMT+08:00 Julian Anastasov <ja@ssi.bg>:
>
>         Hello,
>
> On Fri, 17 Feb 2017, Hangbin Liu wrote:
>
>> Fix and add some new ipvs sysctl options. Also use tab instead of whitespaces
>> to indent the descriptions.
>
>         You change only docs, so the patchset should be for
> the net-next tree.
>
>> Hangbin Liu (4):
>>   ipvs: fix sync_threshold description and add sync_refresh_period,
>>     sync_retries
>>   ipvs: Document sysctl sync_qlen_max and sync_sock_size
>
> - we can add "are " here but then also check if lines become too long:
>
> "Hard limit for queued sync messages that [are ]not sent yet."
>
>         You can also move the "commit" word to next line
> to make checkpatch happy:
>
> scripts/checkpatch.pl --strict /tmp/file2.patch
>
>>   ipvs: Document sysctl sync_ports
>>   ipvs: Document sysctl pmtu_disc
>
> - we can make it like this:
>
> "By default, reject with FRAG_NEEDED all DF packets that exceed
> the PMTU, irrespective of the forwarding method. For TUN method
> the flag can be disabled to fragment such packets."
>
>>  Documentation/networking/ipvs-sysctl.txt | 68 ++++++++++++++++++++++++++++----
>>  1 file changed, 60 insertions(+), 8 deletions(-)
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
