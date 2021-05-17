#property copyright "Copyright 2021, WittStack && Mr. Destiny Cooperatiion"
#property link      "http://www.wittstack.herokuapp.com"
#property description "ALERT SENDING TO MR DESTINY"
#property description "DISCLAIMER: The use of this software does not guanrantee 100% return on your investment. You may loose your capital in Forex"
#property strict
#property version   "1.00"
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue

#include <Telegram/Telegram.mqh>

input int TenEMA = 10;
input int ThirteenEMA = 13;
input int FiftyEMA = 50;
input int  TwoHundredEMA = 200;
input int    TriggerCandle      = 1;
input bool   EnableNativeAlerts = true;
input bool   EnableSoundAlerts  = true;
input bool   EnableEmailAlerts  = true;
input bool   EnablePushAlerts  = true;
input string AlertEmailSubject  = "WittStack Alert";
input string AlertText          = "WittStack";
input string SoundFileName      = "alert.wav";

input ENUM_MA_METHOD MA_Method=MODE_EMA; 

//+------------------------------------------------------------------+
//|   CMyBot                                                         |
//+------------------------------------------------------------------+
class CMyBot: public CCustomBot
  {
public:
   void ProcessMessages(void)
     {
      for(int i=0; i<m_chats.Total(); i++)
        {
         CCustomChat *chat=m_chats.GetNodeAtIndex(i);
         //--- if the message is not processed
         if(!chat.m_new_one.done)
           {
            chat.m_new_one.done=true;
            string text=chat.m_new_one.message_text;

            //--- start
            if(text=="/start")
               SendMessage(chat.m_id,"Hello, world! I am bot. How can I be of help. We will respond as soon as we are online \xF680");

            //--- help
            if(text=="/help")
               SendMessage(chat.m_id,"My commands list: \n/start-start chatting with me \n/help-get help");
           }
        }
     }
  };

//---
input string InpChannelName="@wittstackchannel";//Channel Name
input string InpToken="TELEGRAM_TOKEN";//Token
//---
CMyBot bot;
int getme_result;
//+------------------------------------------------------------------+
//|   OnInit                                                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set token
   bot.Token(InpToken);

//--- check token
   getme_result=bot.GetMe();
  // bot.SendMessage(InpChannelName,"hello from bot");
//--- run timer
   EventSetTimer(3);
   OnTimer();
//--- done
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|   OnDeinit                                                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Comment("");
  }
//+------------------------------------------------------------------+
//|   OnTimer                                                        |
//+------------------------------------------------------------------

void OnTimer()
  {
//--- show error message end exit
   if(getme_result!=0)
     {
      Comment("Error: ",GetErrorDescription(getme_result));
      return;
     }
//--- show bot name
   Comment("Bot name: ",bot.Name());
//--- reading messages
   bot.GetUpdates();
//--- processing messages
   bot.ProcessMessages();
  }
  
  
  
  
