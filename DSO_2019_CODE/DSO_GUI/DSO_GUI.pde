/*****************************************************
 * USB DSO Interface Software
 * Original Author: David Jahshan 2011
 * updated by: Geoff Ayre 2014
 * 
 * This code interfaces with the USB DSO and displays 
 * the information captured by the device.
 *****************************************************
 */




import processing.serial.*;
import org.apache.commons.math.complex.*;

/*class Complex {
    double real;   // the real part
    double img;   // the imaginary part

    public Complex(double real, double img) {
        this.real = real;
        this.img = img;
    }

    public Complex multi(Complex b) {
        double real = this.real * b.real - this.img * b.img;
        double img = this.real * b.img + this.img * b.real;
        return new Complex(real, img);
    }
}*/

int screen_width, screen_height, topgap = 50;
int fft_width = 650;
int Nyquist_freq;
int background_red,background_green,background_blue;
int foreground_red,foreground_green,foreground_blue;
int line_red,line_green,line_blue;
int button_on_red,button_on_green,button_on_blue;
int button_off_red,button_off_green,button_off_blue;
int grid1_red,grid1_green,grid1_blue;
int grid2_red,grid2_green,grid2_blue;

Serial USBDSOPort;
char KeyStroke = ' ';  
String ReceivedString = " ";
int x = 0, y = 0, mouse_x, mouse_y;

//folowing vaiables are for button positions
//x is start point on x. y is start point on y, w is width, h is height
char Sample_Rate=3;
int trigger_x=800, trigger_y=650, trigger_w=100, trigger_h=30;
char trigger=127;

int[] captured_data = new int[65001];
float[] fft_data = new float[65001];
int dataindex = 0;

boolean FFT_COMP;
boolean FREQ_LINE;
boolean GRID_1V;
boolean GRID_100mV;
boolean GRID_MAJOR_TIME;
boolean GRID_MINOR_TIME;
boolean GRID_FREQ;
boolean FULL_GRID;
boolean SHOW_TRIGGER;
boolean DRAW_LINE = true;
boolean CURSOR_1;
boolean CURSOR_2;
boolean EDGE_SW;
boolean CONT_MODE = false;

boolean DSO_connected=false;

boolean dragging_trigger=false;
boolean dragging_c1=false;
boolean dragging_c2=false;

JSONObject configobject;
import controlP5.*;

ControlP5 cp5;

RadioButton SampleRateControl;
Toggle Grid1VButton;
Toggle Grid100mVButton;
Toggle GridMajorTimeButton;
Toggle GridMinorTimeButton;
Toggle ShowTriggerButton;
Toggle FullGridButton;
Toggle DrawLineButton;
Toggle FreqLineButton;
Toggle Cursor1Button;
Toggle Cursor2Button;
Toggle EdgeSwitchButton;
Toggle GridFreqButton;

Bang CaptureButton;
Bang ForceTriggerButton;
Bang AbortButton;
Bang HighspeedButton;
DropdownList CPList;
DropdownList BaudList;
Toggle ContButton;

Knob NumberOfSamplesKnob;
int NUMBER_OF_SAMPLES=1000;
Knob TriggerKnob;
float Trigger_Value=1.0;
boolean NewTriggerLevel=false;

int BaudValue=38400;

int total_displayed_time;
int samples_per_column;

int program_state = 1;
int capturestarttime = 0;

int scopeYsize;
int scopeXsize;

float Cursor1Val=1.0;
float Cursor2Val=-1.0;
float Cursor1V;
float Cursor2V;

float deltaT;
float deltaTinv;

String[] portList = Serial.list();


