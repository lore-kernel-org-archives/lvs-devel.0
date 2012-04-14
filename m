From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: [PATCH v2 1/2] netfilter: ipvs: Verify that IP_VS protocol has
 been registered
Date: Sat, 14 Apr 2012 14:32:01 +0200
Message-ID: <CA+1xoqdOqy8-Nkk00ZoCcUNLLvz0n6ZFyefsP8GoJhpepfVNtg@mail.gmail.com>
References: <1334409722-26315-1-git-send-email-levinsasha928@gmail.com>
 <alpine.LFD.2.00.1204141439440.1680@ja.ssi.bg> <CA+1xoqe0q=XH7mO6=qZKPxqZK8LU2Kk5BjmfLeQ9LUD1Ku65YA@mail.gmail.com>
 <alpine.LFD.2.00.1204141518270.9966@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:in-reply-to:references:from:date:message-id:subject:to
         :cc:content-type:content-transfer-encoding;
        bh=TmDxr+8YJVmoJkGlkAMEQlbncaUqAyN6XwaY3fZwfys=;
        b=U/UUIteOwevNkBtMA4RKYY5RNDHruykcWWC3zmgO0xlaZKMZGiwJgnodn9HqRpxCm8
         B4XTVAGk677Zr8y1su/Kcc1pmzxx7XIWEj7K0nuqa2MyYulHlDK/tlVUgTB5mgA/qlum
         OjCsrW2dsvzpPeJL0GBd5RpfsxEtUejG/+NTHYCEZKiXH91omD9+lJHqgY1pMsiGGD+q
         HbxTn7+43OH6q7aOcs/GifsYE7MOfbArH/WYRrUlxa99OXsoE6J0/WpM5p0oXYiaI+JI
         PhPfoI++uymnitqxfiTS/T+s2hEWxSQ9fknJvLz5WB1E4W8yMcZ3A5hytG4DTcn49bAp
         0/qw==
In-Reply-To: <alpine.LFD.2.00.1204141518270.9966@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Julian Anastasov <ja@ssi.bg>
Cc: wensong@linux-vs.org, horms@verge.net.au, kaber@trash.net, davem@davemloft.net, davej@redhat.com, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org

On Sat, Apr 14, 2012 at 2:23 PM, Julian Anastasov <ja@ssi.bg> wrote:
>
> =A0 =A0 =A0 =A0Hello,
>
> On Sat, 14 Apr 2012, Sasha Levin wrote:
>
>> On Sat, Apr 14, 2012 at 1:53 PM, Julian Anastasov <ja@ssi.bg> wrote:
>> > =A0 =A0 =A0 =A0Ops. It seems now we expose old problem when
>> > no protocol is configured. As this change probably will
>> > go to stable kernels, lets make it correct. Can you
>> > remove the defines around register_ip_vs_proto_netns, so
>> > that it is always compiled. One that wants to save
>> > memory will not disable all protocols. See commit
>> > 091bb34c143674d37a59b2d4857534f7106c5d7d for reference.
>>
>> Oh, so it wasn't getting built right now at all if we didn't select
>> any protocols.
>>
>> How about moving those defines down to our loop as well? this way
>> everything will behave exactly like it did before.
>
> =A0 =A0 =A0 =A0Better to remove the defines. It is a misconfiguration
> to enable IPVS without protocols. The referenced commit
> just tried to remove warnings, not save memory by commenting
> unused function. Adding more define makes the things more ugly.

Understood. I'll resend.
