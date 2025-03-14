#include <Servo.h>

Servo myservo;  // create servo object to control a servo
int servoVal = 0;

int minDataVal = 100 , maxDataVal = 700;
void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  myservo.attach(10);
  myservo.write(servoVal);

  calibrate_sensor();
}

void loop() {
  if(Serial.available() > 0){
   servoVal = Serial.parseInt();
 
    if(servoVal <= 180 && servoVal >= 0){
      myservo.write(servoVal);
    }
    else if(servoVal == 500){
      calibrate_sensor();
      servoVal = 0;
    }
    else{
      motorControl(servoVal);
      servoVal = 0;
      myservo.write(servoVal);
    }
  }
  
  int sensorValue = analogRead(A0);
  int data = map(sensorValue, minDataVal, maxDataVal, 180, 0);
        
  Serial.print(servoVal);
  Serial.print(",");
  Serial.println(data);
  delay(15);       
}


void calibrate_sensor(){
   // CALIBRATE SENSOR TO MOTOR OUTPUT
  int count = 0;
  myservo.write(0);
  delay(1000);
  
  while(count < 100){
    maxDataVal = max(maxDataVal, analogRead(A0));
    delay(15);
    count++;
  }
  
  count = 0;
  myservo.write(180);
  delay(1000);
  
  while(count < 100){
    minDataVal = min(minDataVal, analogRead(A0));
    delay(15);
    count++;
  }
  
  count = 0;
  myservo.write(0);
  delay(1000);
}


void motorControl(int type){
  float duration = 10000;
  int t_delay = 15;
  int angle = 0;
  float count = 0;
  float old_count = 0;

  if(type != -1){
    duration = duration * 10;
  }
  
  while(count < duration){
    if(type == -1){
      // STEP INPUT
      if(count < (duration / 2)){
        angle = 0;
      }
      else{
        angle = 180;
      }
    }
    else if(type == -2){
      // SQUARE WAVE INPUT
      if(int((count / 2000)) % 2 == 0){
        angle = 0;
      }
      else{
        angle = 180;
      }
    }
    else if(type == -3){
      // SINUSOID INPUT
      angle = 90 + 80 * sin(millis() * 0.001);
    }
    else if(type = -4){
      // RANDOM INPUT
      if(count - old_count > 2000){
        angle = random(0,180);
        old_count = count;
      }
    }
    else{
      return;
      Serial.println("BAD INPUT");
    }
    myservo.write(angle);
    int sensorValue = analogRead(A0);
    int data = map(sensorValue, minDataVal, maxDataVal, 180, 0);
          
    Serial.print(angle);
    Serial.print(",");
    Serial.println(data);
    delay(t_delay);   
    count += t_delay;
  } 
}

/*
 * Sensor Values:
 * 0 = 770
 * 90 = 435
 * 180 = 94
 * Servo's effective range is 0 to 180 degrees.
 * Pot output has been mapped to angles. Is always very close if not spot on.
 */