void setup() 
{

  PFont DisplayFont = createFont("Arial", 10);
  textFont(DisplayFont);

  // Print a list all the available serial ports:
  println(Serial.list());
  if(portList.length>0)
  {
    // Open USBDSO port
    USBDSOPort = new Serial(this, portList[0], 38400);
    background(255);
    USBDSOPort.write('v');
    //USBDSOPort.write('r');
    //USBDSOPort.write('3');
    
    DSO_connected=true;
    NewTriggerLevel=true;
  } else {
    DSO_connected=false;
  }
 
  configobject = loadJSONObject("config.json");
  screen_width = configobject.getInt("ScreenWidth");
  screen_height = configobject.getInt("ScreenHeight");
  
  background_red = configobject.getInt("BackgroundColourRed");
  background_green = configobject.getInt("BackgroundColourGreen");
  background_blue = configobject.getInt("BackgroundColourBlue");
  foreground_red = configobject.getInt("ForegroundColourRed");
  foreground_green = configobject.getInt("ForegroundColourGreen");
  foreground_blue = configobject.getInt("ForegroundColourBlue");
  line_red = configobject.getInt("LineColourRed");
  line_green = configobject.getInt("LineColourGreen");
  line_blue = configobject.getInt("LineColourBlue");
  button_on_red = configobject.getInt("ButtonOnColourRed");
  button_on_green = configobject.getInt("ButtonOnColourGreen");
  button_on_blue = configobject.getInt("ButtonOnColourBlue");
  button_off_red = configobject.getInt("ButtonOffColourRed");
  button_off_green = configobject.getInt("ButtonOffColourGreen");
  button_off_blue = configobject.getInt("ButtonOffColourBlue");

  grid1_red = configobject.getInt("Grid1ColourRed");
  grid1_green = configobject.getInt("Grid1ColourGreen");
  grid1_blue = configobject.getInt("Grid1ColourBlue");
  grid2_red = configobject.getInt("Grid2ColourRed");
  grid2_green = configobject.getInt("Grid2ColourGreen");
  grid2_blue = configobject.getInt("Grid2ColourBlue");

  scopeYsize = screen_height*3/4;
  scopeXsize = screen_width-(2*topgap);
     
  println("SCOPE SIZE = "+scopeYsize+"x"+scopeXsize);
  println("FFT SCOPE SIZE = "+scopeYsize+"x"+fft_width);

  cp5 = new ControlP5(this);
    

  Grid1VButton = cp5.addToggle("GRID_1V")
                     .setPosition(screen_width-topgap-150,scopeYsize+topgap+20)
                     .setSize(20,20)
                     .setColorActive(color(button_on_red,button_on_green,button_on_blue))
                     .setColorForeground(color(button_off_red,button_off_green,button_off_blue))
                     .setColorBackground(color(button_off_red,button_off_green,button_off_blue))
                     .setValue(1)
                     ;                 
                     Grid1VButton.captionLabel().style().moveMargin(-18,0,0,25);

  Grid100mVButton = cp5.addToggle("GRID_100mV")
                     .setPosition(screen_width-topgap-150,scopeYsize+topgap+41)
                     .setSize(20,20)
                     .setColorActive(color(button_on_red,button_on_green,button_on_blue))
                     .setColorForeground(color(button_off_red,button_off_green,button_off_blue))
                     .setColorBackground(color(button_off_red,button_off_green,button_off_blue))
                     .setValue(1)
                     ;
                     Grid100mVButton.captionLabel().style().moveMargin(-18,0,0,25);
  
  GridFreqButton = cp5.addToggle("GRID_FREQ")
                     .setPosition(screen_width+topgap+50,scopeYsize+topgap+20)
                     .setSize(20,20)
                     .setColorActive(color(button_on_red,button_on_green,button_on_blue))
                     .setColorForeground(color(button_off_red,button_off_green,button_off_blue))
                     .setColorBackground(color(button_off_red,button_off_green,button_off_blue))
                     .setValue(1)
                     ;
                     GridFreqButton.captionLabel().style().moveMargin(-18,0,0,25);

       
  FullGridButton = cp5.addToggle("FULL_GRID")
                     .setPosition(screen_width-topgap-150,scopeYsize+topgap+62)
                     .setSize(20,20)
                     .setColorActive(color(button_on_red,button_on_green,button_on_blue))
                     .setColorForeground(color(button_off_red,button_off_green,button_off_blue))
                     .setColorBackground(color(button_off_red,button_off_green,button_off_blue))
                     ;
                     FullGridButton.captionLabel().style().moveMargin(-18,0,0,25);

  GridMajorTimeButton = cp5.addToggle("GRID_MAJOR_TIME")
                     .setPosition(screen_width-topgap-60,scopeYsize+topgap+20)
                     .setSize(20,20)
                     .setColorActive(color(button_on_red,button_on_green,button_on_blue))
                     .setColorForeground(color(button_off_red,button_off_green,button_off_blue))
                     .setColorBackground(color(button_off_red,button_off_green,button_off_blue))
                     .setValue(1)
                     ;                 
                     GridMajorTimeButton.captionLabel().style().moveMargin(-18,0,0,25);

  GridMinorTimeButton = cp5.addToggle("GRID_MINOR_TIME")
                     .setPosition(screen_width-topgap-60,scopeYsize+topgap+41)
                     .setSize(20,20)
                     .setColorActive(color(button_on_red,button_on_green,button_on_blue))
                     .setColorForeground(color(button_off_red,button_off_green,button_off_blue))
                     .setColorBackground(color(button_off_red,button_off_green,button_off_blue))
                     .setValue(1)
                     ;
                     GridMinorTimeButton.captionLabel().style().moveMargin(-18,0,0,25);

  ShowTriggerButton = cp5.addToggle("SHOW_TRIGGER")
                     .setPosition(screen_width-topgap-60,scopeYsize+topgap+62)
                     .setSize(20,20)
                     .setColorActive(color(button_on_red,button_on_green,button_on_blue))
                     .setColorForeground(color(button_off_red,button_off_green,button_off_blue))
                     .setColorBackground(color(button_off_red,button_off_green,button_off_blue))
                     .setValue(1)
                     ;
                     ShowTriggerButton.captionLabel().style().moveMargin(-18,0,0,25);

  DrawLineButton = cp5.addToggle("DRAW_LINE")
                     .setPosition(screen_width-topgap-320,scopeYsize+topgap+62)
                     .setSize(20,20)
                     .setColorActive(color(button_on_red,button_on_green,button_on_blue))
                     .setColorForeground(color(button_off_red,button_off_green,button_off_blue))
                     .setColorBackground(color(button_off_red,button_off_green,button_off_blue))
                     .setValue(1)
                     ;
                     DrawLineButton.captionLabel().style().moveMargin(-18,0,0,25);

  Cursor2Button = cp5.addToggle("CURSOR_2")
                     .setPosition(screen_width-topgap-320,scopeYsize+topgap+41)
                     .setSize(20,20)
                     .setColorActive(color(button_on_red,button_on_green,button_on_blue))
                     .setColorForeground(color(button_off_red,button_off_green,button_off_blue))
                     .setColorBackground(color(button_off_red,button_off_green,button_off_blue))
                     .setValue(0)
                     ;
                     Cursor2Button.captionLabel().style().moveMargin(-18,0,0,25);

  Cursor1Button = cp5.addToggle("CURSOR_1")
                     .setPosition(screen_width-topgap-320,scopeYsize+topgap+20)
                     .setSize(20,20)
                     .setColorActive(color(button_on_red,button_on_green,button_on_blue))
                     .setColorForeground(color(button_off_red,button_off_green,button_off_blue))
                     .setColorBackground(color(button_off_red,button_off_green,button_off_blue))
                     .setValue(0)
                     ;
                     Cursor1Button.captionLabel().style().moveMargin(-18,0,0,25);
  
                  
  EdgeSwitchButton = cp5.addToggle("EDGE_SW")
                     .setPosition(screen_width-topgap-400,scopeYsize+topgap+20)
                     .setSize(20,20)
                     .setColorActive(color(button_on_red,button_on_green,button_on_blue))
                     .setColorForeground(color(button_off_red,button_off_green,button_off_blue))
                     .setColorBackground(color(button_off_red,button_off_green,button_off_blue))
                     .setValue(0)
                     ;
                     EdgeSwitchButton.captionLabel().style().moveMargin(-18,0,0,25);
                     
  ContButton = cp5.addToggle("CONT_MODE")
                     .setPosition(screen_width-topgap-400,scopeYsize+topgap+41)
                     .setSize(20,20)
                     .setColorActive(color(button_on_red,button_on_green,button_on_blue))
                     .setColorForeground(color(button_off_red,button_off_green,button_off_blue))
                     .setColorBackground(color(button_off_red,button_off_green,button_off_blue))
                     .setValue(0)
                     ;
                     ContButton.captionLabel().style().moveMargin(-18,0,0,25);

  FreqLineButton = cp5.addToggle("FREQ_LINE")
                     .setPosition(screen_width+topgap+50,scopeYsize+topgap+41)
                     .setSize(20,20)
                     .setColorActive(color(button_on_red,button_on_green,button_on_blue))
                     .setColorForeground(color(button_off_red,button_off_green,button_off_blue))
                     .setColorBackground(color(button_off_red,button_off_green,button_off_blue))
                     .setValue(1)
                     ;
                     FreqLineButton.captionLabel().style().moveMargin(-18,0,0,25);


  NumberOfSamplesKnob = cp5.addKnob("NUMBER_OF_SAMPLES")
                     .setRange(1000,65000)
                     .setNumberOfTickMarks(64)
                     .setTickMarkLength(2)
                     .snapToTickMarks(true)
                     .setValue(1000)
                     .setRadius(30)
                     //.setDragDirection(Knob.VERTICAL)
                     .setPosition(topgap,scopeYsize+topgap+20)
                     .setColorActive(color(button_on_red,button_on_green,button_on_blue))
                     .setColorForeground(color(button_off_red,button_off_green,button_off_blue))
                     .setColorBackground(color(button_off_red,button_off_green,button_off_blue))
                     ;

  TriggerKnob = cp5.addKnob("Trigger_Value")
                     .setRange(-5.0,5.0)
                     .setNumberOfTickMarks(100)
                     .setTickMarkLength(2)
                     .snapToTickMarks(true)
                     .setValue(1.0)
                     .setRadius(30)
                     //.setDragDirection(Knob.VERTICAL)
                     .setPosition(topgap+80,scopeYsize+topgap+20)
                     .setColorActive(color(button_on_red,button_on_green,button_on_blue))
                     .setColorForeground(color(button_off_red,button_off_green,button_off_blue))
                     .setColorBackground(color(button_off_red,button_off_green,button_off_blue))
                     ;


  SampleRateControl = cp5.addRadioButton("Sample_Rate")
                     .setPosition(screen_width-topgap-240,scopeYsize+topgap+20)
                     .setSize(20,20)
                     .setColorActive(color(button_on_red,button_on_green,button_on_blue))
                     .setColorForeground(color(button_off_red,button_off_green,button_off_blue))
                     .setColorBackground(color(button_off_red,button_off_green,button_off_blue))
                     .setColorLabel(color(255))
                     .setItemsPerRow(1)
                     .setSpacingRow(1)
                     .addItem("40MHz",1)
                     .addItem("30MHz",2)
                     .addItem("20MHz",3)
                     .addItem("10MHz",4)
                     .activate(2)
                     ;

  CaptureButton = cp5.addBang("Capture")
                     .setPosition(topgap+170,scopeYsize+topgap+20)
                     .setSize(85,20)
                     .setTriggerEvent(Bang.RELEASE)
                     .setColorActive(color(button_on_red,button_on_green,button_on_blue))
                     .setColorForeground(color(button_off_red,button_off_green,button_off_blue))
                     .setColorBackground(color(button_off_red,button_off_green,button_off_blue))
                     ;
                     CaptureButton.captionLabel().style().moveMargin(-18,0,0,11);
                    
  ForceTriggerButton = cp5.addBang("Force_Trigger")
                     .setPosition(topgap+170,scopeYsize+topgap+41)
                     .setSize(85,20)
                     .setTriggerEvent(Bang.RELEASE)
                     .setColorActive(color(button_on_red,button_on_green,button_on_blue))
                     .setColorForeground(color(button_off_red,button_off_green,button_off_blue))
                     .setColorBackground(color(button_off_red,button_off_green,button_off_blue))
                   ;
                    ForceTriggerButton.captionLabel().style().moveMargin(-18,0,0,11);

  AbortButton = cp5.addBang("Abort")
                     .setPosition(topgap+170,scopeYsize+topgap+62)
                     .setSize(85,20)
                     .setTriggerEvent(Bang.RELEASE)
                     .setColorActive(color(button_on_red,button_on_green,button_on_blue))
                     .setColorForeground(color(button_off_red,button_off_green,button_off_blue))
                     .setColorBackground(color(button_off_red,button_off_green,button_off_blue))
                    ;
                    AbortButton.captionLabel().style().moveMargin(-18,0,0,11);
  /**
  //Add a button to enable faster baudrate (250000 at 2X speed)  
  HighspeedButton = cp5.addBang("Highspeed")
                     .setPosition(topgap+100,7)
                     .setSize(85,20)
                     .setTriggerEvent(Bang.RELEASE)
                     .setColorActive(color(button_on_red,button_on_green,button_on_blue))
                     .setColorForeground(color(button_off_red,button_off_green,button_off_blue))
                     .setColorBackground(color(button_off_red,button_off_green,button_off_blue))
                    ;
                    HighspeedButton.captionLabel().style().moveMargin(-18,0,0,11);
  **/
  
  CPList = cp5.addDropdownList("ComPortList")
                     .setPosition(topgap,25)
                     .setSize(85,200)
                     .setColorActive(color(button_on_red,button_on_green,button_on_blue))
                     .setColorForeground(color(button_off_red,button_off_green,button_off_blue))
                     .setColorBackground(color(button_off_red,button_off_green,button_off_blue))
                     ;
                     
                     println("COM ports: "+portList.length+" available");
                     println(portList);
                     CPList.setBackgroundColor(color(190));
                     CPList.setItemHeight(20);
                     CPList.setBarHeight(15);
                     CPList.captionLabel().style().marginTop = 3;
                     CPList.captionLabel().style().marginLeft = 3;
                     CPList.valueLabel().style().marginTop = 3;
                     for (int i=0;i<portList.length;i++) {
                         CPList.addItem(portList[i],i);
                         
                     }
                     if(DSO_connected==true)
                     {
                       CPList.setIndex(0);
                     }
/*
  BaudList = cp5.addDropdownList("BaudRateList")
                     .setPosition(topgap+100,25)
                     .setSize(85,200)
                     .setColorActive(color(button_on_red,button_on_green,button_on_blue))
                     .setColorForeground(color(button_off_red,button_off_green,button_off_blue))
                     .setColorBackground(color(button_off_red,button_off_green,button_off_blue))
                     ;
                     
                     BaudList.setBackgroundColor(color(190));
                     BaudList.setItemHeight(20);
                     BaudList.setBarHeight(15);
                     BaudList.captionLabel().style().marginTop = 3;
                     BaudList.captionLabel().style().marginLeft = 3;
                     BaudList.valueLabel().style().marginTop = 3;
                     BaudList.addItem("38400",1);
                     BaudList.addItem("115200",2);
                         
                     

                     BaudList.setIndex(0);
*/

  //size(screen_width,screen_height);
  size(1450,600);
  
  stroke(0);
  
  
  
}

