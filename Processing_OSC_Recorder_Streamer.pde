import oscP5.*;
import netP5.*;
OscP5 oscP5;
JSONObject json;
int millis = 0;
JSONArray currentSample;
int sampleL = 0;
String FILE_NAME;
boolean playing = true;
boolean recorded = false;
int MODE;
NetAddress myRemoteLocation;

void setup() {
  size(800, 800);
  oscP5 = new OscP5(this, 9999);
  currentSample = new JSONArray();
  
  /* CONFIGURE APPLICATION HERE */
  MODE = RECORDING;  
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
  fill(0);
  if(MODE==RECORDING){
    if(playing) text("The input is being recorded. Click to stop", 20, 40);
    else text("Your stream has been recorded. Click to close", 20, 40);
  }else if(MODE==STREAMING){
    text("Streaming from file: " + FILE_NAME + ".json", 20, 40);
  }
  
  
  // ------------------------------
  
  if(MODE == STREAMING){
    JSONArray sample = json.getJSONArray(millis()+"");
    println(sample);
    if(sample!=null){
      for(int i=0; i<sample.size(); i++){
        JSONObject message = sample.getJSONObject(i);
        OscMessage myMessage = new OscMessage(message.getString("title"));
        myRemoteLocation = new NetAddress(message.getString("ipAddress"),message.getInt("port"));
        oscP5.send(myMessage, myRemoteLocation); 
      }
    }
  }
}

void oscEvent(OscMessage m) {
  println(m);
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
  //obj.setString("message", msgString);
  //obj.setInt("addressInt", message.addrInt());
  obj.setString("ipAddress", splited[0].substring(1,10));
  obj.setInt("port", int(splited[0].split(":")[1]));
  //obj.setString("addressString", splited[0]);
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
    if(recorded){
      exit();  
    }else if(playing){
      playing = false;
    }
    else
    {
      saveJSONObject(json, "data/"+FILE_NAME+".json");
      recorded = true;
    }   
  }
}
