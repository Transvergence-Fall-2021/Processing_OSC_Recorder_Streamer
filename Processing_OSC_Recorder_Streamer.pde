import oscP5.*;
import netP5.*;
OscP5 oscP5;
JSONObject json;
int millis = 0;
JSONArray currentSample;
int sampleL = 0;
boolean playing = true;
int MODE;

void setup() {
  size(800, 800);
  oscP5 = new OscP5(this, 9999);
  json = new JSONObject();  
  currentSample = new JSONArray();
  
  int MODE = RECORDING;  
}

void draw() {
  color bg;
  if(playing) bg = color(0, 255, 0);
  else bg = color(255, 0, 0);
  background(bg);
}

void oscEvent(OscMessage m) {
  if(playing){
    if(millis==millis()){
      currentSample.setJSONObject(sampleL, oscToJson(m));
      sampleL++;
    }else{
      if(sampleL!=0) json.setJSONArray(millis + "", currentSample);
      sampleL = 0;
      currentSample = new JSONArray();
      millis = millis();
    }
  }
}

JSONObject oscToJson(OscMessage message){
  JSONObject obj = new JSONObject();
  String typeTag = message.typetag();
  String msgString = message + "";
  String[] splited = msgString.split(" ", 10);
  println(splited[2]);
  obj.setString("message", msgString);
  obj.setInt("addressInt", message.addrInt());
  obj.setString("addressString", splited[0]);
  obj.setString("typeTag", typeTag);
  obj.setString("title", splited[2]);
  
  JSONArray arguments = new JSONArray();
  for(int i=0; i<typeTag.length(); i++){
    char type = typeTag.charAt(i);
    switch (type){
      case 'f':
        float value = message.get(i).floatValue();
        arguments.setFloat(i, value);
    }
  }
  obj.setJSONArray("arguments", arguments);
  
  return obj;
}

void mousePressed(){
  if(playing) playing = false;
  else saveJSONObject(json, "data/new.json");
}
