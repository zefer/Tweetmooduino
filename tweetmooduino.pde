#include <SPI.h>
#include <Ethernet.h>

#include <TextFinder.h>

// MAC address (probs printed on your ethernet controller)
byte mac[] = { 0x90, 0xA2, 0xDA, 0x00, 0x1F, 0x6F };
// static IP
byte ip[] = { 192,168,1,250 };
byte gateway[] ={ 192, 168, 1, 1 };
byte subnet[] ={ 255, 255, 255, 0 };

// query.yahooapis.com
byte server[] = { 69,147,126,237 };

Client client(server, 80);
TextFinder finder(client);

// this will store the 'mood', the twitter sentiment analysis
float mood;

void setup()
{
	Ethernet.begin(mac, ip, gateway, subnet); 
	Serial.begin(9600);
	Serial.println("connecting...");  
	delay(2000);  
}

void loop()
{
	if (client.connect())
	{
		Serial.print("connected...");
		// do the HTTP GET request
		client.println("GET http://query.yahooapis.com/v1/public/yql?q=SELECT%20sentiment_index%20FROM%20json%20WHERE%20url%20%3D%20%22http://data.tweetsentiments.com:8080/api/search.json%3Ftopic%3Dxfactor%22&format=xml HTTP/1.0");
		client.println();
	}
	else
	{
		Serial.println("connection failed");
	}
	
	if (client.connected())
	{
		char moodstring[5];
		int charcount = finder.getString("<sentiment_index>","</sentiment_index>",moodstring,5);

		if(charcount>0)
		{
			Serial.print("mood: ");
			Serial.print(moodstring);
			Serial.println();
		}
		else
		{
			Serial.println("unable to find the data we need");
		}

		delay(20000); // check again in 20 seconds
	}
	else
	{
		Serial.println();
		Serial.println("not connected");
		delay(1000); 
	} 

	client.stop();
}
