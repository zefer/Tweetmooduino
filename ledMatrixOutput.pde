/*
 * smiley or frown faces!
 */

// defines which pin each row is attached to - rows are common anode (drive HIGH)
int rowA[] = {9,8,7,6,5,4,3,2};
// defines which pin each column is attached to - columns are common cathode (drive LOW)
int colA[] = {17,16,15,14,13,12,11,10};

// bitmaps
byte smile[] = {0,0,0,0,0,0,0,0};
byte frown[] = {0,0,0,0,0,0,0,0};
byte neutral[] = {0,0,0,0,0,0,0,0};
byte allon[] = {0,0,0,0,0,0,0,0};
byte* currentOutput = &smile[0];

void initOutput()
{ 
	// set the 16 pins used to control the array as OUTPUTs
	for(int i = 0; i <8; i++)
	{
		pinMode(rowA[i], OUTPUT);
		pinMode(colA[i], OUTPUT);
	}

	// smiley face bitmask
	smile[7] = B11100111;
	smile[6] = B11100111;
	smile[5] = B11100111;
	smile[4] = B00000000;
	smile[3] = B00000000;
	smile[2] = B10000001;
	smile[1] = B11000011;
	smile[0] = B00111100;

	// frown face bitmask
	frown[7] = B11100111;
	frown[6] = B11100111;
	frown[5] = B11100111;
	frown[4] = B00000000;
	frown[3] = B00000000;
	frown[2] = B00111100;
	frown[1] = B11000011;
	frown[0] = B10000001;

	// neutral face bitmask
	neutral[7] = B11100111;
	neutral[6] = B11100111;
	neutral[5] = B11100111;
	neutral[4] = B00000000;
	neutral[3] = B00000000;
	neutral[2] = B11111111;
	neutral[1] = B11111111;
	neutral[0] = B00000000;

	// all on bitmask
	allon[7] = B11111111;
	allon[6] = B11111111;
	allon[5] = B11111111;
	allon[4] = B11111111;
	allon[3] = B11111111;
	allon[2] = B11111111;
	allon[1] = B11111111;
	allon[0] = B11111111;
}

void setOutput(float state)
{
	if( state > 0 )
	{
		currentOutput = &smile[0];
	}
	else if( state < 0 )
	{
		currentOutput = &frown[0];
	}
	else
	{
		currentOutput = &neutral[0];
	}
}

void doOutput()
{
	// for each column...
	for(int column = 0; column < 8; column++)
	{
		// turn off all its row pins
		for(int i = 0; i < 8; i++)
		{                          
			digitalWrite(rowA[i], LOW);
		}

		for(int i = 0; i < 8; i++)
		{
			// set only the one pin
			if(i == column)
			{
				// turns the current row on
				digitalWrite(colA[i], LOW);
			}
			else
			{
				// turns the rest of the rows off
				digitalWrite(colA[i], HIGH); 
			}
		}

		// for each pixel in the current column...
		for(int row = 0; row < 8; row++)
		{
			int bit = (currentOutput[column] >> row) & 1;
			if(bit == 1)
			{
				// turn the LED on
				digitalWrite(rowA[row], HIGH);
			}
		}
	} 
	delay(10);
}
