From: Jason Stubbs <j.stubbs@linkthink.co.jp>
Subject: Re: Least Connection Scheduler
Date: Wed, 2 Apr 2008 11:38:15 +0900
Message-ID: <200804021138.15828.j.stubbs@linkthink.co.jp>
References: <200804011336.08118.j.stubbs@linkthink.co.jp> <20080401051641.GB21127@verge.net.au> <200804011455.58676.j.stubbs@linkthink.co.jp>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_XGv8H3EQSlYQfQs"
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <200804011455.58676.j.stubbs@linkthink.co.jp>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: lvs-devel@vger.kernel.org

--Boundary-00=_XGv8H3EQSlYQfQs
Content-Type: text/plain;
  charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Tuesday 01 April 2008 14:55:58 Jason Stubbs wrote:
> On Tuesday 01 April 2008 14:16:41 Simon Horman wrote:
> > I think that the reasoning is that there is some expense related to
> > inactive connections, though its probably only in terms of memory
> > or possibly scheduler (thus CPU) being taken up, and its probably
> > a lot less than 1/256th of the cost associated with a live connection.
>
> This is the main reason why I kept the inactconns check as a secondary
> decision. The number of inactive connections should still stay fairly well
> balanced. If the number of inactive connections on a more powerful server
> is high enough that it starts affecting performance, lesser servers should
> start getting more requests causing things to even out again.
>
> > I like your patch, but I wonder if it might be better to make this
> > configurable. Perhaps two values, multiplier for active and multiplier
> > for inactive, which would be 256 and 1 by default. Setting such
> > a configuration to 1 and 0 would achieve what you are after without
> > changing the default behaviour.
>
> The request distribution should be nearly identical in the case of real
> servers of equal specs. I guess I should brush off my mathematics and
> calculate what the difference is in the various other cases. ;)

My mathematics was never really that good that I can just brush it off. ;)
Instead, I wrote a little simulation (attached) that compares behaviours.
The unbracketed figures below are values at the end of the run, the bracketed 
figures below are peak values during the run and T is the total number of 
connections sent to that server.

With 1000reqs/sec and two servers where #1 can handle 20% more requests:

Current LC
1:  A 21(23)  I 30567(30618)  T 153040
2:  A 24(26)  I 29388(29595)  T 146960

Patched LC
1:  A 22(22)  I 32978(32979)  T 164998
2:  A 23(23)  I 26977(26980)  T 135002

With 1000reqs/sec and two servers where #1 can handle 400% more requests:

Current LC
1:  A  5(11)  I 32352(32546)  T 162414
2:  A 24(26)  I 27619(28344)  T 137586

Patched LC
1:  A  9(10)  I 49191(49195)  T 245998
2:  A  9(10)  I 10791(10793)  T  54002

Looking at these figures, the only real problem would be the extra number of 
inactive connections on the faster server. However, after thinking about 
adding server weights to the equation, I'm wondering if this would not be 
better as yet-another-scheduler? I don't really like the idea of adding extra 
configuration as it steps away from LVS's current simplicity, but the 
difference in behaviour compared to the WLC scheduler is too great to be able 
to merge as is... Would yet-another-scheduler be accepted?

-- 
Jason Stubbs <j.stubbs@linkthink.co.jp>
LINKTHINK INC.
東京都渋谷区桜ヶ丘町22-14 N.E.S S棟 3F
TEL 03-5728-4772  FAX 03-5728-4773

--Boundary-00=_XGv8H3EQSlYQfQs
Content-Type: text/x-c++src;
  charset="iso-2022-jp";
  name="lvslctest.cpp"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="lvslctest.cpp"

#include <iostream>
#include <queue>
#include <vector>

#define INACTIVE_TIME 60000
#define NEW_CONN_INTERVAL 1
#define SERVER1_TIME 40
#define SERVER2_TIME 50


using namespace std;

class Server
{
public:
	Server(int processingTime)
	: m_processingTime(processingTime)
	, m_maxActive(0)
	, m_maxInactive(0)
	, m_totalCount(0)
	{
	}

