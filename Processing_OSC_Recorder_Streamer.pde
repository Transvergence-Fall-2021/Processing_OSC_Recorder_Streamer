import oscP5.*;
import netP5.*;
OscP5 oscP5;
JSONObject json;
int millis = 0;
JSONArray currentSample;
int sampleL = 0;
String FILE_NAME;
boolean playing = true;
int MODE;
NetAddress myRemoteLocation;

void setup() {
  size(800, 800);
  oscP5 = new OscP5(this, 9999);
  currentSample = new JSONArray();
  myRemoteLocation = new NetAddress("127.0.0.1",12000);
  
  /* CONFIGURE APPLICATION HERE */
  MODE = STREAMING;  
  FILE_NAME = "data";
  /* DON'T TOUCH ANYTHING ABOVE THIS LINE :) */
  
  if(MODE == RECORDING) json = new JSONObject();  
  else if(MODE == STREAMING) json = loadJSONObject("data/"+FILE_NAME+".json");
}

void draw() {
  color bg;
  if(playing) bg = color(0, 255, 0);
  else bg = color(255, 0, 0);
  background(bg);
  
  // ------------------------------
  
  if(MODE == STREAMING){
    JSONArray sample = json.getJSONArray(millis()+"");
    println(sample);
    if(sample!=null){
      for(int i=0; i<sample.size(); i++){
        JSONObject message = sample.getJSONObject(i);
        OscMessage myMessage = new OscMessage(message.getString("title"));
        oscP5.send(myMessage, myRemoteLocation); 
      }
    }
  }
}

void oscEvent(OscMessage m) {
  if(MODE == RECORDING){
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
  if(MODE == RECORDING){
    if(playing) playing = false;
    else saveJSONObject(json, "data/"+FILE_NAME+".json");
  }
}