void draw() 
{
     portList = Serial.list();
     if(portList.length==0)
     {
       DSO_connected=false; 
     }
    if(Sample_Rate==4)
    {
      total_displayed_time = NUMBER_OF_SAMPLES/10;
      Nyquist_freq = 5;
    } else if(Sample_Rate==3) {
      total_displayed_time = NUMBER_OF_SAMPLES/20;
      Nyquist_freq = 10;      
    } else if(Sample_Rate==2) {
      total_displayed_time = NUMBER_OF_SAMPLES/30;
      Nyquist_freq = 15;      
    } else if(Sample_Rate==1) {
      total_displayed_time = NUMBER_OF_SAMPLES/40;      
      Nyquist_freq = 20;
    }
    
    samples_per_column = NUMBER_OF_SAMPLES/scopeXsize;    
    
    if(program_state==2&&DSO_connected)
    {
      if(millis()-capturestarttime>500)
      {
          USBDSOPort.write('s');   
          dataindex=0;
          program_state=3;
      }
    }
    
    if(dragging_trigger == true)
    {
      Trigger_Value = -2.0*(mouseY - (topgap+scopeYsize/2))*5.0/scopeYsize;
      if(Trigger_Value>5.0)
      {
         Trigger_Value=5.0; 
      }
      if(Trigger_Value<-5.0)
      {
         Trigger_Value=-5.0; 
      }
    }
    if(dragging_c1 == true)
    {
      Cursor1Val = 2.0*(mouseX - (topgap+scopeXsize/2))*5.0/scopeXsize;
      if(Cursor1Val>5.0)
      {
         Cursor1Val=5.0; 
      }
      if(Cursor1Val<-5.0)
      {
         Cursor1Val=-5.0; 
      }
    }
    if(dragging_c2 == true)
    {
      Cursor2Val = 2.0*(mouseX - (topgap+scopeXsize/2))*5.0/scopeXsize;
      if(Cursor2Val>5.0)
      {
         Cursor2Val=5.0; 
      }
      if(Cursor2Val<-5.0)
      {
         Cursor2Val=-5.0; 
      }
    }
    
    
    if(NewTriggerLevel==true&&mousePressed==false&&DSO_connected)
    {
      USBDSOPort.write('n');
      USBDSOPort.write('t');
      //char TriggerVal8Bit = (char)(((Trigger_Value+5.0)/10.0)*255.0);
      char trig15 = (char)(1.5/5.0 * 255); //-5v input
      char trig35 = (char)(3.5/5.0 * 255); //+5v input
      float dacVoltage = ((((1.0*Trigger_Value)+5.0)/10.0) * 2.0 + 1.5);
      char TriggerVal8Bit = (char)(dacVoltage/5.0 * 255);
      USBDSOPort.write(TriggerVal8Bit);
      println("Trigger threshold set to "+Trigger_Value+" DACvoltage="+(float)dacVoltage+" ("+(int)TriggerVal8Bit+")");
      NewTriggerLevel=false;
    }
  
    background(foreground_red,foreground_green,foreground_blue);
    fill(background_red,background_green,background_blue);
    stroke(line_red,line_green,line_blue);
    rect(topgap,topgap,screen_width-topgap*2,scopeYsize);//screen
    rect(topgap+750,topgap,fft_width-topgap*2,scopeYsize); //fft

    fill(line_red,line_green,line_blue);
    text("Time Domain",25+scopeXsize/2,topgap-10);
    text("Frequency Domain",topgap+650+fft_width/2,topgap-10);

    if(GRID_100mV==true)
    {
      stroke(grid2_red,grid2_green,grid2_blue);
      for(int i=-25;i<=25;i++)
      {
        if(FULL_GRID==true)
        {
          line(topgap,ScaleVertically(float(i)/5.0),screen_width-topgap,ScaleVertically(float(i)/5.0));
        } else {
          line(screen_width/2-5,ScaleVertically(float(i)/5.0),screen_width/2+5,ScaleVertically(float(i)/5.0));        
        }
      }
    }

    if(GRID_MINOR_TIME==true)
    {
      stroke(grid2_red,grid2_green,grid2_blue);
      int spacing = scopeXsize/50;
      for(int i=0;i<=50;i++)
      {
        if(FULL_GRID==true)
        {
          line(topgap+i*spacing,topgap,topgap+i*spacing,scopeYsize+topgap);
        } else {
          line(topgap+i*spacing,screen_height*3/8-5+topgap,topgap+i*spacing,screen_height*3/8+5+topgap);        
        }
      }
    }
    
    if(GRID_1V==true)
    {
      stroke(grid1_red,grid1_green,grid1_blue);
      for(int i=-5;i<=5;i++)
      {
        if(FULL_GRID==true)
        {
          line(topgap,ScaleVertically(i),screen_width-topgap,ScaleVertically(i));
          text(i+"V",topgap-25,ScaleVertically(i));
        } else {
          line(screen_width/2-10,ScaleVertically(i),screen_width/2+10,ScaleVertically(i));        
          if(i>-5&&i<5&&i!=0)
          {
            text(i+"V",screen_width/2-30,ScaleVertically(i)+5);
          } else if(i==-5) {
            text(i+"V",screen_width/2-30,scopeYsize+topgap-2);
            
          } else if(i==5) {
            text(i+"V",screen_width/2-30,topgap+10);
            
          }
        }
      }
    }

    
    if(GRID_MAJOR_TIME==true)
    {
      stroke(grid1_red,grid1_green,grid1_blue);
      int spacing = scopeXsize/10;
      for(int i=0;i<=10;i++)
      {
        if(FULL_GRID==true)
        {
          line(topgap+i*spacing,topgap,topgap+i*spacing,scopeYsize+topgap);
          if(total_displayed_time<2000)
          {
            text((i*(total_displayed_time/10))+"us",topgap+i*spacing-10,topgap-10);
          } else {
            String temp = String.format("%.1fms",((float)i*((float)total_displayed_time/10000.0)));
            text(temp,topgap+i*spacing-10,topgap-10);            
          }
        } else {
          line(topgap+i*spacing,screen_height*3/8-10+topgap,topgap+i*spacing,screen_height*3/8+10+topgap);        
          if(total_displayed_time<2000)
          {
            if(i>0&&i<10&&i!=5)
            {
              text((i*(total_displayed_time/10))+"us",topgap+i*spacing-10,screen_height*3/8+10+topgap+10);
            } else if(i==0) {
              text((i*(total_displayed_time/10))+"us",topgap+5,screen_height*3/8+10+topgap+10);            
            } else if(i==10) {
              text((i*(total_displayed_time/10))+"us",screen_width-topgap-35,screen_height*3/8+10+topgap+10);            
            }
          } else {
            String temp = String.format("%.1fms",((float)i*((float)total_displayed_time/10000.0)));
            if(i>0&&i<10&&i!=5)
            {
              text(temp,topgap+i*spacing-10,screen_height*3/8+10+topgap+10);
            } else if(i==0) {
              text(temp,topgap+5,screen_height*3/8+10+topgap+10);            
            } else if(i==10) {
              text(temp,screen_width-topgap-30,screen_height*3/8+10+topgap+10);            
            }
          }

        }
      }
    }

    if(GRID_FREQ==true)
    {
      stroke(grid1_red,grid1_green,grid1_blue);
      int spacing = (fft_width-2*topgap)/10;
      for(int i=0;i<=10;i++)
      {
    
        line(topgap+750+i*spacing,scopeYsize+topgap-10,topgap+750+i*spacing,scopeYsize+topgap);        
        text((i*(Nyquist_freq/10.0))+"MHz",topgap+730+i*spacing,scopeYsize+topgap+10);          
      }
    }

    
    stroke(line_red,line_green,line_blue);    
    if(SHOW_TRIGGER==true)
    {
      int numdashes = scopeXsize/6;
      for(int i=0;i<=numdashes;i++)
      {
        line(topgap+i*6,ScaleVertically(Trigger_Value),topgap+i*6+3,ScaleVertically(Trigger_Value));
      }
      
      String TrigStr = String.format("%.2fV",Trigger_Value);
      if(Trigger_Value<4.8)
      {
        text(TrigStr,topgap+5,ScaleVertically(Trigger_Value)-5);
      } else {
        text(TrigStr,topgap+5,ScaleVertically(Trigger_Value)+10);        
      }
    }
    if(CURSOR_1==true)
    {
        Cursor1V = captured_data[(int)((Cursor1Val*scopeXsize/10+scopeXsize/2)*NUMBER_OF_SAMPLES/scopeXsize)];
        String C1Str = String.format("%.0fus",(Cursor1Val+5.0)*total_displayed_time/10.0);
        String C1VStr = String.format("%.2fV",(Cursor1V)*10.0/255.0-5);
        line(Cursor1Val*scopeXsize/10+topgap+scopeXsize/2,topgap,Cursor1Val*scopeXsize/10+topgap+scopeXsize/2,topgap+scopeYsize);
        line(Cursor1Val*scopeXsize/10+topgap+scopeXsize/2-8,topgap+scopeYsize-(Cursor1V*scopeYsize)/255,Cursor1Val*scopeXsize/10+topgap+scopeXsize/2+8,topgap+scopeYsize-(Cursor1V*scopeYsize)/255);
        if(Cursor1Val<4.6)
        {
          text(C1Str,(Cursor1Val*scopeXsize/10+topgap+scopeXsize/2)+5,topgap+scopeYsize-3);
          text(C1VStr,(Cursor1Val*scopeXsize/10+topgap+scopeXsize/2)+5,topgap+scopeYsize-13);
        } else {
          text(C1Str,(Cursor1Val*scopeXsize/10+topgap+scopeXsize/2)-30,topgap+scopeYsize-3);
          text(C1VStr,(Cursor1Val*scopeXsize/10+topgap+scopeXsize/2)-30,topgap+scopeYsize-13);
        }
    }
    if(CURSOR_2==true)
    {
        Cursor2V = captured_data[(int)((Cursor2Val*scopeXsize/10+scopeXsize/2)*NUMBER_OF_SAMPLES/scopeXsize)];
        String C2Str = String.format("%.0fus",(Cursor2Val+5.0)*total_displayed_time/10.0);
        String C2VStr = String.format("%.2fV",(Cursor2V)*10.0/255.0-5);
        line(Cursor2Val*scopeXsize/10+topgap+scopeXsize/2,topgap,Cursor2Val*scopeXsize/10+topgap+scopeXsize/2,topgap+scopeYsize);
        line(Cursor2Val*scopeXsize/10+topgap+scopeXsize/2-8,topgap+scopeYsize-(Cursor2V*scopeYsize)/255,Cursor2Val*scopeXsize/10+topgap+scopeXsize/2+8,topgap+scopeYsize-(Cursor2V*scopeYsize)/255);
        if(Cursor2Val<4.6)
        {
          text(C2Str,(Cursor2Val*scopeXsize/10+topgap+scopeXsize/2)+5,topgap+scopeYsize-3);
          text(C2VStr,(Cursor2Val*scopeXsize/10+topgap+scopeXsize/2)+5,topgap+scopeYsize-13);
        } else {
          text(C2Str,(Cursor2Val*scopeXsize/10+topgap+scopeXsize/2)-30,topgap+scopeYsize-3);
          text(C2VStr,(Cursor2Val*scopeXsize/10+topgap+scopeXsize/2)-30,topgap+scopeYsize-13);
        }
    }

    
    
    noFill();
    rect(topgap,topgap,screen_width-topgap*2,scopeYsize,0);//screen
    line(topgap,screen_height*3/8+topgap,screen_width-topgap,screen_height*3/8+topgap);
    line((screen_width/2),topgap,(screen_width/2),scopeYsize+topgap);
    fill(line_red,line_green,line_blue);
    
    if(DSO_connected==false)
    {
      fill(background_red,background_green,background_blue);
      stroke(line_red,line_green,line_blue);
      rect(topgap,topgap,screen_width-topgap*2,scopeYsize);//screen
  
      fill(line_red,line_green,line_blue);
      text("No DSO detected.",screen_width/2-40,scopeYsize/2+topgap);
      text("Please check connection and restart the GUI.",screen_width/2-100,scopeYsize/2+topgap+15);
    }
    stroke(0,255,255);
    for(int j=0;j<scopeXsize;j++)
    {
      int startindex = j*NUMBER_OF_SAMPLES/scopeXsize;
      int stopindex = startindex+1;//+samples_per_column;
      
      if(DRAW_LINE==true&&j>0)
      {
         
        if(captured_data[startindex]>0)
        {
          line(topgap+j,topgap+scopeYsize-(captured_data[startindex-samples_per_column]*scopeYsize)/255,topgap+j,topgap+scopeYsize-(captured_data[startindex]*scopeYsize)/255);
        }
        
      } else {
        for(int i=startindex;i<stopindex;i++)
        {
            point(topgap+j,topgap+scopeYsize-(captured_data[i]*scopeYsize)/255);
        }
         
       }
      
    }
    
    //fft();
    
        
    stroke(line_red,line_green,line_blue);
    fill(button_off_red,button_off_green,button_off_blue);
    rect(screen_width-130,7,120,20);
    fill(line_red,line_green,line_blue);


    if(program_state==1)
    {
      text("READY",screen_width-120,20);
    } else if(program_state==2) {
      text("CAPTURING...",screen_width-120,20);      
    } else if(program_state==3) {
      text("WAITING FOR DATA...",screen_width-120,20);      
    } else if(program_state==4) {
      text("RECEIVING DATA...",screen_width-120,20);      
    }
    
    if(program_state==1&&CONT_MODE==true) {
      Capture();
    }

    if(CURSOR_1&&CURSOR_2)
    {
      deltaT = total_displayed_time*abs(Cursor1Val-Cursor2Val)/10.0;
      deltaTinv = 1.0/deltaT;
      
      stroke(line_red,line_green,line_blue);
      fill(button_off_red,button_off_green,button_off_blue);
      /*
      rect(topgap+267,topgap+scopeYsize+20,100,60);
      fill(line_red,line_green,line_blue);
      text("Cursor analysis:",topgap+270,topgap+scopeYsize+32);
      text(String.format("   ΔT = %.2fus",deltaT),topgap+270,topgap+scopeYsize+42);
      text(String.format("1/ΔT = %.2fkHz",deltaTinv*1000.0),topgap+270,topgap+scopeYsize+52);
      text(String.format("   ΔV = %.2fV",abs(Cursor1V-Cursor2V)*10/255),topgap+270,topgap+scopeYsize+62);
      */
      rect(topgap+10,topgap+scopeYsize+20-90,100,60);
      fill(line_red,line_green,line_blue);
      text("Cursor analysis:",topgap+13,topgap+scopeYsize+32-90);
      text(String.format("   ΔT = %.2fus",deltaT),topgap+13,topgap+scopeYsize+42-90);
      text(String.format("1/ΔT = %.2fkHz",deltaTinv*1000.0),topgap+13,topgap+scopeYsize+52-90);
      text(String.format("   ΔV = %.2fV",abs(Cursor1V-Cursor2V)*10/255),topgap+13,topgap+scopeYsize+62-90);
    }
    
}

