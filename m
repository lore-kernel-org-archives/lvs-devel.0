From: Graeme Fowler <graeme@graemef.net>
Subject: Re: Configuring keepalived + ipvs with persistence: doesn't balance
 to other node if initial persistent node fails.
Date: Wed, 11 Dec 2013 16:08:25 +0000
Message-ID: <52A88DF9.5060306@graemef.net>
References: <CAO2+3OzZ-XK7X0vto7sgh4VULGT7FTep5ot_pqPqb1mB=gO6rQ@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <CAO2+3OzZ-XK7X0vto7sgh4VULGT7FTep5ot_pqPqb1mB=gO6rQ@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: lvs-devel@vger.kernel.org

On 11/12/2013 15:26, Jose Luis Godoy wrote:
> real_server 192.168.58.201 443 {
>      weight 1
>      inhibit_on_failure

Remove inhibit_on_failure.

That keeps the server in the pool but with weight 0, meaning no *new* 
connections go to it. Existing persistent connections remain.

Alternatively, if you don't want to do that, set the sysctl 
net.ipv4.vs.expire_quiescent_template to 1, and keep inhibit_on_failure.

Both options are in effect synonyms, meaning in both cases that the 
persistence templates are removed for the VS in question when either it 
is removed from the pool (removing inhibit_on_failure) or quiesced 
(weight set to 0).

Graeme
