From: Sohgo Takeuchi <sohgo@sohgo.dyndns.org>
Subject: ldirectord: a new format of ldirectord.conf for IPv6
Date: Mon, 02 Aug 2010 18:35:49 +0900 (JST)
Message-ID: <20100802.183549.71091890.sohgo@sohgo.dyndns.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org
Cc: horms@verge.net.au


Hi,

  I have been working on improving IPv6 support of ldirectord
for a few weeks. I would like to hear your opinion or ideas
about how to write ldirectord.conf.

Q1. Should ldirectord support an IPv6 hostname in ldirectord.conf?

    A manual of ldirectord says that a hostname can be written
    in "virtual", "real", "fallback" and so on. Current
    implementation of ldirectord handles the hostname as only
    IPv4. It partially supports IPv6, and can write only IPv6
    addresses. But it does not have a way to write a hostname as
    IPv6. Because there is no way to distinguish between IPv4
    and IPv6. Should ldirectord support an IPv6 hostname in
    ldirectord.conf?

Q2. If the answer of Q1 is yes, how do you want to write?

    [Candidate 1] Adding a new keyword like a "ipversion".
	A default value of "ipversion" is 4 (IPv4).

	fallback=fallback.example.com
	fallback6=fallback.example.com
        virtual=virtual.example.com:daytime
	    real=real1.example.com:daytime gate
	    real=10.10.10.10:daytime gate
    	
	virtual=virtual.example.com:daytime
	    ipversion=6
	    real=real1.example.com:daytime gate
	    real=[2001:db8::10]:daytime gate

    This way cannot handle a global "fallback" variable. We must
    have a way to distinguish between IPv4 and IPv6 when a
    hostname is specified in the global "fallback" variable. To
    achieve this, there is a way to add a new variable of
    "fallback6". Any other good ideas?

    
    [Candidate 2] Adding new keywords of "virtual6" and
	"fallback6".

    "virtual6" is an IPv6 version of "virtual". If a hostname
    and an IP address are specified in the "virtual6" line and
    in its section, they are treated as an IPv6 address and the
    hostname will be resolved into an IPv6 address.

    "fallback6" is just a global variable. It cannot be
    specified in a virtual section. If no "fallback" in a
    "virtual6" section is defined, the variable of "fallback6"
    will be used.  If "fallback" in the "virtual6" section is
    defined, it is treated as an IPv6 address.
    

	fallback=fallback.example.com
	fallback6=fallback.example.com
        virtual=virtual.example.com:daytime
	    real=real1.example.com:daytime gate
	    real=10.10.10.10:daytime gate
    	
	virtual6=virtual.example.com:daytime
	    real=real1.example.com:daytime gate
	    real=[2001:db8::10]:daytime gate

    This way breaks a backward compatibility. Current ldirectord
    can write an IPv6 address in a "virtual" line. But this way
    cannot.

    [Candidate 3] Completely separate IPv4 and IPv6 using
	"hoge6" keywords.
    
    Adding new keywords which denote IPv6. These keywords can
    handle IPv6 only and have a name "hoge6".

	fallback=fallback.example.com
	fallback6=fallback.example.com
        virtual=virtual.example.com:daytime
	    real=real1.example.com:daytime gate
	    real=10.10.10.10:daytime gate
    	
	virtual6=virtual.example.com:daytime
	    real6=real1.example.com:daytime gate
	    real6=[2001:db8::10]:daytime gate
	    fallback6=localhost:daytime

    This way is very similar to [Candidate 2]. But it is
    consistent and easy to read. A demerit is a bit redundant?
    

    [Candidate 4...] Any other good ideas?

--
Sohgo Takeuchi