void serialEvent(Serial USBDSOPort) 
{
  if(program_state==3||program_state==4)
  {
    captured_data[dataindex] = int(USBDSOPort.read());
    //println("Received data: "+captured_data[dataindex]+"  - Stored in slot "+dataindex);
    if(program_state==3)
    {
      program_state=4;
    }
    dataindex++;
    if (dataindex > NUMBER_OF_SAMPLES)
    {
      USBDSOPort.write('n');
      dataindex=0;
      program_state=1;
    }
  } else if(program_state==2) {
    if(int(USBDSOPort.read())=='C') {
      dataindex=0;
      program_state=3;
    }
  } else {
    int garbage = int(USBDSOPort.read());
    if (program_state==1){
      //print((char)garbage);
    }
    
  }
}

void mousePressed() 
{
 mouse_x = mouseX;
 mouse_y = mouseY;
 
 if(abs(mouse_y-ScaleVertically(Trigger_Value))<10&&SHOW_TRIGGER==true)
 {
   dragging_trigger = true;
 }
 if(abs(mouse_x-((Cursor1Val*scopeXsize/10)+screen_width/2))<10&&CURSOR_1==true)
 {
   dragging_c1 = true; 
 }
 if(abs(mouse_x-((Cursor2Val*scopeXsize/10)+screen_width/2))<10&&CURSOR_2==true)
 {
   dragging_c2 = true; 
 }
}