void OnTick()
  {

   datetime times[1];
   if(CopyTime(NULL,0,0,1,times)!=1)
      return;
      
  static datetime timestamp;
  datetime time = iTime(_Symbol, PERIOD_CURRENT,0);
  if(timestamp != time) {
  timestamp = time;
//---
   
   int handlerTenMa = iMA(_Symbol,PERIOD_CURRENT,TenEMA,0,MA_Method,PRICE_CLOSE);
   double TenMaArray[];
  CopyBuffer(handlerTenMa,0,1,2, TenMaArray);
  ArraySetAsSeries(TenMaArray, true);
  
   static int handlerThirteenMa = iMA(_Symbol,PERIOD_CURRENT,ThirteenEMA,0,MA_Method,PRICE_CLOSE);
   double ThirteenMaArray[];
  CopyBuffer(handlerThirteenMa,0,1,2, ThirteenMaArray);
  ArraySetAsSeries(ThirteenMaArray, true);
  
   int handlerFiftyMa = iMA(_Symbol,PERIOD_CURRENT,FiftyEMA,0,MA_Method,PRICE_CLOSE);
   double FiftyMaArray[];
  CopyBuffer(handlerFiftyMa,0,1,2, FiftyMaArray);
  ArraySetAsSeries(FiftyMaArray, true);
 
  
   static int handlerTwoHundredMa = iMA(_Symbol,PERIOD_CURRENT,TwoHundredEMA,0,MA_Method,PRICE_CLOSE);
   double TwoHundredMaArray[];
  CopyBuffer(handlerTwoHundredMa,0,1,2, TwoHundredMaArray);
  ArraySetAsSeries(TwoHundredMaArray, true);
  
  static string Text;
  
  
  
   
  if(TenMaArray[0] < ThirteenMaArray[0] && TenMaArray[1] > ThirteenMaArray[1]) {
   Print("Fast Ma is now > than slow Ma");
   
   
   string msg=StringFormat("Name: EMA Signal\nSymbol: %s\nTimeframe: %s\nType: Buy\nPrice: %s\nTime: %s",
                                 _Symbol,
                                 StringSubstr(EnumToString(_Period),7),
                                 DoubleToString(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits),
                                 TimeToString(times[0]));
         int res=bot.SendMessage(InpChannelName,msg);
         if(res!=0)
            Print("Error: ",GetErrorDescription(res));
   
        
   Text = AlertText + "BOUGHT " + _Symbol + " - " + EnumToString(_Period);
                if (EnableNativeAlerts) Alert(Text);
                if (EnableEmailAlerts) SendMail(AlertEmailSubject + "Aroon Up & Down Alert", Text);
                if (EnableSoundAlerts) PlaySound(SoundFileName);
                if (EnablePushAlerts) SendNotification(Text);
  }
  
  
  
  
  
  else if(TenMaArray[0] < ThirteenMaArray[0] && TenMaArray[1] > ThirteenMaArray[1]) {
   Print("Fast Ma is now < than slow Ma");
   
   
    string msg=StringFormat("Name: EMA Signal\nSymbol: %s\nTimeframe: %s\nType: Sell\nPrice: %s\nTime: %s",
                                 _Symbol,
                                 StringSubstr(EnumToString(_Period),7),
                                 DoubleToString(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits),
                                 TimeToString(times[0]));
                                 
       int res=bot.SendMessage(InpChannelName,msg);
         if(res!=0)
            Print("Error: ",GetErrorDescription(res));
            
            
             Text = AlertText + "SOLD " + _Symbol + " - " + EnumToString(_Period);
                if (EnableNativeAlerts) Alert(Text);
                if (EnableEmailAlerts) SendMail(AlertEmailSubject + "Aroon Up & Down Alert", Text);
                if (EnableSoundAlerts) PlaySound(SoundFileName);
                if (EnablePushAlerts) SendNotification(Text);
 
  }
  
  
  
  
  
  
  
  
  
  
  if(FiftyMaArray[0] < TwoHundredMaArray[0] && FiftyMaArray[1] > TwoHundredMaArray[1]) {
   Print("Fast Ma is now > than slow Ma");
   
   
   string msg=StringFormat("Name: EMA Signal\nSymbol: %s\nTimeframe: %s\nType: Buy\nPrice: %s\nTime: %s",
                                 _Symbol,
                                 StringSubstr(EnumToString(_Period),7),
                                 DoubleToString(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits),
                                 TimeToString(times[0]));
         int res=bot.SendMessage(InpChannelName,msg);
         if(res!=0)
            Print("Error: ",GetErrorDescription(res));
   
        
   Text = AlertText + "BOUGHT " + _Symbol + " - " + EnumToString(_Period);
                if (EnableNativeAlerts) Alert(Text);
                if (EnableEmailAlerts) SendMail(AlertEmailSubject + "Aroon Up & Down Alert", Text);
                if (EnableSoundAlerts) PlaySound(SoundFileName);
                if (EnablePushAlerts) SendNotification(Text);
  }
  
  
  
  
  
  if(FiftyMaArray[0] < TwoHundredMaArray[0] && FiftyMaArray[1] > TwoHundredMaArray[1]) {
   Print("Fast Ma is now < than slow Ma");   
   
    string msg=StringFormat("Name: EMA Signal\nSymbol: %s\nTimeframe: %s\nType: Sell\nPrice: %s\nTime: %s",
                                 _Symbol,
                                 StringSubstr(EnumToString(_Period),7),
                                 DoubleToString(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits),
                                 TimeToString(times[0]));
                                 
       int res=bot.SendMessage(InpChannelName,msg);
         if(res!=0)
            Print("Error: ",GetErrorDescription(res));
            
            
             Text = AlertText + "SOLD " + _Symbol + " - " + EnumToString(_Period);
                if (EnableNativeAlerts) Alert(Text);
                if (EnableEmailAlerts) SendMail(AlertEmailSubject + "Aroon Up & Down Alert", Text);
                if (EnableSoundAlerts) PlaySound(SoundFileName);
                if (EnablePushAlerts) SendNotification(Text);
 
  }
  
  Comment("\nslowMaArray[0]", TenMaArray[0],
          "\nslowMaArray[1]", TenMaArray[1],
          "\nfastMaArray[0]", TwoHundredMaArray[0],
          "\nfastMaArray[1]", TwoHundredMaArray[1]);
  }
  }