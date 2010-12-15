From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [*v2 PATCH 06/22] IPVS: netns preparation for proto_tcp
Date: Wed, 15 Dec 2010 23:37:12 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1012152314070.1827@ja.ssi.bg>
References: <1292247510-753-1-git-send-email-hans.schillstrom@ericsson.com> <1292247510-753-7-git-send-email-hans.schillstrom@ericsson.com> <20101213221831.GI3221@verge.net.au> <201012140742.33715.hans@schillstrom.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <201012140742.33715.hans@schillstrom.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: Simon Horman <horms@verge.net.au>, Hans Schillstrom <hans.schillstrom@ericsson.com>, daniel.lezcano@free.fr, Wensong Zhang <wensong@linux-vs.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org


 	Hello,

On Tue, 14 Dec 2010, Hans Schillstrom wrote:

>>> +/* Remove dot used
>>>  static int
>>>  tcp_set_state_timeout(struct ip_vs_protocol *pp, char *sname, int to)
>>>  {
>>>  	return ip_vs_set_state_timeout(pp->timeout_table, IP_VS_TCP_S_LAST,
>>>  				       tcp_state_name_table, sname, to);
>>> -}
>>> +} */
>>
>> Can we just remove tcp_set_state_timeout ?
>
> Sure, anyone that disagree ?

 	OK. Long ago the idea was ipvsadm to change the
timeouts for all states but it was not finished. IIRC,
all sysctl vars to control these timeouts are disabled.
What is missing is some method (via netlink) to provide
protocol, state name and timeout to the tcp_set_state_timeout
function because some users want to reduce the memory
usage with lower timeouts. Example:

# ipvsadm --get-proto-timeouts TCP SYN_RECV,ESTABLISHED
TCP.SYN_RECV=60
TCP.ESTABLISHED=900

# ipvsadm --set-proto-timeouts TCP "SYN_RECV=10, ESTABLISHED=20"

Regards

--
Julian Anastasov <ja@ssi.bg>
