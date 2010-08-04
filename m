From: Sohgo Takeuchi <sohgo@sohgo.dyndns.org>
Subject: Re: ldirectord: a new format of ldirectord.conf for IPv6
Date: Thu, 05 Aug 2010 00:13:30 +0900 (JST)
Message-ID: <20100805.001330.59655583.sohgo@sohgo.dyndns.org>
References: <20100803010342.GE14499@verge.net.au>
	<20100804.001324.112617176.sohgo@sohgo.dyndns.org>
	<20100804010034.GD4469@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20100804010034.GD4469@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: horms@verge.net.au
Cc: lvs-devel@vger.kernel.org


Hi simon,

From: Simon Horman <horms@verge.net.au>
|
> Hi Takeuchi-san,
> 
> On Wed, Aug 04, 2010 at 12:13:24AM +0900, Sohgo Takeuchi wrote:
>> 
>> Hi simon,
>> 
>> From: Simon Horman <horms@verge.net.au>
>> |
>> > On Mon, Aug 02, 2010 at 06:35:49PM +0900, Sohgo Takeuchi wrote:
>> >>     [Candidate 3] Completely separate IPv4 and IPv6 using
>> >> 	"hoge6" keywords.
>> >>     
>> >>     Adding new keywords which denote IPv6. These keywords can
>> >>     handle IPv6 only and have a name "hoge6".
>> >> 
>> >> 	fallback=fallback.example.com
>> >> 	fallback6=fallback.example.com
>> >>         virtual=virtual.example.com:daytime
>> >> 	    real=real1.example.com:daytime gate
>> >> 	    real=10.10.10.10:daytime gate
>> >>     	
>> >> 	virtual6=virtual.example.com:daytime
>> >> 	    real6=real1.example.com:daytime gate
>> >> 	    real6=[2001:db8::10]:daytime gate
>> >> 	    fallback6=localhost:daytime
>> >> 
>> >>     This way is very similar to [Candidate 2]. But it is
>> >>     consistent and easy to read. A demerit is a bit redundant?
>> > 
>> > I like candidate 3. Yes, it is redundant, but it is also very clear
>> > and consistent.
>> 
>> Yes.
>> 
>> I have implemented [candidate 3]. Now it works good.
> 
> Great, once you've finished your testing please post the patch.

Sure!