void keyPressed() 
{
  if(key == ESC){return;}
  else if(DSO_connected){
    // Send the keystroke out:
    ReceivedString = "";
    USBDSOPort.write(key);
    KeyStroke = char(key);
    x=0;
    //rect(0,0,width,height/2);
  }
}

int ScaleVertically(float v)
{
  return ((int(-(v/5.0)*3.0*float(screen_height)/8.0))+screen_height*3/8+topgap);
}

public void Capture() {
  //println("capture pressed");
    if(DSO_connected){
      USBDSOPort.write('n');
      USBDSOPort.write('C');
      program_state=2;
      FFT_COMP = false;
      /*for(int i=0;i<65000;i++)
      {
         captured_data[i]=0; 
      }*/
      capturestarttime=millis();
    }
}
public void Force_Trigger() {
    if(DSO_connected){
      USBDSOPort.write('n');
      USBDSOPort.write('f');
      program_state=2;
      capturestarttime=millis();
    }
}
public void Abort() {
    if(DSO_connected){
      USBDSOPort.write('n');
      program_state=1;
    }
}

public void Highspeed() {
  if (BaudValue==38400) {
    BaudValue = 250000;
    USBDSOPort.write('B');
    USBDSOPort.stop();
    println("Changing Baud rate to "+BaudValue);
    USBDSOPort = new Serial(this, portList[(int)CPList.getValue()], BaudValue);
    HighspeedButton.setColorForeground(color(button_on_red,button_on_green,button_on_blue));
  }
}

