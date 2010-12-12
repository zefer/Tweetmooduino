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

	// init the 8x8 LED Matrix Output
	initOutput();

	Serial.println("connecting...");  
	delay(2000);
}

void loop()
{
	doOutput();

	if (client.connect())
	{
		Serial.println("connected...");
		
		// build the HTTP request string
		String request = "GET ";
		request += "http://query.yahooapis.com/v1/public/yql?q=SELECT%20sentiment_index%20FROM%20json%20WHERE%20url%20%3D%20%22http://data.tweetsentiments.com:8080/api/search.json%3Ftopic%3Dxfactor%22&format=xml&tsecs=";
		request += millis()/1000; // cache bust
		request += " HTTP/1.0";
		Serial.println( request );

		// do the HTTP GET request
		client.println( request );		
		client.println();
	}
	else
	{
		Serial.println("connection failed");
	}
	
	if (client.connected())
	{
		char moodstring[5];

		if(finder.getString("<sentiment_index>","</sentiment_index>",moodstring,5) > 0)
		{
			// parse to float
			float newMood = atof(moodstring);
			showMood(newMood);
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

void showMood(float newMood)
{
	float moodDelta = newMood - mood;
	
	setOutput( moodDelta );

	if( moodDelta == 0 || mood == 0 )
	{
		// no mood change or first run
	}
	else if( moodDelta > 0 )
	{
		Serial.print("mood has improved by ");
		Serial.print( moodDelta );
		Serial.println( " :)" );
	}
	else
	{
		Serial.print("mood has worsened by ");
		Serial.print( abs(moodDelta) );
		Serial.println( " :(" );
	}
	
	mood = newMood;
	
	Serial.print("mood: ");
	Serial.println(newMood);
}
