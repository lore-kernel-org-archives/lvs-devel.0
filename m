From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: [PATCH] IPVS: Allow boot time change of hash size.
Date: Thu, 27 Nov 2008 07:58:56 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0811270754290.32640@wm7d.net>
References: <1227706578-5449-1-git-send-email-catab@embedromix.ro>   
 <Pine.LNX.4.64.0811260636100.26650@wm7d.net>
 <37809.91.201.80.240.1227769089.squirrel@mail.embedromix.ro>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <37809.91.201.80.240.1227769089.squirrel@mail.embedromix.ro>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: "Catalin(ux) M. BOIE" <catab@embedromix.ro>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org

On Wed, 26 Nov 2008, Catalin(ux) M. BOIE wrote:

>> Why do you need to change the hash size? We really don't
>> recommend anyone do this under normal circumstances
>
> As it is written in the help, to lower the collisions in 
> the case of a lot of concurrent connections. Or am I 
> missing something?

not sure how big the collision problem is (have you measured 
an effect?) but Ratz put out the results of a back of the 
envelope calculation that the current value for the hash 
table size would work on the currect fastest machines with 
3G of memory

Joe

-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!