void mouseReleased() {
  if(dragging_trigger==true)
  {
      NewTriggerLevel = true;
      dragging_trigger = false;
  }
  dragging_c1=false;
  dragging_c2=false;
}

void controlEvent(ControlEvent theEvent) {
  if(theEvent.isFrom(SampleRateControl)&&DSO_connected) {
    Sample_Rate = (char)theEvent.getValue();
      USBDSOPort.write('n');
    USBDSOPort.write('r');
    USBDSOPort.write((Sample_Rate+48));  
    println("Sample rate set to "+(int)Sample_Rate);
  }
  if(theEvent.isFrom(TriggerKnob)) {
    NewTriggerLevel=true;
  }
  
  if(theEvent.isFrom(EdgeSwitchButton)&&DSO_connected) {
    if(EDGE_SW==true) {
      USBDSOPort.write('i');
      USBDSOPort.write('f');
      println("edge switch on");
    } else {
      USBDSOPort.write('i');
      USBDSOPort.write('r');
      println("edge switch off");
    }
  }

  if(theEvent.isFrom(CPList)) {
    
    USBDSOPort.stop();
    println("Changing COM port to "+portList[(int)CPList.getValue()]);
    USBDSOPort = new Serial(this, portList[(int)CPList.getValue()], BaudValue);
  }
  /*
  if(theEvent.isFrom(BaudList)) {
    if (DSO_connected==true) {
      //USBDSOPort.write('B');
    }
    USBDSOPort.stop();
    if((int)BaudList.getValue()==1)
    {
       BaudValue = 38400;
    } else if((int)BaudList.getValue()==2)
    {
       BaudValue = 115200;
    }
    println("Changing baud rate to "+BaudValue);
    USBDSOPort = new Serial(this, portList[(int)CPList.getValue()], BaudValue);
  }
  */
  
}

