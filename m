From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH RFC net-next] net: ipvs: Adjust gso_size for IPPROTO_TCP
Date: Tue, 5 Jun 2018 14:31:28 -0700
Message-ID: <20180605213128.tlskvjhuk6vx3m6r@kafai-mbp.dhcp.thefacebook.com>
References: <20180419212324.1542504-1-kafai@fb.com>
 <alpine.LFD.2.20.1805020932270.1964@ja.home.ssi.bg>
 <20180502171041.s3euld6i7hm6bw5c@kafai-mbp>
 <alpine.LFD.2.20.1805022143360.3301@ja.home.ssi.bg>
 <20180503070114.bcuusvzga45klccs@kafai-mbp>
 <alpine.LFD.2.20.1805051515450.1895@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=date : from : to : cc :
 subject : message-id : references : mime-version : content-type :
 in-reply-to; s=facebook; bh=ru+sm9uU612fw7BMg9V/8HahlnMQH3FtGSnciIPdM1s=;
 b=A0qmoCAHN5YnWiy/okm2yS9BHHX2mk9XwJrwcqto7B3QUg3GDpSpMOrY8BSEvLFRIqEM
 30QDH7ncNDUL6xfhC1Je5znWHQNxJYJY076tqxJbCt0byT24PwgtV3CzKUxMWRNYmP78
 bZv0cH7biQT8VGK1HNI+q2uvr5swVHtq8iQ= 
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.20.1805051515450.1895@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: netdev@vger.kernel.org, David Ahern <dsahern@gmail.com>, Tom Herbert <tom@herbertland.com>, Eric Dumazet <eric.dumazet@gmail.com>, Nikita Shirokov <tehnerd@fb.com>, kernel-team@fb.com, lvs-devel@vger.kernel.org

On Sat, May 05, 2018 at 03:58:25PM +0300, Julian Anastasov wrote:
> 	So, except the RTF_LOCAL check in __ip6_rt_update_pmtu
> we should have no other issues. 
Hi Julian,

Do you have a chance to work on the IPv6 side?

Thanks,
Martin