	void tick(int time)
	{
		if (m_active.size() > m_maxActive) {
			m_maxActive = m_active.size();
		}

		int expireTime = time - m_processingTime;
		while (m_active.size() && m_active.front() <= expireTime) {
			m_inactive.push(m_active.front());
			m_active.pop();
		}

		if (m_inactive.size() > m_maxInactive) {
			m_maxInactive = m_inactive.size();
		}

		expireTime = time - INACTIVE_TIME;
		while (m_inactive.size() && m_inactive.front() <= expireTime) {
			m_inactive.pop();
		}
	}

	void addConn(int time)
	{
		m_active.push(time);
		m_totalCount++;
	}

	int activeCount()
	{
		return m_active.size();
	}

	int maxActive()
	{
		return m_maxActive;
	}

	int inactiveCount()
	{
		return m_inactive.size();
	}

	int maxInactive()
	{
		return m_maxInactive;
	}

	int totalCount()
	{
		return m_totalCount;
	}

private:
	int m_processingTime;
	queue<int> m_active;
	queue<int> m_inactive;
	int m_maxActive;
	int m_maxInactive;
	int m_totalCount;
};


class Balancer
{
public:
	Balancer()
	: m_currentTime(0)
	{
	}

	~Balancer()
	{
		vector<Server*>::iterator i_server;
		for (i_server = m_servers.begin(); i_server != m_servers.end(); i_server++) {
			delete *i_server;
		}
	}

	void addServer(Server* server)
	{
		m_servers.push_back(server);
	}

	Server* regularLC()
	{
		Server* least = NULL;
		int loh = 0;

		vector<Server*>::iterator i_server;
		for (i_server = m_servers.begin(); i_server != m_servers.end(); i_server++) {
			Server* server = *i_server;
			int doh = (server->activeCount() << 8) + server->inactiveCount();
			if (!least || doh < loh) {
				least = server;
				loh = doh;
			}
		}

		return least;
	}

	Server* patchedLC()
	{
		Server* least = NULL;
		int least_active = 0;
		int least_inactive = 0;

		vector<Server*>::iterator i_server;
		for (i_server = m_servers.begin(); i_server != m_servers.end(); i_server++) {
			Server* server = *i_server;
			int server_active = server->activeCount();
			int server_inactive = server->inactiveCount();
			if (!least || server_active < least_active) {
				least = server;
				least_active = server_active;
				least_inactive = server_inactive;
			} else if (server_active == least_active && server_inactive < least_inactive) {
				least = server;
				least_inactive = server_inactive;
			}
		}

		return least;
	}

	void tick(int time)
	{
		vector<Server*>::iterator i_server;
		for (i_server = m_servers.begin(); i_server != m_servers.end(); i_server++) {
			Server* server = *i_server;
			server->tick(time);
		}
	}

	void debug()
	{
		vector<Server*>::iterator i_server;
		int i = 0;
		for (i_server = m_servers.begin(); i_server != m_servers.end(); i_server++) {
			Server* server = *i_server;
			cout << ++i << ":";
			cout << "  A " << server->activeCount() << "(" << server->maxActive() << ")";
			cout << "  I " << server->inactiveCount() << "(" << server->maxInactive() << ")";
			cout << "  T " << server->totalCount() << "\n";
		}
		cout << "\n";
	}

private:
	int m_currentTime;
	vector<Server*> m_servers;
};


int main(int, char**)
{
	Balancer *balancer;

	balancer = new Balancer();
	balancer->addServer(new Server(SERVER1_TIME));
	balancer->addServer(new Server(SERVER2_TIME));

	for (int time = 0; time < 5 * INACTIVE_TIME; time += NEW_CONN_INTERVAL) {
		Server* server = balancer->regularLC();
		server->addConn(time);
		balancer->tick(time);
	}
	balancer->debug();
	delete balancer;

	balancer = new Balancer();
	balancer->addServer(new Server(SERVER1_TIME));
	balancer->addServer(new Server(SERVER2_TIME));

	for (int time = 0; time < 5 * INACTIVE_TIME; time += NEW_CONN_INTERVAL) {
		balancer->tick(time);
		Server* server = balancer->patchedLC();
		server->addConn(time);
	}
	balancer->debug();
	delete balancer;

	return 0;
}

--Boundary-00=_XGv8H3EQSlYQfQs--