public void fft(){
  Complex sum;
  int freq_samples=NUMBER_OF_SAMPLES;
  if (program_state==1 & FFT_COMP == false){
    //APACHE LIBRARY IMPLEMENTATION
    
    /*if (NUMBER_OF_SAMPLES > 20000){
      freq_samples = 20000;
    }*/
    
    for (int i=0; i<(int)NUMBER_OF_SAMPLES/20; i++){
      sum = Complex.ZERO;
      for (int j=0; j<NUMBER_OF_SAMPLES; j++){
        sum = new Complex(0,-2*3.1415*i*10*j/NUMBER_OF_SAMPLES).exp().multiply(captured_data[j]).add(sum);
      }
      fft_data[i] = (float)sum.abs();
    }
    FFT_COMP = true;
  }
  
  //Plot
  float max_val = log(max(fft_data))/log(10);
  for(int j=0;j<(fft_width-2*topgap);j++)
  {
    int startindex= j*NUMBER_OF_SAMPLES/20/(fft_width-2*topgap); 
    int stopindex = startindex+1;//+samples_per_column;
    
    if (FREQ_LINE == true&&j>0){
      if(fft_data[startindex]>0)
      {
        line(topgap+750+j,topgap+scopeYsize-(log(fft_data[startindex])/log(10)*scopeYsize/max_val),topgap+750+j,topgap+scopeYsize-(log(fft_data[startindex+j*NUMBER_OF_SAMPLES/20/(fft_width-2*topgap)])/log(10)*scopeYsize/max_val));
      }
    } else {
      for(int i=startindex;i<stopindex;i++)
      {
            point(topgap+750+j,topgap+scopeYsize-(log(fft_data[i])/log(10))*scopeYsize/max_val);
      }
    }  
  }
  
} 
